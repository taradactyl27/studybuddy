import * as functions from "firebase-functions";
import * as path from "path";
import * as os from "os";
import * as fs from "fs";
import ffmpegCommand from "fluent-ffmpeg";
import ffmpeg_static from "ffmpeg-static";
import { startTranscribe } from "./transcription";

import { admin, bucket } from "./config";

const defaultMockTranscriptPath = "mock_transcript.json";
const extensionRegex = /\.[^/.]+$/;

export const onObjectUploaded = functions
  .runWith({
    // Ensure the function has enough memory and time
    // to process large files
    timeoutSeconds: 360,
    memory: "2GB",
  })
  .storage.object()
  .onFinalize(async (object, context) => {
    const contentType = object.contentType!;
    const filePath = object.name!;

    // file is at bucket base / is admin copy
    if (!filePath.includes("/")) {
      functions.logger.log("copy generated by admin dev");
      return;
    }

    // file is a transcript
    if (
      contentType.startsWith("application/json") &&
      filePath.endsWith("_transcript.json")
    ) {
      functions.logger.log("generated transcript json file added");

      await readTranscript(filePath);
      if (path.dirname(filePath).endsWith("admin")) {
        await bucket.file(filePath).copy(path.basename(filePath));
      }
      return;
    }

    // file has no metadata
    if (!object.metadata) {
      functions.logger.log("No metadata for file");
      return;
    }

    const metadata = object.metadata;
    const { courseID, audioID, uid, mocker, mockTemplate } = metadata;

    let audioDoc = admin
      .firestore()
      .collection("courses")
      .doc(courseID)
      .collection("audios")
      .doc(audioID);

    if (mocker.includes("data")) {
     audioDoc = admin
      .firestore()
      .collection("lectures")
      .doc(audioID);
    }

    await audioDoc.set(
      {
        courseID,
        roles: {
          [uid]: {
            email: mocker,
            role: "owner"
          }
        },
        created: admin.firestore.Timestamp.now(),
        status: "in the clouds",
        owner: uid,
        audioRef: filePath,
        notesGenerated: false,
      },
      { merge: true }
    );

    // file not converted to optimal format
    if (!metadata.formatted) {
      if (
        !(contentType.startsWith("audio/") || contentType.startsWith("video/"))
      ) {
        functions.logger.log("not a valid source file to format");
        return;
      }

      functions.logger.log("converting to flac audio file");

      await audioDoc.update({
        status: "converting file...",
      });
      await convertToFlac(filePath, contentType, metadata);
      return;
    }

    // file ready for transcription
    functions.logger.log("TRANSCRIBE STAGE");

    try {

      const transcriptPath = `${courseID}/${audioID}/${
        mocker.includes("admin") ? "admin/" : ""
      }${filePath.replace(extensionRegex, "_transcript.json")}`;

      await audioDoc.update({
        status: "transcribing file...",
      });

      if (mocker && !mocker.includes("admin")) {
        functions.logger.log("mocking transcribe");
        console.log(mockTemplate);
        await bucket
          .file(mockTemplate ? mockTemplate : defaultMockTranscriptPath)
          .copy(bucket.file(transcriptPath));

        await audioDoc.update({
          transcriptRef: transcriptPath,
          status: "available",
        });
      } else {
        if (mocker.includes("admin")) {
          await bucket.file(filePath).copy(path.basename(filePath));
        }

        functions.logger.log("running transcribe");
        await audioDoc.update({
          isTranscribing: true,
        });
        await startTranscribe(filePath, transcriptPath);
      }
    } catch (e) {
      functions.logger.log(e);
      await audioDoc.update({
        error: JSON.stringify(e),
        status: "error in transcription process...",
      });
      functions.logger.error(e);
      return;
    }
  });

// Makes an ffmpeg command return a promise.
const promisifyCommand = (command: ffmpegCommand.FfmpegCommand) => {
  return new Promise((resolve, reject) => {
    command.on("end", resolve).on("error", reject).run();
  });
};

const convertToFlac = async (
  filePath: string,
  contentType: string,
  metadata: Object
) => {
  const fileName = path.basename(filePath);
  const tempFilePath = path.join(os.tmpdir(), fileName);
  const targetTempFileName = fileName.replace(extensionRegex, ".flac");
  const targetTempFilePath = path.join(os.tmpdir(), targetTempFileName);
  const targetStorageFilePath = path.join(
    path.dirname(filePath),
    targetTempFileName
  );

  await bucket.file(filePath).download({ destination: tempFilePath });
  functions.logger.log(`Audio downloaded locally to: ${tempFilePath}`);

  let command = ffmpegCommand(tempFilePath).setFfmpegPath(ffmpeg_static);

  if (contentType.startsWith("video/")) {
    command = command.noVideo();
  }

  command = command
    .audioChannels(1)
    .audioFrequency(16000)
    .format("flac")
    .output(targetTempFilePath);

  await promisifyCommand(command);
  functions.logger.log("Formatted audio created at", targetTempFilePath);

  // Uploading the audio.
  await bucket.upload(targetTempFilePath, {
    destination: targetStorageFilePath,
    metadata: {
      metadata: {
        ...metadata,
        formatted: true,
      },
    },
  });
  functions.logger.log(`Formatted audio uploaded to: ${targetStorageFilePath}`);

  // Once the audio has been uploaded delete the local file to free up disk space.
  fs.unlinkSync(tempFilePath);
  fs.unlinkSync(targetTempFilePath);

  functions.logger.log(`Temporary files removed: ${targetTempFilePath}`);

  return targetStorageFilePath;
};

const readTranscript = async (filePath: string) => {
  const [courseID, audioID] = filePath.split("/");

  const audioDoc = admin
    .firestore()
    .collection("courses")
    .doc(courseID)
    .collection("audios")
    .doc(audioID);

  try {
    const data = await bucket.file(filePath).download();
    const transcript = JSON.parse(data[0].toString());
    const transcriptText = transcript.results
      .map((result: any) => result?.alternatives[0].transcript)
      .join("\n");

    functions.logger.log(transcriptText);

    await audioDoc.update({
      transcriptRef: filePath,
      text: transcriptText,
      isTranscribing: false,
    });
  } catch (e) {
    await audioDoc.update({
      error: "error adding transcript to db",
    });
    functions.logger.error(e);
  }
};
