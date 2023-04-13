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

class ImageMessageContent extends MessageContent {
  final String imageUrl;

  ImageMessageContent(this.imageUrl);

  @override
  String get type => 'image';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'imageUrl': imageUrl};

  factory ImageMessageContent.fromJson(Map<String, dynamic> json) {
    return ImageMessageContent(json['imageUrl']);
  }
}

class VideoMessageContent extends MessageContent {
  final String videoUrl;

  VideoMessageContent(this.videoUrl);

  @override
  String get type => 'video';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'videoUrl': videoUrl};

  factory VideoMessageContent.fromJson(Map<String, dynamic> json) {
    return VideoMessageContent(json['videoUrl']);
  }
}

class MultipleImagesMessageContent extends MessageContent {
  final List<String> imageUrls;

  MultipleImagesMessageContent(this.imageUrls);

  @override
  String get type => 'multiple_images';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'imageUrls': imageUrls};

  factory MultipleImagesMessageContent.fromJson(Map<String, dynamic> json) {
    return MultipleImagesMessageContent(json['imageUrls'].cast<String>());
  }
}

class MultipleVideosMessageContent extends MessageContent {
  final List<String> videoUrls;

  MultipleVideosMessageContent(this.videoUrls);

  @override
  String get type => 'multiple_videos';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'videoUrls': videoUrls};

  factory MultipleVideosMessageContent.fromJson(Map<String, dynamic> json) {
    return MultipleVideosMessageContent(json['videoUrls'].cast<String>());
  }
}
