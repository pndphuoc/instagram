import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/interface/comment_interface.dart';
import 'package:instagram/models/comment.dart';

class CommentServices implements ICommentService {
  final CollectionReference _commentsCollection =
      FirebaseFirestore.instance.collection('commentList');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> addComment(String commentListId, Comment comment) async {
    DocumentReference cmtListRef = _commentsCollection.doc(commentListId);
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
      likeRef.set({"likedBy": [], "id": likeRef.id});

      comment.likedListId = likeRef.id;

      transaction.set(cmtRef, comment.toJson());
    });

    return uid ?? "";
  }

  @override
  Future<void> deleteComment(String commentListId, String commentId) {
    // TODO: implement deleteComment
    throw UnimplementedError();
  }

  @override
  Future<Comment> getComment(String commentListId, String uid) {
    // TODO: implement getComment
    throw UnimplementedError();
  }

  @override
  Future<List<Comment>> getComments({
    required String commentListId,
    int page = 0,
    int pageSize = 10,
  }) async {
    final int startIndex = page * pageSize;

    QuerySnapshot snapshot = await _commentsCollection
        .doc(commentListId)
        .collection("comments")
        .orderBy("commentCount", descending: true)
        .orderBy("likeCount", descending: true)
        .limit(pageSize)
        .startAt([startIndex]).get();
    return snapshot.docs
        .map((doc) => Comment.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateComment(String commentListId, Comment comment) {
    // TODO: implement updateComment
    throw UnimplementedError();
  }
}
