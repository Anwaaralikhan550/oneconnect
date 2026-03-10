const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

let firebaseApp = null;
let storageBucket = null;

function initializeFirebase() {
  if (firebaseApp) return { firebaseApp, storageBucket };

  const serviceAccountPath = path.join(__dirname, '../../firebase-service-account.json');

  try {
    if (fs.existsSync(serviceAccountPath)) {
      const serviceAccount = require(serviceAccountPath);
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
      });
    } else {
      // Fallback: use application default credentials or skip
      console.warn('[Firebase] No service account key found. File uploads will be disabled.');
      return { firebaseApp: null, storageBucket: null };
    }

    storageBucket = admin.storage().bucket();
    console.log('[Firebase] Storage initialized successfully');
  } catch (error) {
    console.warn('[Firebase] Initialization failed:', error.message);
  }

  return { firebaseApp, storageBucket };
}

function getStorageBucket() {
  if (!storageBucket) {
    initializeFirebase();
  }
  return storageBucket;
}

module.exports = { initializeFirebase, getStorageBucket };
