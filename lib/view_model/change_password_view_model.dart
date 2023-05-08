import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../repository/authentication_repository.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  bool isChanging = false;
  bool isReenterNewPasswordDifferent = false;
  bool isEmailEmpty = false;

  Future<bool> onChangeButtonTap(String email, String oldPassword, String newPassword, String reenterNewPassword) async {
    if (newPassword != reenterNewPassword) {
      isReenterNewPasswordDifferent = true;
      Fluttertoast.showToast(msg: 'Reenter password is wrong');
      notifyListeners();
      return false;
    }

    isChanging = true;
    notifyListeners();

    bool result = await AuthenticationRepository.changePassword(email, oldPassword, newPassword);

    isChanging = false;
    notifyListeners();

    return result;
  }
}