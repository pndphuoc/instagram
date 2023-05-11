import 'dart:convert';

import 'package:instagram/models/prize.dart';

class Contest {
  final String? uid;
  final String name;
  final String description;
  final String? topic;
  final String? rules;
  final DateTime startTime;
  final DateTime endTime;
  final String banner;
  final List<Prize> prizes;
  final String ownerId;
  final String status;

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
        required this.status
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
        status: json['status']
    );
  }

  Map<String, dynamic> toJson() => {
    'contestId': uid,
    'name': name,
    'description': description,
    'topic': topic,
    'rules': rules,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'banner': banner,
    'prizes': prizes.map((e) => e.toJson()).toList(),
    'ownerId': ownerId,
    'status': status
  };
}
