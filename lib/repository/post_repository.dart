import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/post.dart';

class PostRepository{
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');

  static final CollectionReference _likesCollection =
      FirebaseFirestore.instance.collection('likes');

  static final CollectionReference _commentListCollection =
      FirebaseFirestore.instance.collection("commentList");

  static final CollectionReference _viewedListCollection =
      FirebaseFirestore.instance.collection("viewedList");

  static Future<List<Post>> getPosts(List<String> followingIds) async {
    QuerySnapshot snapshot = await _postsCollection
        .where('userId', whereIn: followingIds)
        .where('isDeleted', isEqualTo: false)
        .where('isArchived', isEqualTo: false)
        .where('isContestPost', isEqualTo: false)
        .orderBy('createAt', descending: true)
        .orderBy('likeCount', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Post>> getDiscoverPosts(List<String> followingIds) async {
    followingIds.add(FirebaseAuth.instance.currentUser!.uid);
    QuerySnapshot snapshot = await _postsCollection
        .where('userId', whereNotIn: followingIds)
        .orderBy('userId', descending: true)
        .get();
    List<Post> posts = snapshot.docs
        .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    return posts;
  }

  static Future<String> addPost(Post post) async {
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

  static Future<String> addContestPost(ContestPost post) async {
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

  static Future<String> addAIPost(AIPost post) async {
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

  static Future<void> updateCaption({required String postId, required String caption}) async {
    await _postsCollection.doc(postId).update({
      'caption': caption
    });
  }

  static Future<void> deletePost(String postId) async {
    await _postsCollection.doc(postId).update({'isDeleted': true});
  }

  static Future<Post> getPost(String postId) async {
    DocumentSnapshot snapshot = await _postsCollection.doc(postId).get();
    if (snapshot.exists) {
      Post post = Post.fromJson(snapshot.data() as Map<String, dynamic>);
      return post;
    } else {
      throw Exception('Post not found');
    }
  }

  static Future<void> addComment(String postId) async {
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

  static Future<void> deleteComment(String postId) async {
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

  static Future<void> updateOwnerInformation({required String userId, required String avatarUrl, required String username}) async {
    try {
      final posts = await _postsCollection.where('userId', isEqualTo: userId).get();

      final batch = FirebaseFirestore.instance.batch();
      for (final post in posts.docs) {
        batch.update(post.reference, {
          'avatarUrl': avatarUrl,
          'username': username,
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Post>> getArchivedPosts({required String userId}) async {
    try {
      QuerySnapshot snapshot = await _postsCollection
          .where('userId', isEqualTo: userId)
          .where('isArchived', isEqualTo: true)
          .orderBy('createAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> toggleArchivePost({required String postId, required bool isArchive}) async {
    await _postsCollection.doc(postId).update({'isArchived': isArchive});
  }

}
