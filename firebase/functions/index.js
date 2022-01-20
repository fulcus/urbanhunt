const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const storage = admin.storage()

exports.unlockPlacePoints = functions.firestore
  .document("users/{userId}/unlockedPlaces/{placeId}")
  .onCreate((snapshot, context) => {
    const docRef = db.collection("users").doc(context.params.userId);    
    docRef.update({ score: admin.firestore.FieldValue.increment(1) });
  });

exports.addPlacePoints = functions.firestore
  .document("places/{placeId}")
  .onCreate((snapshot, context) => {
    const userId = snapshot.data().creatorId;
    const docRef = db.collection("users").doc(userId);
    docRef.update({ score: admin.firestore.FieldValue.increment(5) });
  });

exports.deleteProfile = functions.auth.user().onDelete(async (user) => {
      const batch = db.batch();
      const profile = db.collection("users").doc(user.uid);

      batch.delete(profile);

      // Any other necessary cleanup (e.g. delete likes and dislikes of that user -> optional)

      await batch.commit();

      console.log(`Deleted profile ${user.uid}`);
  });

//clean storage after deleting a user
exports.firestoreDeleteProfileCleanUp = functions.firestore
    .document('users/{userId}')
    .onDelete((snapshot,context) => {

      const userId = context.params.userId
      const defaultBucket = storage.bucket();
      const file = defaultBucket.file("profile/" + userId);

      return file.delete();
  });

//todo check with security rules: when user added score == 0 and username is unique
//exports.addUser = functions.auth.user().onCreate((user) => {
//  db.collection("users").doc(user.uid).set({ score: 0 });
//});

// todo check with security rule like dislike exclusivity
//exports.updateLikes = functions.firestore
//  .document("users/{userId}/unlockedPlaces/{placeId}")
//  .onUpdate((change, context) => {
//    const docRef = db.collection("places").doc(context.params.placeId);
//    const newPlace = change.after.data();
//    const oldPlace = change.before.data();
//
//    // like or unlike
//    if (newPlace.liked && !oldPlace.liked) {
//      docRef.update({ likes: admin.firestore.FieldValue.increment(1) });
//    } else if (!newPlace.liked && oldPlace.liked) {
//      docRef.update({ likes: admin.firestore.FieldValue.increment(-1) });
//    }
//  });

