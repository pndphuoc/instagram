import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:instagram/services/authentication_services.dart';
import 'package:instagram/services/elastic_services.dart';

class AuthenticationViewModel extends ChangeNotifier {
  final AuthenticationService _service = AuthenticationService();
  final ElasticService _elasticService = ElasticService();

  Future<String> login(
      {required String email, required String password}) async {
    return await _service.login(email: email, password: password);
  }

  Future<void> logout() async {
    await _service.logout();
  }

  Future<bool> signInWithGoogle() async {
    return await _service.signInWithGoogle();
  }

  Future<String> signUp(
      {required String email,
      required String password,
      required String username,
      String displayName = '',
      String bio = '',
      String avatarUrl = ''}) async {
    final isExists = await _elasticService.isUsernameExists('users', username);

    if (isExists) {
      return "Username already exists";
    }

    String result = await _service.signUp(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
        bio: bio,
        avatarUrl: avatarUrl);

    return result;
  }

  Future<String> completeSignInWithGoogle(
      {required String username, String bio = "", Uint8List? file}) async {
    return await _service.completeSignInWithGoogle(
        username: username, bio: bio, file: file);
  }

  Future<bool> isNewUser() async {
    return await _service.isNewUser();
  }
}
