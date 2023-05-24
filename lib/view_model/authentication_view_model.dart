import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/repository/authentication_repository.dart';
import 'package:instagram/repository/firebase_storage_repository.dart';
import 'package:instagram/repository/notification_repository.dart';
import 'package:instagram/repository/user_repository.dart';

import '../ultis/global_variables.dart';
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
      await NotificationRepository.addFcmToken(FirebaseAuth.instance.currentUser!.uid, token);
    }

    _loadingController.sink.add(false);

    return res;
  }

  static Future<void> logout() async {
    await NotificationRepository.removeFcmToken(FirebaseAuth.instance.currentUser!.uid, NotificationController().firebaseToken);
    await AuthenticationRepository.logout();
  }

  Future<String?> signInWithGoogle() async {
    try {
      final userCredential = await AuthenticationRepository.signInWithGoogle();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return null;
      }

      if (userCredential.additionalUserInfo!.isNewUser) {
        return await UserRepository.addNewUser(
          uid: user.uid,
          email: user.email.toString(),
          username: user.email.toString().split('@').first,
          avatarUrl: user.photoURL.toString(),
          displayName: user.displayName.toString());
      }

      await NotificationRepository.addFcmToken(FirebaseAuth.instance.currentUser!.uid, token);
      
      return user.uid;
    } catch (e) {
      rethrow;
    }
  }


  Future<String> signUp(
      {required String email,
      required String password,
      required String username,
      String bio = '',
        String displayName = ''
      }) async {
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      return "Please enter all fields";
    }
    isLoading = true;
    notifyListeners();

    String result = await AuthenticationRepository.signUp(
        email: email,
        password: password);



    if (result == 'success') {
      String? avatarUrl = await _uploadAvatar();
      await UserRepository.addNewUser(
          email: email,
          username: username,
          uid: FirebaseAuth.instance.currentUser!.uid,
          bio: bio,
          displayName: displayName,
          avatarUrl: avatarUrl ?? "");
      await NotificationRepository.addFcmToken(FirebaseAuth.instance.currentUser!.uid, token);
    }

    isLoading = false;
    notifyListeners();

    return result;
  }

  Future<String?> _uploadAvatar() async {
    if (_image == null) return null;
    return await FireBaseStorageRepository.uploadFile(_image!, profilePicturesPath);
  }

  File? _image;

  File? get image => _image;
  bool isLoading = false;

  void selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 1080, maxWidth: 1080);

    if (pickedFile != null) {
      final File image = File(pickedFile.path);
        _image = image;
        notifyListeners();
    }
  }

}
