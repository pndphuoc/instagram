import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/contest.dart';

import '../models/post.dart';


class ContestRepository {
  static final CollectionReference _contestRef = FirebaseFirestore.instance.collection('contest');
  static final CollectionReference _postRef = FirebaseFirestore.instance.collection('posts');
  static Future<void> addContest(Contest contest) async {
    try {
      await _contestRef.add(contest.toJson());
    } catch (e) {
      rethrow;
    }
  }

  static Future<Contest> getContestDetail(String contestId) async {
    try {
      final snap = await _contestRef.doc(contestId).get();
      return Contest.fromJson(snap.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Post>> getTop10PostOfContest(String contestId) async {
    try {
      final snap = await _postRef.where('contestId', isEqualTo: contestId).orderBy('likeCount', descending: true).limit(10).get();
      return snap.docs.map((e) => Post.fromJson(e.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<List<Contest>> getProgressingContest({int page = 0, int pageSize = 10}) async {
    try {
      final snap = await _contestRef.where('status', isEqualTo: ContestStatus.inProgress['status']).orderBy('createAt').get();
      return snap.docs.map((e) => Contest.fromJson(e.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Contest>> getUpcomingContest({int page = 0, int pageSize = 10}) async {
    try {
      final snap = await _contestRef.where('status', isEqualTo: ContestStatus.upcoming['status']).orderBy('createAt').get();
      return snap.docs.map((e) => Contest.fromJson(e.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Contest>> getExpiredContest({int page = 0, int pageSize = 10}) async {
    try {
      final snap = await _contestRef.where('status', isEqualTo: ContestStatus.expired['status']).orderBy('createAt').get();
      return snap.docs.map((e) => Contest.fromJson(e.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }
}