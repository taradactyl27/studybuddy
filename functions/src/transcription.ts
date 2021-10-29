import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as path from "path";
import speech from "@google-cloud/speech";
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//

const serviceAccount = require("../../google-services.json");

const firebaseConfig = JSON.parse(process.env.FIREBASE_CONFIG!);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  ...firebaseConfig,
});

const baseBucketURL = `gs://${firebaseConfig.projectId}.appspot.com/`;

const generateTranscriptPath = (audioPath: string) => {
  const { dir, name } = path.parse(audioPath);
  return `${path.join(dir, name)}_transcript.json`;
};

export const requestTranscription = functions
  .runWith({
    // Ensure the function has enough memory and time
    // to process large files
    timeoutSeconds: 360,
  })
  .https.onCall(async (data, context) => {
    console.log(!context.auth?.token.email?.includes("admin"));
    // Mock transcription calls for non-admin accounts by copying existing file
    if (!context.auth?.token.email?.includes("admin")) {
      const bucket = admin.storage().bucket();
      const transcriptPath = generateTranscriptPath(data.storagePath);

      console.log(data.template);
      await bucket
        .file(data.template || "Joann Peck, marketing (1).wav_transcript.json")
        .copy(bucket.file(transcriptPath));

      return {
        path: transcriptPath,
      };
    }

    // remove uid from 'admin' requests to put at base of bucket
    // end mock code: comment block above and replace below line with full path for 'prod' behavior
    const audioPath = path.basename(data.storagePath);

    // run transcription request
    const client = new speech.SpeechClient();
    const gcsUri = baseBucketURL + audioPath;
    const audio = {
      uri: gcsUri,
    };
    const config = {
      languageCode: "en-US",
      audioChannelCount: 2,
    };
    const outputConfig = {
      gcsUri: baseBucketURL + generateTranscriptPath(audioPath),
    };
    const speechRequest = {
      audio,
      config,
      outputConfig,
    };

    const [operation] = await client.longRunningRecognize(speechRequest);
    // Get a Promise representation of the final result of the job
    console.log(operation.name);
    return {
      operationID: operation.name,
    };

    // const [res] = await operation.promise();
    // const transcription = res?.results
    //   ?.map((result: any) => result?.alternatives[0].transcript)
    //   .join("\n");

    // return {
    //   data: `Transcription: ${transcription}`,
    // };
  });

export const checkTranscriptionOperation = functions.https.onCall(
  async (data, context) => {
    // const client = new speech.SpeechClient();
    // client.checkLongRunningRecognizeProgress('');

    return "should probably be in server";
  }
);
