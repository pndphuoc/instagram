const functions = require("firebase-functions");

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.updatePostsOfUser = functions.firestore
  .document('users/{userId}')
  .onUpdate((change, context) => {
    const userId = context.params.userId;
    const newUser = change.after.data();
    const previousUser = change.before.data();

    // Check if the user has updated their username or avatarUrl
    if (newUser.username !== previousUser.username || newUser.avatarUrl !== previousUser.avatarUrl) {

      // Get all posts of the user
      const postsRef = db.collection('posts').where('userId', '==', userId);

      return postsRef.get()
        .then(snapshot => {
          const batch = db.batch();
          snapshot.forEach(doc => {
            const postRef = db.collection('posts').doc(doc.id);

            // Update the username and avatarUrl of the post
            batch.update(postRef, {
              username: newUser.username,
              avatarUrl: newUser.avatarUrl
            });
          });

          // Commit the batch
          return batch.commit();
        })
        .catch(err => {
          console.log(err);
          return Promise.reject(err);
        });
    } else {
      return null;
    }
  });
