import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/services/authentication_services.dart';
import 'package:instagram/services/conversation_services.dart';
import 'package:instagram/services/post_services.dart';
import 'package:instagram/services/user_services.dart';
import 'package:instagram/view_model/firestore_view_model.dart';

import '../models/user_summary_information.dart';
import '../ultis/global_variables.dart';

class EditProfileViewModel extends ChangeNotifier {
  final String _oldUsername;
  final String _oldDisplayName;
  final String _oldBio;
  final String _oldAvatarUrl;
  final String _userId = FirebaseAuth.instance.currentUser!.uid;
  late UserSummaryInformation _oldData;

  EditProfileViewModel(this._oldUsername, this._oldDisplayName, this._oldBio,
      this._oldAvatarUrl) {
    _oldData = UserSummaryInformation(
        userId: _userId,
        username: _oldUsername,
        avatarUrl: _oldAvatarUrl,
        displayName: _oldDisplayName);
  }

  final AuthenticationService _authenticationService = AuthenticationService();
  final FirestoreViewModel _firestoreViewModel = FirestoreViewModel();
  final UserService _userService = UserService();
  final PostService _postService = PostService();
  final ConversationService _conversationService = ConversationService();

  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();

  TextEditingController get displayNameController => _displayNameController;

  set displayNameController(TextEditingController value) {
    _displayNameController = value;
  }

  TextEditingController get usernameController => _usernameController;

  set usernameController(TextEditingController value) {
    _usernameController = value;
  }

  TextEditingController get bioController => _bioController;

  set bioController(TextEditingController value) {
    _bioController = value;
  }

  final FocusNode _displayNameNode = FocusNode();

  FocusNode get displayNameNode => _displayNameNode;

  final FocusNode _usernameNode = FocusNode();

  FocusNode get usernameNode => _usernameNode;

  final _displayNameNoteController = StreamController<bool>();

  Stream<bool> get displayNameStream => _displayNameNoteController.stream;

  final _usernameCheckingController = StreamController<bool>();

  Stream<bool> get usernameCheckingStream => _usernameCheckingController.stream;

  final _usernameNotificationController = StreamController<String>();

  Stream<String> get usernameNotificationStream =>
      _usernameNotificationController.stream;

  final _updatingController = StreamController<bool>();

  Stream<bool> get updatingStream => _updatingController.stream;

  void onDisplayNameFocusChange() {
    if (_displayNameNode.hasFocus) {
      _displayNameNoteController.sink.add(true);
    } else {
      _displayNameNoteController.sink.add(false);
    }
  }

  bool _isUsernameValid = false;

  void onUsernameFieldChanged(String username, String currentUsername) async {
    if (username == currentUsername) {
      _usernameNotificationController.sink.add('');
      return;
    }
    if (username.isEmpty) {
      _usernameNotificationController.sink.add("Username must not empty");
      return;
    } else if (username.length < 5) {
      _usernameNotificationController.sink.add("Username too short");
      return;
    }

    _usernameCheckingController.sink.add(true);
    final result = await _authenticationService.isUsernameExists(username);
    _usernameCheckingController.sink.add(false);
    if (result) {
      _usernameNotificationController.sink.add("Username already exists");
    } else {
      _isUsernameValid = true;
      _usernameNotificationController.sink.add("You can use this username");
    }
  }

  final ImagePicker _picker = ImagePicker();
  File? _newAvatar;

  final _newAvatarController = StreamController<File>.broadcast();

  Stream<File> get newAvatarStream => _newAvatarController.stream;

  File? get newAvatar => _newAvatar;

  onGalleryTap() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    onConfirmNewAvatar(File(image.path));
  }

  onConfirmNewAvatar(File file) {
    _newAvatar = file;
    _newAvatarController.sink.add(file);
  }

  Future<bool> onSave() async {
    _updatingController.sink.add(true);
    String newAvatarUrl = _oldAvatarUrl;
    String newUsername = _usernameController.text;
    String newDisplayName = _displayNameController.text;
    String newBio = _bioController.text;

    if (_newAvatar != null) {
      newAvatarUrl = await _firestoreViewModel.uploadFile(
          _newAvatar!, profilePicturesPath);
    } else if ((_newAvatar == null &&
        _oldUsername == newUsername &&
        _oldDisplayName == newDisplayName &&
        _oldBio == newBio) || _isUsernameValid == false) {
      _updatingController.sink.add(false);
      return false;
    }



    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        await _userService.updateUserInformationTransaction(
            transaction: transaction,
            userId: _userId,
            newAvatarUrl: newAvatarUrl,
            newUsername: newUsername,
            newDisplayName: newDisplayName,
            newBio: newBio
        );

        await _postService.updateOwnerInformation(
            userId: _userId,
            avatarUrl: newAvatarUrl,
            username: newUsername
        );

        final UserSummaryInformation newData = UserSummaryInformation(
            userId: _userId,
            username: newUsername,
            avatarUrl: newAvatarUrl,
            displayName: newDisplayName);

        await _conversationService.updateUserInformation(
            userId: _userId,
            oldData: _oldData,
            newData: newData
        );
      });

      if (_oldAvatarUrl != newAvatarUrl) {
        Reference reference = FirebaseStorage.instance.refFromURL(_oldAvatarUrl);
        await reference.delete().then((value) => print('File deleted successfully'))
            .catchError((onError) => print('An error occurred while deleting the file: $onError'));
      }
    } catch (e) {
      print("Transaction failed: ${e.toString()}");
      return false;
    }

    _updatingController.sink.add(false);
    return true;
  }

  @override
  void dispose() {
    _newAvatarController.close();
    _usernameCheckingController.close();
    _displayNameNoteController.close();
    _usernameNotificationController.close();
    super.dispose();
  }
}
