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
  bool isArchived;
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
    required this.isArchived,
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
      isArchived: json['isArchived'] as bool,
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
      'isArchived': isArchived,
    };
  }
}

class ContestPost extends Post {
  String contestId;
  bool isContestPost;
  ContestPost({
    required this.contestId,
    required String uid,
    required String caption,
    required String commentListId,
    required int commentCount,
    required String likedListId,
    required int likeCount,
    required String viewedListId,
    required List<Media> medias,
    required String userId,
    required String username,
    required String avatarUrl,
    required DateTime createAt,
    required DateTime updateAt,
    required bool isDeleted,
    required bool isArchived,
    this.isContestPost = true,
  }) : super(
    uid: uid,
    caption: caption,
    commentListId: commentListId,
    commentCount: commentCount,
    likedListId: likedListId,
    likeCount: likeCount,
    viewedListId: viewedListId,
    medias: medias,
    userId: userId,
    username: username,
    avatarUrl: avatarUrl,
    createAt: createAt,
    updateAt: updateAt,
    isDeleted: isDeleted,
    isArchived: isArchived,
  );

  factory ContestPost.fromJson(Map<String, dynamic> json) {
    return ContestPost(
      contestId: json['contestId'] ?? '',
      uid: json['uid'] ?? '',
      caption: json['caption'] ?? '',
      commentListId: json['commentListId'] ?? '',
      commentCount: json['commentCount'] ?? 0,
      likedListId: json['likedListId'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      viewedListId: json['viewedListId'] ?? '',
      medias: (json['medias'] as List<dynamic>)
          .map((e) => Media.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      createAt: DateTime.parse(json['createAt'] ?? ''),
      updateAt: DateTime.parse(json['updateAt'] ?? ''),
      isDeleted: json['isDeleted'] ?? false,
      isArchived: json['isArchived'] ?? false,
      isContestPost: json['isContestPost'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['contestId'] = contestId;
    data['isContestPost'] = isContestPost;
    return data;
  }
}

