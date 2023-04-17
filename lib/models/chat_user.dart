class ChatUser {
  String userId;
  String username;
  String avatarUrl;
  String displayName;

  ChatUser({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.displayName,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
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