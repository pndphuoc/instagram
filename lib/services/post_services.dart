import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram/interface/post_interface.dart';
import 'package:instagram/models/comment.dart';

import '../models/post.dart';

class PostService implements IPostServices {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');
  final CollectionReference _likesCollection =
      FirebaseFirestore.instance.collection('likes');

  @override
  Future<List<Post>> getPosts() async {
    QuerySnapshot snapshot = await _postsCollection.get();
    print("aaa ${snapshot.docs.length}");
    return snapshot.docs
        .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> addPost(Post post) async {
    DocumentReference docRef = _postsCollection.doc();
    String uid = docRef.id;
    post.uid = uid;

    DocumentReference likeRef = _likesCollection.doc();
    likeRef.set({"likedBy": [], "id": likeRef.id});
    post.likedListId = likeRef.id;

    await docRef.set(post.toJson());
    return uid;
  }

  @override
  Future<void> updatePost(Post post) async {
    /*await _postsCollection.doc(post.postId).update({
      'likesCount': post.likesCount,
      'commentsCount': post.commentsCount,
      'imageUrls': post.imageUrls,
    });*/
  }

  @override
  Future<void> deletePost(String postId) async {
    await _postsCollection.doc(postId).delete();
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    await _postsCollection.doc(postId).update({
      'likeCount': FieldValue.increment(1),
    });
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    await _postsCollection.doc(postId).update({
      'likeCount': FieldValue.increment(-1),
    });
  }

  @override
  Future<Post> getPost(String postId) async {
    DocumentSnapshot snapshot = await _postsCollection.doc(postId).get();
    if (snapshot.exists) {
      Post post = Post.fromJson(snapshot.data() as Map<String, dynamic>);
      return post;
    } else {
      throw Exception('Post not found');
    }
  }

  @override
  Future<String> addComment(String postId, Comment cmt) async {
    DocumentReference postRef = _firestore.collection('posts').doc(postId);
    DocumentReference commentRef = postRef.collection('comments').doc();

    String uid = commentRef.id;

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);

      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }

      transaction.set(commentRef, cmt.toSnap());

      transaction.update(postRef, {
        'commentCount': FieldValue.increment(1),
      });
    });
    return uid;
  }

  @override
  Future<void> getComments({int page = 0, int size = 20}) {
    // TODO: implement getComments
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteComment(String postId, String commentId) {
    // TODO: implement deleteComment
    throw UnimplementedError();
  }

  @override
  Future<bool> updateComment(String postId, Comment cmt) {
    // TODO: implement updateComment
    throw UnimplementedError();
  }
}
