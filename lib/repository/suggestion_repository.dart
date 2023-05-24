import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/user.dart';

class SuggestionRepository {
  static final CollectionReference _userRef = FirebaseFirestore.instance.collection('users');
  
  Future<List<User>> getSuggestedUsers() async {
    final snap = await _userRef.orderBy('followerCount', descending: true).limit(10).get();
    return snap.docs.map((e) => User.fromJson(e.data() as Map<String, dynamic>)).toList();
  }
}