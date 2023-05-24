import 'dart:convert';
import 'package:instagram/models/prize.dart';

class Contest {
  late String? uid;
  final String name;
  final String description;
  final String? topic;
  final String? rules;
  final DateTime startTime;
  final DateTime endTime;
  final String banner;
  List<Prize> prizes;
  final String ownerId;
  final String status;
  final int awardMethod;
  final DateTime createAt;
  Contest(
      {this.uid,
      required this.name,
      required this.description,
      this.topic,
      this.rules,
      required this.startTime,
      required this.endTime,
      required this.banner,
      required this.prizes,
      required this.ownerId,
        required this.status,
        required this.awardMethod,
        required this.createAt
      });

  factory Contest.fromJson(Map<String, dynamic> json) {
    final prizeList = json['prizes'] as List<dynamic>;
    final List<Prize> prizes = prizeList.map((e) => Prize.fromJson(e as Map<String, dynamic>)).toList();
    return Contest(
        uid: json['uid'],
        name: json['name'],
        description: json['description'],
        topic: json['topic'],
        rules: json['rules'],
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        banner: json['banner'],
        prizes: prizes,
        ownerId: json['ownerId'],
        awardMethod: json['awardMethod'],
        createAt: DateTime.parse(json['createAt']),
        status: getContestStatus(DateTime.parse(json['startTime']), DateTime.parse(json['endTime'])));
  }

  static String getContestStatus(DateTime startTIme, DateTime endTime) {
    if (DateTime.now().isBefore(startTIme)) {
      return ContestStatus.upcoming['status'];
    } else if (endTime.isBefore(DateTime.now())) {
      return ContestStatus.expired['status'];
    } else {
      return ContestStatus.inProgress['status'];
    }
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'description': description,
        'topic': topic,
        'rules': rules,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'banner': banner,
        'prizes': prizes.map((e) => e.toJson()).toList(),
        'ownerId': ownerId,
        'status': status,
        'awardMethod': awardMethod,
        'createAt': createAt.toIso8601String()
      };
}

class ContestStatus {
  static const Map<String, dynamic> inProgress = {
    'name': 'In progress',
    'status': "progressing"
  };

  static const Map<String, dynamic> upcoming = {
    'name': 'Coming soon',
    'status': 'upcoming'
  };

  static const Map<String, dynamic> expired = {
    'name': 'Expired',
    'status': 'expired'
  };
}

class AwardMethod {
  static const Map<String, dynamic> interaction = {
    'name': 'Interaction',
    'code': 1
  };
  static const Map<String, dynamic> selfDetermined = {
    'name': 'Self-determined',
    'code': 2
  };
}
