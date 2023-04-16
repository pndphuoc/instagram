class ChatUser {
  String userId;
  String username;
  String avatarUrl;
  String displayName;
  bool isOnline;

  ChatUser({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.displayName,
    required this.isOnline
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      displayName: json['displayName'] ?? '',
      isOnline: json['isOnline']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'displayName': displayName,
      'isOnline': isOnline
    };
  }
}