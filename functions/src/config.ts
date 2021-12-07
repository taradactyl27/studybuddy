import * as admin from "firebase-admin";

const serviceAccount = require("../google-services.json");

const firebaseConfig = JSON.parse(process.env.FIREBASE_CONFIG!);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  ...firebaseConfig,
});

const bucket = admin.storage().bucket();
const projectId = firebaseConfig.projectId;

export { admin, projectId, bucket };
