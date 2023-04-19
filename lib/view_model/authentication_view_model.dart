import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/services/authentication_services.dart';
import 'package:instagram/services/elastic_services.dart';
import 'package:instagram/services/user_services.dart';

class AuthenticationViewModel extends ChangeNotifier {
  final AuthenticationService _service = AuthenticationService();
  final ElasticService _elasticService = ElasticService();
  final UserService _userService = UserService();

  Future<String> login(
      {required String email, required String password}) async {
    return await _service.login(email: email, password: password);
  }

  Future<void> logout() async {
    await _service.logout();
  }

  Future<String?> signInWithGoogle() async {
    try {
      final userCredential = await _service.signInWithGoogle();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return null;
      }

      if (userCredential.additionalUserInfo!.isNewUser) {
        return await _userService.addNewUser(
          uid: user.uid,
          email: user.email.toString(),
          username: user.email.toString().split('@').first,
          avatarUrl: user.photoURL.toString(),
          displayName: user.displayName.toString());
      }

    } catch (e) {
      rethrow;
    }
  }

  Future<String> signUp(
      {required String email,
      required String password,
      required String username,}) async {
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      return "Please enter all fields";
    }

    String result = await _service.signUp(
        email: email,
        password: password);

    return result;
  }
}
