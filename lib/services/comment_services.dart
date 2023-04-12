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

      if (!commentListSnapshot.exists) {
        throw Exception;
      }

      DocumentReference cmtRef = cmtListRef.collection('comments').doc();
      uid = cmtRef.id;

      comment.uid = uid!;

      DocumentReference likeRef =
          FirebaseFirestore.instance.collection('likes').doc();
      likeRef.set({"likedBy": [], "commentId": uid, "commentListId": commentListId});

      comment.likedListId = likeRef.id;

      transaction.set(cmtRef, comment.toJson());
    });

    return uid ?? "";
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
}
