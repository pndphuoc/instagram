class SearchResult {
  final String username;
  final String uid;
  final String photoUrl;

  SearchResult({
    required this.username,
    required this.uid,
    this.photoUrl = "",
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      username: json['username'],
      uid: json['uid'],
      photoUrl: json['photoUrl'],
    );
  }
}
