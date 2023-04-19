import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthenticationService {
  Future<String?> signUp({
    required String email,
    required String password,
  });

  Future<String> login({required String email, required String password});
  Future<void> logout();
  Future<UserCredential> signInWithGoogle();
  Future<String> completeSignInWithGoogle(
      {required String username, String bio = "", File? file});
}