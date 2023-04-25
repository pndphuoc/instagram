import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram/interface/authenticatin_interface.dart';
import 'package:instagram/services/firebase_storage_services.dart';
import 'package:instagram/ultis/global_variables.dart';

import '../models/user.dart' as model;

class AuthenticationService implements IAuthenticationService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final CollectionReference _followerListCollection =
      FirebaseFirestore.instance.collection('followerList');
  final CollectionReference _followingListCollection =
      FirebaseFirestore.instance.collection('followingList');
  final CollectionReference _blockedListCollection =
      FirebaseFirestore.instance.collection('blockedList');
  final FireBaseStorageService _fireBaseStorageService = FireBaseStorageService();
  

  @override
  Future<String> login(
      {required String email, required String password}) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Please enter all fields";
      }

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      return "Login successful";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return "Wrong password";
      } else if (e.code == 'user-not-found') {
        return "User not found";
      } else {
        print(e.toString());
        return "Some error occurred";
      }
    } catch (err) {
      print(err.toString());
      return "Some error occurred";
    }
  }

  @override
  Future<void> logout() async {
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
    }
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);

    return authResult;
  }

  @override
  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return "success";

    } catch (err) {
      return err.toString();
    }
  }

  @override
  Future<bool> isUsernameExists(String username) async {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      final List<DocumentSnapshot> documents = result.docs;
      return documents.isNotEmpty;
  }
}
