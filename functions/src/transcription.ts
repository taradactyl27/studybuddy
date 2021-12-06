import * as functions from "firebase-functions";
import speech from "@google-cloud/speech";
import { toTranscriptPath } from "./storage";
import { projectId } from "./config";

const baseBucketURL = `gs://${projectId}.appspot.com/`;

export const startTranscribe = async (
  audioPath: string,
  transcriptPath: string
): Promise<string | undefined> => {
  const client = new speech.SpeechClient();
  const gcsUri = baseBucketURL + audioPath;
  const audio = {
    uri: gcsUri,
  };
  const config = {
    languageCode: "en-US",
  };
  const outputConfig = {
    gcsUri: baseBucketURL + transcriptPath,
  };

  const [operation] = await client.longRunningRecognize({
    audio,
    config,
    outputConfig,
  });

  console.log(operation.name);
  return operation.name;
};

// TODO: delete post storage triggers deploy
export const requestTranscript = functions
  .runWith({
    timeoutSeconds: 360,
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "function call not authenticated somehow??"
      );
    }

    const audioPath = data.storagePath;

    try {
      const transcriptPath = toTranscriptPath(audioPath);
      const operationID = await startTranscribe(audioPath, transcriptPath);
      return {
        operationID,
        path: transcriptPath,
      };
    } catch (error) {
      console.log(error);
      return { error };
    }
  });
