abstract class MessageContent {
  String get type;
  Map<String, dynamic> toJson();
}

class TextMessageContent extends MessageContent {
  final String text;

  TextMessageContent({required this.text});

  @override
  String get type => 'text';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};

  factory TextMessageContent.fromJson(Map<String, dynamic> json) {
    return TextMessageContent(text: json['text']);
  }
}

class ImagesMessageContent extends MessageContent {
  final List<String> imageUrls;

  ImagesMessageContent(this.imageUrls);

  @override
  String get type => 'image';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'imageUrls': imageUrls};

  factory ImagesMessageContent.fromJson(Map<String, dynamic> json) {
    return ImagesMessageContent(json['imageUrls']);
  }
}

class VideosMessageContent extends MessageContent {
  final String videoUrls;

  VideosMessageContent(this.videoUrls);

  @override
  String get type => 'video';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'videoUrls': videoUrls};

  factory VideosMessageContent.fromJson(Map<String, dynamic> json) {
    return VideosMessageContent(json['videoUrls']);
  }
}

