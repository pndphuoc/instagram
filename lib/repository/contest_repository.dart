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
      final snap = await _postRef.where('contestId', isEqualTo: contestId).limit(10).get();
      return snap.docs.map((e) => Post.fromJson(e.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }
}