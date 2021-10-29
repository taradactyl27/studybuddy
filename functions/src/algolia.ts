import * as functions from "firebase-functions";
import algoliasearch from "algoliasearch";

// Initialize Algolia, requires installing Algolia dependencies:
// https://www.algolia.com/doc/api-client/javascript/getting-started/#install
//
// App ID and API Key are stored in functions config variables
const ALGOLIA_ID = functions.config().algolia.app_id;
const ALGOLIA_ADMIN_KEY = functions.config().algolia.api_key;
const ALGOLIA_SEARCH_KEY = functions.config().algolia.search_key;

const ALGOLIA_INDEX_NAME = "audios";
const client = algoliasearch(ALGOLIA_ID, ALGOLIA_ADMIN_KEY);

export const onAudioCreated = functions.firestore
  .document("courses/{courseID}/audios/{audioID}")
  .onUpdate((change, context) => {
    // Get the updated document
    const audio = change.after.data();
    if (audio.text) {
      console.log("UPDATING ALGOLIA");
      audio.objectID = context.params.audioID;
      audio.course = context.params.courseID;
      audio.access = [audio.owner, `course/${context.params.courseID}`];

      // Write to the algolia index
      const index = client.initIndex(ALGOLIA_INDEX_NAME);
      return index.partialUpdateObject(audio, { createIfNotExists: true });
    }
    return;
  });

export const onAudioDeleted = functions.firestore
  .document("courses/{courseID}/audios/{audioID}")
  .onDelete((_snap, context) => {
    const index = client.initIndex(ALGOLIA_INDEX_NAME);
    return index.deleteObject(context.params.audioID);
  });

export const generateSearchKey = functions.https.onCall(
  async (_data, context) => {
    const uid = context.auth?.uid;
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "function call not authenticated somehow??"
      );
    }

    const params = {
      // This filter ensures that only documents where owner == uid will be readable
      filters: `owner:${context.auth.uid}`,
      // We also proxy the uid as a unique token for this key.
      userToken: uid,
    };

    // Call the Algolia API to generate a unique key based on our search key
    const key = client.generateSecuredApiKey(ALGOLIA_SEARCH_KEY, params);

    return { key };
  }
);
