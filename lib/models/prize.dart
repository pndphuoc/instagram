class Prize {
  final String? uid;
  final String name;
  final String award;
  late String? winnerId;

  Prize({this.uid, required this.name, required this.award, this.winnerId});

  factory Prize.fromJson(Map<String, dynamic> json) {
    return Prize(
      uid: json['uid'],
      name: json['name'],
      award: json['award'],
      winnerId: json['winnerId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'award': award,
    'winnerId': winnerId,
  };
}
