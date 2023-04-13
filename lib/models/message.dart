import 'message_content.dart';

class Message {
  final String id;
  final String senderId;
  final String conversationId;
  final DateTime timestamp;
  final MessageContent content;

  Message({
    required this.id,
    required this.senderId,
    required this.conversationId,
    required this.timestamp,
    required this.content,
  });

  Message.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        senderId = json['sender'],
        conversationId = json['receiver'],
        timestamp = json['timestamp'].toDate(),
        content = _getContentFromJson(json['content']);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'senderId': senderId,
    'roomId': conversationId,
    'sentAt': timestamp.toIso8601String(),
    'content': content.toJson(),
  };

  static MessageContent _getContentFromJson(Map<String, dynamic> json) {
    String type = json['type'];
    switch (type) {
      case 'text':
        return TextMessageContent.fromJson(json);
      case 'image':
        return ImageMessageContent.fromJson(json);
      case 'video':
        return VideoMessageContent.fromJson(json);
      case 'multiple_images':
        return MultipleImagesMessageContent.fromJson(json);
      case 'multiple_videos':
        return MultipleVideosMessageContent.fromJson(json);
      default:
        throw Exception('Invalid message content type: $type');
    }
  }
}
