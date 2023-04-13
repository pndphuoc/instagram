class Message {
  final String id;
  final String senderId;
  final String type;
  final DateTime timestamp;
  final String content;

  Message({
    required this.id,
    required this.senderId,
    required this.type,
    required this.timestamp,
    required this.content,
  });

  Message.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        senderId = json['sender'],
        type = json['type'],
        timestamp = json['timestamp'].toDate(),
        content = json['content'];

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'senderId': senderId,
    'sentAt': timestamp.toIso8601String(),
    'content': content,
  };

/*  static MessageContent _getContentFromJson(Map<String, dynamic> json) {
    String type = json['type'];
    switch (type) {
      case 'text':
        return TextMessageContent.fromJson(json);
      case 'image':
        return ImagesMessageContent.fromJson(json);
      case 'video':
        return VideosMessageContent.fromJson(json);
      default:
        throw Exception('Invalid message content type: $type');
    }
  }*/
}
