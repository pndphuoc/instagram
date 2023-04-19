class UserSummaryInformation {
  String userId;
  String username;
  String avatarUrl;
  String displayName;

  UserSummaryInformation({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.displayName,
  });

  factory UserSummaryInformation.fromJson(Map<String, dynamic> json) {
    return UserSummaryInformation(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      displayName: json['displayName'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'displayName': displayName,
    };
  }
}