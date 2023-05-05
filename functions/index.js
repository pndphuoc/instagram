const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

exports.updateLikeCount = functions.firestore
    .document('likes/{likeId}')
    .onWrite(async (change, context) => {
        const postData = change.after.data();
        const postId = postData.postId;
        const commentId = postData.commentId;
        const commentListId = postData.commentListId;
        const likedBy = postData.likedBy;
        const replyCommentId = postData.replyCommentId;

        if (replyCommentId !== undefined) {
            const commentRef = db.collection('commentList').doc(commentListId).collection('comments').doc(commentId).collection('replyComments').doc(replyCommentId);

            await db.runTransaction(async (transaction) => {
                const likeCount = likedBy.length;

                transaction.update(commentRef, { likeCount });
            });
        } else if (postId === undefined) {
            const commentRef = db.collection('commentList').doc(commentListId).collection('comments').doc(commentId);

            await db.runTransaction(async (transaction) => {
                const likeCount = likedBy.length;

                transaction.update(commentRef, { likeCount });
            });
        } else if (replyCommentId === undefined) {
            const postRef = db.collection('posts').doc(postId);

            await db.runTransaction(async (transaction) => {
                const likeCount = likedBy.length;

                transaction.update(postRef, { likeCount });
            });
        } 
    });


// Listen for changes in subcollection 'comments' of collection 'commentList'
exports.updateCommentCount = functions.firestore.document('commentList/{commentListId}/comments/{commentId}')
    .onWrite(async (change, context) => {
        const commentListId = context.params.commentListId;

        const postQuerySnapshot = await db.collection('posts').where('commentListId', '==', commentListId).get();
        const postId = postQuerySnapshot.docs[0].id;

        const commentsQuerySnapshot = await db.collection(`commentList/${commentListId}/comments`).get();
        const commentCount = commentsQuerySnapshot.size;

        return db.collection('posts').doc(postId).update({ commentCount });
    });

exports.updateReplyCount = functions.firestore
    .document('commentList/{commentListId}/comments/{commentId}/replyComments/{replyCommentId}')
    .onWrite(async (change, context) => {
        const commentListId = context.params.commentListId;
        const commentId = context.params.commentId;

        const replyCommentQuery = await db.collection('commentList').doc(commentListId).collection('comments').doc(commentId).collection('replyComments').get();
        const replyCount = replyCommentQuery.size;

        return db.collection('commentList').doc(commentListId).collection('comments').doc(commentId).update({replyCount});
    });


 exports.updateUserInfo = functions.firestore.document('users/{uid}').onUpdate((change, context) => {
  const newData = change.after.data();
  const oldData = change.before.data();
  const uid = context.params.uid;

  const avatarUrlChanged = oldData.avatarUrl !== newData.avatarUrl;
  const usernameChanged = oldData.username !== newData.username;
  const displayNameChanged = oldData.displayName !== newData.displayName;

  const batch = admin.firestore().batch();

  // Update user info in conversation collection
  const conversationRef = admin.firestore().collection('conversation').where('users', 'array-contains', {avatarUrl: oldData.avatarUrl, displayName: oldData.displayName, userId: uid, username: oldData.username});
  conversationRef.get().then(snapshot => {
    snapshot.forEach(doc => {
      const users = doc.data().users;
      const updatedUsers = users.map(user => {
        if (user.userId === uid) {
          return {uid: uid, username: newData.username, avatarUrl: newData.avatarUrl, displayName: newData.displayName};
        } else {
          return user;
        }
      });
      batch.update(doc.ref, {users: updatedUsers});
    });
  }).catch(err => {
    console.error('Error updating user info in conversation collection', err);
  });

  // Update user info in posts collection
  const postsRef = admin.firestore().collection('posts').where('userId', '==', uid);
  postsRef.get().then(snapshot => {
    snapshot.forEach(doc => {
      batch.update(doc.ref, {'username': newData.username, 'avatarUrl': newData.avatarUrl});
    });
  }).catch(err => {
    console.error('Error updating user info in posts collection', err);
  });

  return batch.commit().then(() => {
    console.log('Updated user info in all collections');
  }).catch(err => {
    console.error('Error updating user info', err);
  });
});


exports.updateUserPostCount = functions.firestore
   .document('posts/{postId}')
   .onUpdate(async (change, context) => {
     const postId = context.params.postId;
     const postBefore = change.before.data();
     const postAfter = change.after.data();

     const userId = postBefore.userId;
     const userRef = admin.firestore().collection('users').doc(userId);

     const user = await userRef.get();
     if (!user.exists) {
       return null;
     }

     const userData = user.data();
     const postCount = userData.postsCount;
     const postIds = userData.postIds || [];

     // Check if isArchived or isDeleted field changed
     const isArchivedBefore = postBefore.isArchived || false;
     const isArchivedAfter = postAfter.isArchived || false;
     const isDeletedBefore = postBefore.isDeleted || false;
     const isDeletedAfter = postAfter.isDeleted || false;

     if (isArchivedBefore !== isArchivedAfter) {
       const newPostCount = !isArchivedAfter ? postCount + 1 : postCount - 1;
       const newPostIds = !isArchivedAfter ? [...postIds, postId] : postIds.filter((id) => id !== postId);
       await userRef.update({ postsCount: newPostIds.length, postIds: newPostIds });
     }

     if (isDeletedBefore !== isDeletedAfter) {
       const newPostCount = isDeletedAfter ? postCount - 1 : postCount + 1;
       const newPostIds = isDeletedAfter ? postIds.filter((id) => id !== postId) : [...postIds, postId];
       await userRef.update({ postsCount: newPostIds.length, postIds: newPostIds });
     }

     return null;
   });



    

