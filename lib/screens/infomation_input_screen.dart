import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/view_model/authentication_view_model.dart';
import 'package:provider/provider.dart';

import '../ultis/colors.dart';
import '../ultis/ultils.dart';
import '../view_model/current_user_view_model.dart';
import '../widgets/text_form_field.dart';

class InformationInputScreen extends StatefulWidget {
  const InformationInputScreen({Key? key}) : super(key: key);

  @override
  State<InformationInputScreen> createState() => _InformationInputScreenState();
}

class _InformationInputScreenState extends State<InformationInputScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Uint8List? _image;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }

  void selectImage() async {
    Uint8List image = await pickImage(ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  void _cancelSignIn() async {
    await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to cancel your account registration?'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () {
                  GoogleSignIn().disconnect();
                  FirebaseAuth.instance.currentUser!.delete();
                  Navigator.of(context).pop();
                },
                child: const Text('Yes'),
              ),
            ],
          ),
    );

  }

  void _completeSignUpUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthenticationViewModel>(context, listen: false);

    String res = await authService.completeSignInWithGoogle(
        username: _usernameController.text,
        bio: _bioController.text,
        file: _image);

    if (res != 'success') {
      if (!mounted) return;
      showSnackBar(context, res);
    } else {
      if (!mounted) return;
      //Navigator.pop(context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height - kToolbarHeight,
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
                      color: primaryColor,
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
                          backgroundImage: MemoryImage(_image!),
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
                    TextFormFieldInput(
                        textEditingController: _bioController,
                        hintText: 'Enter your bio',
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.text),
                    const SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: _completeSignUpUser,
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
                            'Next',
                          )),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Divider(
                      color: Colors.grey,
                      height: 1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: _cancelSignIn,
                      child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                              BorderRadius.all(Radius.circular(4))),
                          child: const Text(
                            'Cancel',
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
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
