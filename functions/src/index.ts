import * as functions from 'firebase-functions';
import speech from '@google-cloud/speech';
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//

export const requestTranscription = functions.runWith({
    // Ensure the function has enough memory and time
    // to process large files
    timeoutSeconds: 360,
  }).https.onCall(async (data, context) => {  
 const client = new speech.SpeechClient();

 const gcsUri = `gs://study-buddy-268e6.appspot.com/${ data.storagepath || 'Joann Peck, marketing.wav'}`;

  const audio = {
    uri: gcsUri,
  };
  
  const config = {
    languageCode: 'en-US',
    audioChannelCount: 2,
  };

  const outputConfig = {
    gcsUri: `gs://study-buddy-268e6.appspot.com/${data.storagepath}_transcript.txt`,
  };

  const speechRequest = {
    audio,
    config,
    outputConfig,
  };

    const [operation] = await client.longRunningRecognize(speechRequest);
    // Get a Promise representation of the final result of the job
    console.log(operation);
    const [res] = await operation.promise();
    const transcription = res?.results?.map((result:any) => result?.alternatives[0].transcript).join('\n');
    console.log(`Transcription: ${transcription}`);

  return {
    data: `Transcription: ${transcription}`,
  };
});


export const checkTranscriptionOperation = functions.https.onRequest(async (request, response) =>  {
   // const client = new speech.SpeechClient();

    // client.checkLongRunningRecognizeProgress('')
    response.send('should probably be in server');
});