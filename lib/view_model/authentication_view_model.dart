import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:instagram/services/authentication_services.dart';
import 'package:instagram/services/elastic_services.dart';
import 'package:instagram/services/notification_services.dart';
import 'package:instagram/services/user_services.dart';
import 'package:instagram/ultis/ultils.dart';

import 'notification_controller.dart';

class AuthenticationViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldMessengerState>? key;

  AuthenticationViewModel({this.key});

  final AuthenticationService _service = AuthenticationService();
  final ElasticService _elasticService = ElasticService();
  final UserService _userService = UserService();
  final token = NotificationController().firebaseToken;
  final _loadingController = StreamController<bool>();
  Stream<bool> get loadingStream => _loadingController.stream;

  Future<String> login(
      {required String email, required String password}) async {
    _loadingController.sink.add(true);

    String res = await _service.login(email: email, password: password);

    if (res == 'Login successful') {
      await NotificationServices.addFcmToken(FirebaseAuth.instance.currentUser!.uid, token!);
    }

    _loadingController.sink.add(false);

    return res;
  }

  Future<void> logout() async {
    await NotificationServices.removeFcmToken(FirebaseAuth.instance.currentUser!.uid, token);
    await _service.logout();
  }

  Future<String?> signInWithGoogle() async {
    try {
      final userCredential = await _service.signInWithGoogle();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return null;
      }

      await NotificationServices.addFcmToken(FirebaseAuth.instance.currentUser!.uid, token);

      if (userCredential.additionalUserInfo!.isNewUser) {
        return await _userService.addNewUser(
          uid: user.uid,
          email: user.email.toString(),
          username: user.email.toString().split('@').first,
          avatarUrl: user.photoURL.toString(),
          displayName: user.displayName.toString());
      }
      return user.uid;
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

    if (result == 'success') {
      await NotificationServices.addFcmToken(FirebaseAuth.instance.currentUser!.uid, token!);
    }

    _loadingController.sink.add(false);

    return result;
  }


}
