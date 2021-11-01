import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as path from "path";
import speech from "@google-cloud/speech";
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//

const serviceAccount = require("../google-services.json");

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

const runTranscription =  async (audioPath: string, transcriptPath: string): Promise<string | undefined> => {
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
      gcsUri: baseBucketURL + transcriptPath,
    };
    const speechRequest = {
      audio,
      config,
      outputConfig,
    };

    const [operation] = await client.longRunningRecognize(speechRequest);
    // Get a Promise representation of the final result of the job
    console.log(operation.name);
    return operation.name;

    // const [res] = await operation.promise();
    // const transcription = res?.results
    //   ?.map((result: any) => result?.alternatives[0].transcript)
    //   .join("\n");

    // return {
    //   data: `Transcription: ${transcription}`,
    // };

};

export const requestTranscription = functions
  .runWith({
    // Ensure the function has enough memory and time
    // to process large files
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
      const transcriptPath = generateTranscriptPath(audioPath);
      const operationID = await runTranscription(audioPath, transcriptPath);
      return {
        operationID,
        path: transcriptPath,
      };

      // const [res] = await operation.promise();
      // const transcription = res?.results
      //   ?.map((result: any) => result?.alternatives[0].transcript)
      //   .join("\n");

      // return {
      //   data: `Transcription: ${transcription}`,
      // };
    } catch (error) {
      console.log(error);
      return { error };
    }

  });

export const mockTranscription = functions
  .runWith({
    // Ensure the function has enough memory and time
    // to process large files
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
    const bucket = admin.storage().bucket();

    let operationID = '';

    // Run actual transcriptions for admins and place at bucket root
    if (context.auth?.token.email?.includes("admin")) {
      const filename = path.basename(audioPath);
      await bucket
      .file(audioPath)
      .copy(bucket.file(filename));

      operationID = await runTranscription(audioPath, generateTranscriptPath(filename)) || '';
      console.log(operationID);
    }

    const transcriptPath = generateTranscriptPath(audioPath);

    console.log(data.template);
    await bucket
      .file(data.template || "5- Minute Lecture - Professor Irwin Goldman_transcript.json")
      .copy(bucket.file(transcriptPath));

    return {
      operationID,
      path: transcriptPath,
    };

  });

// export const checkTranscriptionOperation = functions.https.onCall(
//   async (data, context) => {
//     // const client = new speech.SpeechClient();
//     // client.checkLongRunningRecognizeProgress('');

//     return "should probably be in server";
//   }
// );
