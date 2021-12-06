import * as functions from "firebase-functions";
import { bucket } from "./config";
import { toTranscriptPath } from "./storage";

export const defaultMockTranscriptPath = "mock_transcript.json";

// TODO: delete post storage triggers deploy
export const mockTranscript = functions
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
    const transcriptPath = toTranscriptPath(audioPath);
    await bucket
      .file(data.template ? data.template : defaultMockTranscriptPath)
      .copy(bucket.file(transcriptPath));

    return {
      path: transcriptPath,
    };
  });
