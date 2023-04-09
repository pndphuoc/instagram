class Comment {
  String uid;
  final String authorId;
  String username;
  String avatarUrl;
  String content;
  String likedListId;
  final DateTime createdAt;
  DateTime updatedAt;

  Comment({
    required this.uid,
    required this.authorId,
    required this.username,
    required this.avatarUrl,
    required this.content,
    required this.likedListId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> data) {
    return Comment(
      uid: data['uid'],
      authorId: data['authorId'],
      username: data['username'],
      avatarUrl: data['avatarUrl'],
      content: data['content'],
      likedListId: data['likedListId'],
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'authorId': authorId,
      'username': username,
      'avatarUrl': avatarUrl,
      'content': content,
      'likedListId': likedListId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
