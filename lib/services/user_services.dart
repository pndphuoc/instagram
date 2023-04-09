import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/interface/user_interface.dart';
import 'package:instagram/models/post.dart';
import 'package:instagram/models/user.dart' as model;

class UserService implements IUserService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  @override
  Future<model.User?> getUserDetails(String userId) async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    if (snap.data() == null){
      return null;
    }
    return model.User.fromJson(snap.data() as Map<String, dynamic>);
  }

  @override
  Future<bool> updatePostInformation(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser!.uid)
          .update({
        'postsCount': FieldValue.increment(1),
        'postIds': FieldValue.arrayUnion([postId])
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

}