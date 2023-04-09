import 'dart:typed_data';

abstract class IAuthenticationService {
  Future<String> signUp({
    required String email,
    required String password,
    required String username,
    String displayName = '',
    String bio = '',
    String avatarUrl,
  });

  Future<String> login({required String email, required String password});
  Future<void> logout();
  Future<bool> signInWithGoogle();
  Future<String> completeSignInWithGoogle(
      {required String username, String bio = "", Uint8List? file});
  Future<bool> isNewUser();
}