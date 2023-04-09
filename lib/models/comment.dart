import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String username;
  final String avatarUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> likedBy;
  final int likeCount;

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.username,
    required this.avatarUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.likedBy,
    required this.likeCount,
  });

  factory Comment.fromSnap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      postId: data['postId'],
      authorId: data['authorId'],
      username: data['username'],
      avatarUrl: data['avatarUrl'],
      content: data['content'],
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      likeCount: data['likeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toSnap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'username': username,
      'avatarUrl': avatarUrl,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'likedBy': likedBy,
      'likeCount': likeCount,
    };
  }
}
