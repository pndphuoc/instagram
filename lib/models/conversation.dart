import 'package:instagram/models/chat_user.dart';

class Conversation {
  String uid;
  String lastMessageContent;
  DateTime lastMessageTime;
  List<ChatUser> users;

  Conversation({
    required this.uid,
    required this.lastMessageContent,
    required this.lastMessageTime,
    required this.users,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    List<dynamic> usersJson = json['users'] ?? [];
    List<ChatUser> users = usersJson.map((userJson) => ChatUser.fromJson(userJson)).toList();

    return Conversation(
      uid: json['uid'] ?? '',
      lastMessageContent: json['lastMessageContent'] ?? '',
      lastMessageTime: json['lastMessageTime'].toDate(),
      users: users,
    );
  }

  Map<String, dynamic> toJson() {
    List<dynamic> usersJson = users.map((user) => user.toJson()).toList();

    return {
      'uid': uid,
      'lastMessageContent': lastMessageContent,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'users': usersJson,
    };
  }
}




