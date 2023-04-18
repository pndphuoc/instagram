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

//Tự động tăng, giảm số lượng following của user thực hiện follow/unfollow
exports.updateFollowingCount = functions.firestore.document('followingList/{followingListId}')
    .onWrite(async (change, context) => {
        const userId = change.after.data().userId;
        const followingIds = change.after.data().followingIds;

        const userRef = db.collection('users').doc(userId);

        await db.runTransaction(async (transaction) => {
            const followingCount = followingIds.length;

            transaction.update(userRef, { followingCount });
        })
    
    });

//Tự động tăng/giảm số lượng follower của user được follow/unfollw
exports.updateFollowerCount = functions.firestore.document('followerList/{followerListId}')
    .onWrite(async (change, context) => {
        const userId = change.after.data().userId;
        const followerIds = change.after.data().followerIds;

        const userRef = db.collection('users').doc(userId);

        await db.runTransaction(async (transaction) => {
            const followerCount = followerIds.length;

            transaction.update(userRef, { followerCount });
        })
    
    });
    

