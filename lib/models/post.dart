import 'package:instagram/models/media.dart';

class Post {
  String uid;
  String caption;
  String commentListId;
  int commentCount;
  String likedListId;
  int likeCount;
  String viewedListId;
  List<Media> medias;
  String userId;
  String username;
  String avatarUrl;
  DateTime createAt;
  DateTime updateAt;
  bool isDeleted;
  bool isLiked = false;
  Post({
    required this.uid,
    required this.caption,
    required this.commentListId,
    required this.commentCount,
    required this.likedListId,
    required this.likeCount,
    required this.viewedListId,
    required this.medias,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.createAt,
    required this.updateAt,
    required this.isDeleted,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      uid: json['uid'] as String,
      caption: json['caption'] as String,
      commentListId: json['commentListId'] as String,
      commentCount: json['commentCount'] as int,
      likedListId: json['likedListId'] as String,
      likeCount: json['likeCount'] as int,
      viewedListId: json['viewedListId'] as String,
      medias: (json['mediaUrls'] as List<dynamic>)
          .map((url) => Media.fromJson(url))
          .toList(),
      userId: json['userId'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String,
      createAt: json['createAt'].toDate(),
      updateAt: json['updateAt'].toDate(),
      isDeleted: json['isDeleted'] as bool,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'caption': caption,
      'commentListId': commentListId,
      'commentCount': commentCount,
      'likedListId': likedListId,
      'likeCount': likeCount,
      'viewedListId': viewedListId,
      'mediaUrls': medias.map((mediaUrl) => mediaUrl.toJson()).toList(),
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'createAt': createAt,
      'updateAt': updateAt,
      'isDeleted': isDeleted,
    };
  }
}
