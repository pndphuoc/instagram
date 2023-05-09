class UserSummaryInformation {
  String userId;
  String username;
  String avatarUrl;
  String displayName;
  String? isFollowing;

  UserSummaryInformation({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.displayName,
    this.isFollowing,
  });

  factory UserSummaryInformation.fromJson(Map<String, dynamic> json) {
    return UserSummaryInformation(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      displayName: json['displayName'] ?? '',
    );
  }

  factory UserSummaryInformation.fromJsonElastic(Map<String, dynamic> json) {
    return UserSummaryInformation(
      username: json['username']['raw'],
      userId: json['id']['raw'],
      displayName: json['displayname']['raw'],
      avatarUrl: json['avatarurl']['raw'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatarUrl': avatarUrl,
      'displayName': displayName,
      'userId': userId,
      'username': username,
    };
  }
}