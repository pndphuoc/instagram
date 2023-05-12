import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/contest.dart';

import '../models/post.dart';
import '../models/prize.dart';


class ContestRepository {
  static final CollectionReference _contestRef = FirebaseFirestore.instance.collection('contest');
  static final CollectionReference _postRef = FirebaseFirestore.instance.collection('posts');
  static final CollectionReference _userRef = FirebaseFirestore.instance.collection('users');

  static Future<void> addContest(Contest contest) async {
    try {
      final doc = _contestRef.doc();
      contest.uid = doc.id;
      await doc.set(contest.toJson());
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Contest>> getContests() async {
    try {
      final snap = await _contestRef.get();
      return snap.docs.map((e) => Contest.fromJson(e.data() as Map<String, dynamic>)).toList();
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
  
  static Future<List<Post>> getPostsOfContest(String contestId, {int page = 0, int pageSize = 10}) async {
    try {
      final snap = await _postRef.where('contestId', isEqualTo: contestId).orderBy('createAt', descending: true).orderBy('likeCount', descending: true).get();
      return snap.docs.map((e) => Post.fromJson(e.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<List<Contest>> getOwnContest({required String userId}) async {
    try {
      final snap = await _contestRef.where('ownerId', isEqualTo: userId).get();
      return snap.docs.map((e) => Contest.fromJson(e.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Contest>> getJoinedContest({required String userId}) async {
    try {
      final snap = await _postRef.where('isContestPost', isEqualTo: true).where('userId', isEqualTo: userId).get();

      final List contestIds = snap.docs.map((post) => (post.data() as Map<String, dynamic>)['contestId']).toSet().toList();
      List<Contest> contestList = [];
      for (final contestId in contestIds) {
        contestList.add(await getContestDetail(contestId));
      }
      return contestList;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updatePrizes({required String contestId, required List<Prize> prizes}) async {
    try {
      final prizeJsonList = prizes.map((e) => e.toJson()).toList();
      await _contestRef.doc(contestId).update({
        'prizes': prizeJsonList,
      });
    } catch (e) {
      rethrow;
    }
  }

}