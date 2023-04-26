import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/services/authentication_services.dart';

class EditProfileViewModel extends ChangeNotifier {
  final AuthenticationService _authenticationService = AuthenticationService();

  final FocusNode _displayNameNode = FocusNode();
  FocusNode get displayNameNode => _displayNameNode;

  final FocusNode _usernameNode = FocusNode();
  FocusNode get usernameNode => _usernameNode;

  final _displayNameController = StreamController<bool>();
  Stream<bool> get displayNameStream => _displayNameController.stream;

  final _usernameCheckingController = StreamController<bool>();
  Stream<bool> get usernameCheckingStream => _usernameCheckingController.stream;

  final _usernameNotificationController = StreamController<Widget>();
  Stream<Widget> get usernameNotificationStream => _usernameNotificationController.stream;

  void onDisplayNameFocusChange() {
    if (_displayNameNode.hasFocus) {
      _displayNameController.sink.add(true);
    } else {
      _displayNameController.sink.add(false);
    }
  }

  void onUsernameFocusChange() {
    if (!_usernameNode.hasFocus) {
      _usernameNotificationController.sink.add(Container());
    }
  }

  void onUsernameFieldChanged(String username, String currentUsername) async {
    if (username == currentUsername) {
      _usernameNotificationController.sink.add(Container());
      return;
    }
    _usernameCheckingController.sink.add(true);
    final result = await _authenticationService.isUsernameExists(username);
    _usernameCheckingController.sink.add(false);
    if (result) {
      _usernameNotificationController.sink.add(Text("Username already exists", style: GoogleFonts.readexPro(color: Colors.red, fontWeight: FontWeight.w600)));
    } else {
      _usernameNotificationController.sink.add(Text("You can use this username", style: GoogleFonts.readexPro(color: Colors.grey, fontWeight: FontWeight.w400)));
    }
  }

}