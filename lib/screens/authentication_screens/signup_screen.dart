import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/ultis/ultils.dart';
import 'package:instagram/view_model/authentication_view_model.dart';
import 'package:instagram/view_model/elastic_view_model.dart';
import 'package:instagram/view_model/firestore_view_model.dart';
import 'package:instagram/view_model/user_view_model.dart';
import 'package:instagram/widgets/text_form_field.dart';
import 'package:provider/provider.dart';

import '../../ultis/global_variables.dart';
import '../../view_model/current_user_view_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final FirestoreViewModel _firestoreViewModel = FirestoreViewModel();

  File? _image;
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthenticationViewModel _authenticationViewModel =
      AuthenticationViewModel();
  final UserViewModel _userViewModel = UserViewModel();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return ListenableProvider(
      create: (_) => AuthenticationViewModel(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        key: _scaffoldKey,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - kToolbarHeight,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                  SvgPicture.asset(
                    'assets/ic_instagram.svg',
                    height: 64,
                  ),
                  const SizedBox(
                    height: 64,
                  ),
                  Consumer<AuthenticationViewModel>(
                    builder: (context, value, child) => Stack(
                      children: [
                        value.image != null
                            ? CircleAvatar(
                          radius: 64,
                          backgroundImage: FileImage(value.image!),
                        )
                            : const CircleAvatar(
                          radius: 64,
                          backgroundImage:
                          AssetImage('assets/default_avatar.png'),
                        ),
                        Positioned(
                            bottom: -10,
                            right: 0,
                            child: IconButton(
                              onPressed: () => value.selectImage(),
                              icon: const Icon(Icons.add_a_photo_outlined),
                            ))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormFieldInput.email(
                    textEditingController: _emailController,
                    hintText: 'Enter your email',
                    textInputType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormFieldInput.username(
                      textEditingController: _usernameController,
                      hintText: 'Enter your user name',
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.text),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                        hintText: 'Enter your display name',
                        border: inputBorder,
                        focusedBorder: inputBorder,
                        enabledBorder: inputBorder,
                        filled: true,
                        contentPadding: const EdgeInsets.all(8)),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _bioController,
                    decoration: InputDecoration(
                        hintText: 'Enter your bio',
                        border: inputBorder,
                        focusedBorder: inputBorder,
                        enabledBorder: inputBorder,
                        filled: true,
                        contentPadding: const EdgeInsets.all(8)),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormFieldInput.password(
                    textEditingController: _passwordController,
                    hintText: 'Enter your password',
                    textInputType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                        hintText: 'Confirm your password',
                        border: OutlineInputBorder(
                            borderSide: Divider.createBorderSide(context)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: Divider.createBorderSide(context)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: Divider.createBorderSide(context)),
                        filled: true,
                        contentPadding: const EdgeInsets.all(8)),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    textInputAction: TextInputAction.send,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password.';
                      } else if (value != _passwordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Consumer<AuthenticationViewModel>(
                      builder: (context, value, child) {
                        if (value.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ));
                        } else {
                          return InkWell(
                            onTap: () {
                              value
                                  .signUp(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  username: _usernameController.text,
                                  bio: _bioController.text,
                                displayName: _displayNameController.text
                              )
                                  .then((value) {
                                if (value != 'success') {
                                  showSnackBar(context, 'value');
                                } else {
                                  showSnackBar(context, 'Sign up success');
                                  Navigator.pop(context);
                                }
                              });
                            },
                            child: Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(4))),
                                child: const Text(
                                  'Sign up',
                                )),
                          );
                        }
                      },),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: const Text("Already have an account?")),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            child: const Text(
                              "Log in",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            )),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
}
