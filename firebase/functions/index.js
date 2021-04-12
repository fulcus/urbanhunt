const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.addUser = functions.auth.user().onCreate((user) => {
  db.collection("users").doc(user.uid).set({ score: 0 });
});

exports.unlockPlacePoints = functions.firestore
  .document("users/{userId}/unlockedPlaces/{placeId}")
  .onCreate((snapshot, context) => {
    const docRef = db.collection("users").doc(context.params.userId);    
    docRef.update({ score: admin.firestore.FieldValue.increment(1) });
  });

  exports.addPlacePoints = functions.firestore
  .document("places/{placeId}")
  .onCreate((snapshot, context) => {
    const docRef = db.collection("users").doc(context.auth.uid);
    docRef.update({ score: admin.firestore.FieldValue.increment(5) });
  });


/*
exports.updateLikes = functions.firestore
  .document("users/{userId}/unlockedPlaces/{placeId}")
  .onUpdate((change, context) => {
    const docRef = db.collection("places").doc(context.params.placeId);
    const newPlace = change.after.data();
    const oldPlace = change.before.data();

    // like or unlike
    if (newPlace.liked && !oldPlace.liked) {
      docRef.update({ likes: admin.firestore.FieldValue.increment(1) });
    } else if (!newPlace.liked && oldPlace.liked) {
      docRef.update({ likes: admin.firestore.FieldValue.increment(-1) });
    }
  });
  */

// check like dislike exclusivity with security rule
