import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram/interface/post_interface.dart';
import 'package:instagram/models/comment.dart';

import '../models/post.dart';

class PostService implements IPostServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');

  final CollectionReference _likesCollection =
      FirebaseFirestore.instance.collection('likes');

  final CollectionReference _commentListCollection =
      FirebaseFirestore.instance.collection("commentList");

  final CollectionReference _viewedListCollection =
  FirebaseFirestore.instance.collection("viewedList");

  @override
  Future<List<Post>> getPosts() async {
    QuerySnapshot snapshot = await _postsCollection.get();
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
    likeRef.set({"likedBy": [], "postId": uid});
    post.likedListId = likeRef.id;

    DocumentReference commentListRef = _commentListCollection.doc();
    commentListRef.set({"uid": commentListRef.id, "postId": uid});
    post.commentListId = commentListRef.id;

    DocumentReference viewedListRef = _viewedListCollection.doc();
    viewedListRef.set({"uid": viewedListRef.id, "postId": uid});
    post.viewedListId = viewedListRef.id;

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
  Future<void> addComment(String postId) async {
    DocumentReference postRef = _firestore.collection('posts').doc(postId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);

      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }

      transaction.update(postRef, {
        'commentCount': FieldValue.increment(1),
      });
    });
  }

  @override
  Future<void> deleteComment(String postId) async {
    DocumentReference postRef = _firestore.collection('posts').doc(postId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);

      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }

      transaction.update(postRef, {
        'commentCount': FieldValue.increment(-1),
      });
    });
  }
}
