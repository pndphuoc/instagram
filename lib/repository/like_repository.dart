import 'package:cloud_firestore/cloud_firestore.dart';

class LikeRepository {
  static final CollectionReference _likesCollection =
      FirebaseFirestore.instance.collection('likes');

  static Future<bool> isLiked(String likeListId, String userId) async {
    DocumentSnapshot likeDoc = await _likesCollection.doc(likeListId).get();

    Map<String, dynamic> data = likeDoc.data() as Map<String, dynamic>;
    List<String> likedByList = List<String>.from(data['likedBy']);

    return likedByList.contains(userId);
  }

  static Future<void> like(String likeListId, String userId) async {
    DocumentSnapshot likeDoc = await _likesCollection.doc(likeListId).get();
    if (likeDoc.exists) {
      await _likesCollection.doc(likeListId).update({
        'likedBy': FieldValue.arrayUnion([userId])
      });
    }
  }

  static Future<void> unlike(String likesListId, String userId) async {
    DocumentSnapshot likeDoc = await _likesCollection.doc(likesListId).get();
    if (likeDoc.exists) {
      await _likesCollection.doc(likesListId).update({
        'likedBy': FieldValue.arrayRemove([userId])
      });
    }
  }

  static Future<List<String>> getLikedByList(String postId) async {
    DocumentSnapshot doc = await _likesCollection.doc(postId).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<String> likedByList = List<String>.from(data['likedBy']);
      return likedByList;
    } else {
      return [];
    }
  }
}
