import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/edit_profile_view_model.dart';
import 'package:provider/provider.dart';

import '../../ultis/ultils.dart';
import '../../widgets/animation_widgets/show_up_widget.dart';
import '../post_screens/camera_preview_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late CurrentUserViewModel _currentUserViewModel;

  late EditProfileViewModel _editProfileViewModel;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _editProfileViewModel = EditProfileViewModel(
        _currentUserViewModel.user!.username,
        _currentUserViewModel.user!.displayName,
        _currentUserViewModel.user!.bio,
        _currentUserViewModel.user!.avatarUrl
    );
    _editProfileViewModel.displayNameNode.addListener(() =>
        _editProfileViewModel.onDisplayNameFocusChange());
    _editProfileViewModel.displayNameController.text =
        _currentUserViewModel.user!.displayName;
    _editProfileViewModel.usernameController.text =
        _currentUserViewModel.user!.username;
    _editProfileViewModel.bioController.text = _currentUserViewModel.user!.bio;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            _buildAvatarEditor(context),
            const SizedBox(
              height: 20,
            ),
            _buildDisplayNameField(context),
            const SizedBox(height: 10,),
            StreamBuilder(
              stream: _editProfileViewModel.displayNameStream,
              initialData: false,
              builder: (context, snapshot) {
                if (snapshot.data!) {
                  return ShowUp(
                      delay: 0, child: _buildDisplayNameNote(context));
                } else {
                  return const SizedBox();
                }
              },),
            const SizedBox(
              height: 15,
            ),
            _buildUsernameField(context),
            const SizedBox(
              height: 15,
            ),
            _buildBioField(context),
            const SizedBox(
              height: 15,
            ),
            FirebaseAuth.instance.currentUser!.providerData.first.providerId == EmailAuthProvider.PROVIDER_ID ?
            InkWell(
              onTap: () {},
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Colors.white10, width: 1),
                        bottom: BorderSide(color: Colors.white10, width: 1))),
                padding: const EdgeInsets.only(left: 10),
                height: 45,
                width: double.infinity,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Change password",
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.blue),
                    )),
              ),
            ) : Container()
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarEditor(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Hero(
            tag: 'avatar',
            child: StreamBuilder(
              stream: _editProfileViewModel.newAvatarStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircleAvatar(
                    radius: 40,
                    backgroundImage: _currentUserViewModel.user!.avatarUrl
                        .isNotEmpty
                        ? NetworkImage(_currentUserViewModel.user!.avatarUrl)
                        : defaultAvatar,
                  );
                } else {
                  return CircleAvatar(
                      radius: 40,
                      backgroundImage: FileImage(snapshot.data!)
                  );
                }
              },
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        TextButton(
            onPressed: () async {
              //Navigator.push(context, MaterialPageRoute(builder: (context) => const AvatarChangeScreen(),));
              await _showModal(context);
            },
            child: Text(
              "Edit avatar",
              style: GoogleFonts.readexPro(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 15),
            ))
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text(
        "Edit profile",
        style: Theme
            .of(context)
            .textTheme
            .titleLarge,
      ),
      actions: [
        const SizedBox(
          width: 20,
        ),
        StreamBuilder(
            stream: _editProfileViewModel.updatingStream,
            initialData: false,
            builder: (context, snapshot) {
              if (!snapshot.data!) {
                return InkWell(
                  onTap: () {
                    _editProfileViewModel.onSave().then((value) => value ? Navigator.pop(context) : (){});
                  },
                  child: const SizedBox(
                    width: kToolbarHeight,
                    child: Icon(
                      Icons.check,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                );
              } else {
                return const SizedBox(width: kToolbarHeight, height: kToolbarHeight, child: Center(child: CircularProgressIndicator(),));
              }
            },),
      ],
    );
  }

  Widget _buildDisplayNameField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Display name",
            style: Theme
                .of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.grey),
          ),
          TextField(
            focusNode: _editProfileViewModel.displayNameNode,
            controller: _editProfileViewModel.displayNameController,
            cursorHeight: 25,
          )
        ],
      ),
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Username",
            style: Theme
                .of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.grey),
          ),
          TextField(
            focusNode: _editProfileViewModel.usernameNode,
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce?.cancel();

              _debounce = Timer(const Duration(milliseconds: 300), () async {
                _editProfileViewModel.onUsernameFieldChanged(
                    value, _currentUserViewModel.user!.username);
              });
            },
            decoration: InputDecoration(
                suffix: StreamBuilder(
                  stream: _editProfileViewModel.usernameCheckingStream,
                  initialData: false,
                  builder: (context, snapshot) {
                    if (snapshot.data!) {
                      return const SizedBox(width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            color: Colors.grey,));
                    } else {
                      return const SizedBox();
                    }
                  },
                )
            ),
            controller: _editProfileViewModel.usernameController,
            cursorHeight: 25,
          ),
          const SizedBox(height: 10,),
          StreamBuilder(
            stream: _editProfileViewModel.usernameNotificationStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              } else {
                return ShowUp(delay: 0, child: Text(snapshot.data!, style: Theme.of(context).textTheme.titleMedium,));
              }
            },)
        ],
      ),
    );
  }

  Widget _buildBioField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bio",
            style: Theme
                .of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.grey),
          ),
          TextField(
            controller: _editProfileViewModel.bioController,
            cursorHeight: 25,
          )
        ],
      ),
    );
  }

  Widget _buildDisplayNameNote(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Text(
        "Get a name you use often to make your account easier to find. It can be your full name, nickname or business name",
        style:
        Theme
            .of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.grey),
      ),
    );
  }

  Future _showModal(BuildContext context) {
    return showModalBottomSheet(context: context,
      backgroundColor: secondaryColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          decoration: const BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await _editProfileViewModel.onGalleryTap();
                      },
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: const BoxDecoration(
                            color: Colors.white38,
                            shape: BoxShape.circle
                        ),
                        child: const Icon(
                          Icons.collections, color: Colors.white, size: 30,),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Text("Gallery", style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium,)
                  ],
                ),
                const SizedBox(width: 30,),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await availableCameras().then((cameras) async {
                          if (cameras.isEmpty) {
                            return;
                          }
                          Navigator.pop(context);
                          final List newAvatar = await Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                  CameraPreviewScreen(cameras: cameras,
                                      isOnlyTakePhoto: true,),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return buildSlideTransition(animation, child);
                              },
                              transitionDuration:
                              const Duration(milliseconds: 150),
                              reverseTransitionDuration:
                              const Duration(milliseconds: 150),
                            ),
                          );
                          _editProfileViewModel.onConfirmNewAvatar(newAvatar[0]);
                        });
                      },
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: const BoxDecoration(
                            color: Colors.white38,
                            shape: BoxShape.circle
                        ),
                        child: const Icon(
                          Icons.collections, color: Colors.white, size: 30,),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Text("Camera", style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium,)
                  ],
                ),
              ],
            ),
          ),
        );
      },);
  }
}
