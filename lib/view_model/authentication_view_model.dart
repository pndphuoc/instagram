import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/services/authentication_services.dart';
import 'package:instagram/services/elastic_services.dart';
import 'package:instagram/services/user_services.dart';
import 'package:instagram/ultis/ultils.dart';

class AuthenticationViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldMessengerState>? key;

  AuthenticationViewModel({this.key});

  final AuthenticationService _service = AuthenticationService();
  final ElasticService _elasticService = ElasticService();
  final UserService _userService = UserService();

  final _loadingController = StreamController<bool>();
  Stream<bool> get loadingStream => _loadingController.stream;

  Future<String> login(
      {required String email, required String password}) async {
    _loadingController.sink.add(true);

    String res = await _service.login(email: email, password: password);

    _loadingController.sink.add(false);

    return res;
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
    _loadingController.sink.add(true);

    String result = await _service.signUp(
        email: email,
        password: password);

    _loadingController.sink.add(false);

    return result;
  }

  void isUsernameExists(String username) {

  }
}
