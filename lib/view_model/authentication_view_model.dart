import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/repository/authentication_repository.dart';
import 'package:instagram/repository/notification_repository.dart';
import 'package:instagram/repository/user_repository.dart';

import 'notification_controller.dart';

class AuthenticationViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldMessengerState>? key;
  AuthenticationViewModel({this.key});

  final token = NotificationController().firebaseToken;
  final _loadingController = StreamController<bool>();
  Stream<bool> get loadingStream => _loadingController.stream;

  Future<String> login(
      {required String email, required String password}) async {
    _loadingController.sink.add(true);

    String res = await AuthenticationRepository.login(email: email, password: password);

    if (res == 'Login successful') {
      await NotificationRepository.addFcmToken(FirebaseAuth.instance.currentUser!.uid, token!);
    }

    _loadingController.sink.add(false);

    return res;
  }

  Future<void> logout() async {
    await NotificationRepository.removeFcmToken(FirebaseAuth.instance.currentUser!.uid, token);
    await AuthenticationRepository.logout();
  }

  Future<String?> signInWithGoogle() async {
    try {
      final userCredential = await AuthenticationRepository.signInWithGoogle();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return null;
      }

      await NotificationRepository.addFcmToken(FirebaseAuth.instance.currentUser!.uid, token);

      if (userCredential.additionalUserInfo!.isNewUser) {
        return await UserRepository.addNewUser(
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

    String result = await AuthenticationRepository.signUp(
        email: email,
        password: password);

    if (result == 'success') {
      await NotificationRepository.addFcmToken(FirebaseAuth.instance.currentUser!.uid, token!);
    }

    _loadingController.sink.add(false);

    return result;
  }


}
