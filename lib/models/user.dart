class User {
  String uid;
  String username;
  String displayName;
  String email;
  String bio;
  String followerListId;
  int followerCount;
  String followingListId;
  int followingCount;
  List<String> savedPostIds;
  String blockedListId;
  String avatarUrl;
  List<String> postIds;
  DateTime createdAt;

  User({
    required this.uid,
    required this.username,
    required this.displayName,
    required this.email,
    required this.bio,
    required this.followerListId,
    required this.followerCount,
    required this.followingListId,
    required this.followingCount,
    required this.savedPostIds,
    required this.blockedListId,
    required this.avatarUrl,
    required this.postIds,
    required this.createdAt
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    uid: json['uid'],
    username: json['username'],
    displayName: json['displayName'] ?? "",
    email: json['email'],
    bio: json['bio'] ?? "",
    followerListId: json['followerListId'] as String,
    followerCount: json['followerCount'] as int,
    followingListId: json['followingListId'] as String,
    followingCount: json['followingCount'] as int,
    savedPostIds:
    List<String>.from(json['savedPostIds'] as List<dynamic>),
    blockedListId: json['blockedListId'],
    avatarUrl: json['avatarUrl'] as String,
    postIds: List<String>.from(json['postIds'] as List<dynamic>).reversed.toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'username': username,
    'displayName': displayName,
    'email': email,
    'bio': bio,
    'followerListId': followerListId,
    'followerCount': followerCount,
    'followingListId': followingListId,
    'followingCount': followingCount,
    'savedPostIds': savedPostIds,
    'blockedListId': blockedListId,
    'avatarUrl': avatarUrl,
    'postIds': postIds,
    'createdAt': createdAt.toIso8601String(),
  };
}
