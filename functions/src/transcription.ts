import speech from "@google-cloud/speech";
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
