class Notification {
  String? id;
  final String userId;
  final String title;
  final String message;
  final String? postId;
  String interactiveUserAvatarUrl;
  String interactiveUserId;
  String interactiveUsername;
  String? firstImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isRead;
  final NotificationType type;

  Notification({this.id, required this.interactiveUserId, required this.userId, required this.title, required this.message, this.postId, required this.interactiveUserAvatarUrl, required this.interactiveUsername, this.firstImage, required this.createdAt, required this.updatedAt, required this.isRead, required this.type});

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? "",
      interactiveUserId: json['interactiveUserId'],
      userId: json['userId'],
      title: json['title'],
      message: json['message'],
      postId: json['postId'],
      interactiveUserAvatarUrl: json['interactiveUserAvatarUrl'],
      interactiveUsername: json['interactiveUsername'],
      firstImage: json['firstImage'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isRead: json['isRead'],
      type: NotificationType.values[json['type']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? "",
      'userId': userId,
      'title': title,
      'message': message,
      'postId': postId,
      'interactiveUserId': interactiveUserId,
      'interactiveUserAvatarUrl': interactiveUserAvatarUrl,
      'interactiveUsername': interactiveUsername,
      'firstImage': firstImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isRead': false,
      'type': type.index,
    };
  }

}

enum NotificationType {
  like,
  comment,
  tag,
  follow
}

class NotificationMessages {
  static const Map<String, Map<String, String>> _messages = {
    'like': {
      'title': 'You just got a like',
      'message': '%s just liked your post',
    },
    'comment': {
      'title': 'New comment on your post',
      'message': '%s just commented on your post',
    },
    'tag': {
      'title': 'You have just been tagged in a comment',
      'message': '%s just tagged you in a comment',
    },
    'follow': {
      'title': 'You have a new follower',
      'message': '%s started following you'
    }
  };

  static String getTitle(String type) {
    return _messages[type]!['title'] ?? '';
  }

  static String getMessage(String type, String userName) {
    return _messages[type]!['message']?.replaceAll('%s', userName) ?? '';
  }
}