import 'package:instagram/models/user_summary_information.dart';

class Conversation {
  String uid;
  String lastMessageContent;
  DateTime lastMessageTime;
  List<UserSummaryInformation> users;
  bool isSeen;

  Conversation({
    required this.uid,
    required this.lastMessageContent,
    required this.lastMessageTime,
    required this.users,
    required this.isSeen
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    List<dynamic> usersJson = json['users'] ?? [];
    List<UserSummaryInformation> users = usersJson.map((userJson) => UserSummaryInformation.fromJson(userJson)).toList();
    return Conversation(
      uid: json['uid'] ?? '',
      lastMessageContent: json['lastMessageContent'] ?? '',
      lastMessageTime: json['lastMessageTime'].toDate() ?? '',
      users: users,
      isSeen: json['isSeen'] ?? false
    );
  }

  Map<String, dynamic> toJson() {
    List<dynamic> usersJson = users.map((user) => user.toJson()).toList();

    return {
      'uid': uid,
      'lastMessageContent': lastMessageContent,
      'lastMessageTime': lastMessageTime,
      'users': usersJson,
    };
  }
}





