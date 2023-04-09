import 'package:flutter/material.dart';
import 'package:instagram/view_model/elastic_view_model.dart';

class TextFormFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final bool isEmail;
  final bool isUsername;
  final String hintText;
  final TextInputType textInputType;
  final TextInputAction textInputAction;

  const TextFormFieldInput(
      {Key? key,
      required this.textEditingController,
      this.isPass = false,
      this.isEmail = false,
      this.isUsername = false,
      required this.hintText,
      required this.textInputType,
      required this.textInputAction})
      : super(key: key);

  factory TextFormFieldInput.email(
      {required TextEditingController textEditingController,
      required String hintText,
      required TextInputType textInputType,
      required TextInputAction textInputAction}) {
    return TextFormFieldInput(
        textEditingController: textEditingController,
        isEmail: true,
        isPass: false,
        isUsername: false,
        hintText: hintText,
        textInputType: textInputType,
        textInputAction: textInputAction);
  }

  factory TextFormFieldInput.password(
      {required TextEditingController textEditingController,
      required String hintText,
      required TextInputType textInputType,
      required TextInputAction textInputAction}) {
    return TextFormFieldInput(
        textEditingController: textEditingController,
        isPass: true,
        isEmail: false,
        isUsername: false,
        hintText: hintText,
        textInputType: textInputType,
        textInputAction: textInputAction);
  }

  factory TextFormFieldInput.username(
      {required TextEditingController textEditingController,
      required String hintText,
      required TextInputType textInputType,
      required TextInputAction textInputAction}) {
    return TextFormFieldInput(
        textEditingController: textEditingController,
        isEmail: false,
        isUsername: true,
        isPass: false,
        hintText: hintText,
        textInputType: textInputType,
        textInputAction: textInputAction);
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));

    emailValidator(String? value) {
      if (value!.isEmpty) {
        return 'Please enter your email';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return 'Please enter a valid email';
      }
      return null;
    }

    passwordValidator(String? value) {
      if (value!.isEmpty) {
        return 'Please enter your password';
      } else if (value.length < 8) {
        return 'Password must be at least 8 characters';
      }
      return null;
    }

     usernameValidator(String? username) {
      if (username!.isEmpty) {
        return 'Please enter your username';
      }
      return null;
    }

    selectValidator(String? value) {
      if (isPass) {
        return passwordValidator(value!);
      } else if (isEmail) {
        return emailValidator(value!);
      } else if (isUsername) {
        return usernameValidator(value!);
      } else {
        return null;
      }
    }

    return TextFormField(
      controller: textEditingController,
      decoration: InputDecoration(
          hintText: hintText,
          border: inputBorder,
          focusedBorder: inputBorder,
          enabledBorder: inputBorder,
          filled: true,
          contentPadding: const EdgeInsets.all(8)),
      keyboardType: textInputType,
      textInputAction: textInputAction,
      obscureText: isPass,
      validator: (value) => selectValidator(value),
    );
  }
}
