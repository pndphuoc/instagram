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

import '../ultis/global_variables.dart';
import '../view_model/current_user_view_model.dart';

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
  bool _isLoading = false;
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AuthenticationViewModel _authenticationViewModel;
  final UserViewModel _userViewModel = UserViewModel();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authenticationViewModel = context.read<AuthenticationViewModel>();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }

  void selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 1080, maxWidth: 1080);

    if (pickedFile != null) {
      final File image = File(pickedFile.path);
      setState(() {
        _image = image;
      });
    }
  }

  void _signUpUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final avatarUrl = await _uploadAvatar();
    final signUpResult = await _performSignUp(avatarUrl ?? "");

    if (signUpResult != 'success') {
      if (!mounted) return;
      showSnackBar(context, signUpResult);
    } else {
      if (!mounted) return;
      Navigator.pop(context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String?> _uploadAvatar() async {
    if (_image == null) return null;
    return await _firestoreViewModel.uploadFile(_image!, profilePicturesPath);
  }

  Future<String> _performSignUp(String avatarUrl) async {
    String result = await _authenticationViewModel.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text);

    if (result == 'success') {
      await _userViewModel.addNewUser(
          email: _emailController.text,
          username: _usernameController.text,
          uid: FirebaseAuth.instance.currentUser!.uid,
          bio: _bioController.text,
          displayName: _displayNameController.text,
          avatarUrl: avatarUrl);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return Scaffold(
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
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: FileImage(_image!),
                          )
                        : const CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/1200px-Default_pfp.svg.png'),
                          ),
                    Positioned(
                        bottom: -10,
                        right: 0,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo_outlined),
                        ))
                  ],
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
                InkWell(
                  onTap: _signUpUser,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: Colors.white,
                        ))
                      : Container(
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
                ),
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
    );
  }
}
