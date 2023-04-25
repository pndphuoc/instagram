import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/interface/comment_interface.dart';
import 'package:instagram/models/comment.dart';

class CommentServices implements ICommentService {
  final CollectionReference _commentListCollection =
      FirebaseFirestore.instance.collection('commentList');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> addComment(String commentListId, Comment comment) async {
    DocumentReference cmtListRef = _commentListCollection.doc(commentListId);
    String? uid;

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot commentListSnapshot = await transaction.get(cmtListRef);

/*      if (!commentListSnapshot.exists) {
        throw Exception;
      }*/

      DocumentReference cmtRef = cmtListRef.collection('comments').doc();
      uid = cmtRef.id;

      comment.uid = uid!;

      DocumentReference likeRef =
          FirebaseFirestore.instance.collection('likes').doc();
      likeRef.set(
          {"likedBy": [], "commentId": uid, "commentListId": commentListId});

      comment.likedListId = likeRef.id;

      transaction.set(cmtRef, comment.toJson());
    });

    return uid ?? "";
  }

  @override
  Future<String> addReplyComment(
      String commentListId, String mainCommentId, Comment replyComment) async {
    try {
      CollectionReference replyCmtRef = _commentListCollection
          .doc(commentListId)
          .collection('comments')
          .doc(mainCommentId)
          .collection('replyComments');

      DocumentReference cmtRef = replyCmtRef.doc();
      String uid = cmtRef.id;

      DocumentReference likeRef =
          FirebaseFirestore.instance.collection('likes').doc();
      await likeRef.set({
        "likedBy": [],
        "replyCommentId": uid,
        "commentId": mainCommentId,
        "commentListId": commentListId
      });

      replyComment.uid = uid;
      replyComment.likedListId = likeRef.id;

      await cmtRef.set(replyComment.toJson());

      await updateReplyCount(commentListId, mainCommentId, true);

      return uid;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteComment(String commentListId, String commentId) async {
    try {
      await _commentListCollection
          .doc(commentListId)
          .collection("comments")
          .doc(commentId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Comment> getComment(String commentListId, String uid) async {
    DocumentSnapshot snapshot = await _commentListCollection
        .doc(commentListId)
        .collection("comments")
        .doc(uid)
        .get();
    return Comment.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  Future<Comment> getReplyComment(
      String commentListId, String commentId, String replyCommentId) async {
    DocumentSnapshot snapshot = await _commentListCollection
        .doc(commentListId)
        .collection("comments")
        .doc(commentId)
        .collection("replyComments")
        .doc(replyCommentId)
        .get();
    return Comment.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  Future<List<DocumentSnapshot>> getComments({
    required String commentListId,
    int pageSize = 10,
  }) async {
    QuerySnapshot snapshot = await _commentListCollection
        .doc(commentListId)
        .collection("comments")
        .orderBy("likeCount", descending: true)
        .orderBy("createdAt", descending: false)
        .limit(pageSize)
        .get();
    return snapshot.docs;
  }

  @override
  Future<List<DocumentSnapshot<Object?>>> getReplyComments({
    required String commentListId,
    required String commentId,
    int pageSize = 5,
    DocumentSnapshot<Object?>? lastDocument,
  }) async {
    Query query = _commentListCollection
        .doc(commentListId)
        .collection('comments')
        .doc(commentId)
        .collection('replyComments')
        .orderBy('createdAt', descending: false)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    QuerySnapshot snapshot = await query.get();
    return snapshot.docs;
  }


  @override
  Future<List<DocumentSnapshot>> getMoreComments(
      {required String commentListId,
      required DocumentSnapshot<Object?> lastDocument,
      int pageSize = 10}) async {
    QuerySnapshot snapshot = await _commentListCollection
        .doc(commentListId)
        .collection("comments")
        .orderBy("likeCount", descending: true)
        .orderBy("createdAt", descending: false)
        .startAfterDocument(lastDocument)
        .limit(pageSize)
        .get();
    return snapshot.docs;
  }

  @override
  Future<void> updateComment(String commentListId, Comment comment) {
    // TODO: implement updateComment
    throw UnimplementedError();
  }

  @override
  Future<void> likeComment(String commentListId, String commentId) async {
    try {
      await _commentListCollection
          .doc(commentListId)
          .collection('comments')
          .doc(commentId)
          .update({'likeCount': FieldValue.increment(1)});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unlikeComment(String commentListId, String commentId) async {
    try {
      await _commentListCollection
          .doc(commentListId)
          .collection('comments')
          .doc(commentId)
          .update({'likeCount': FieldValue.increment(-1)});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateReplyCount(
      String commentListId, String commentId, bool isIncrease) async {
    try {
      print("aaaaaaaaaaa $commentListId");
      print("bbbbbbbbbbb $commentId");
      await _commentListCollection
          .doc(commentListId)
          .collection('comments')
          .doc(commentId)
          .update({
        'replyCount':
            isIncrease ? FieldValue.increment(1) : FieldValue.increment(-1)
      });
    } catch (e) {
      rethrow;
    }
  }
}
