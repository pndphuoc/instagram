import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/edit_profile_view_model.dart';
import 'package:provider/provider.dart';

import '../../widgets/animation_widgets/show_up_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late CurrentUserViewModel _currentUserViewModel;
  final EditProfileViewModel _editProfileViewModel = EditProfileViewModel();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _editProfileViewModel.displayNameNode.addListener(() => _editProfileViewModel.onDisplayNameFocusChange());
    _editProfileViewModel.usernameNode.addListener(() => _editProfileViewModel.onUsernameFocusChange());
    _displayNameController.text = _currentUserViewModel.user!.displayName;
    _usernameController.text = _currentUserViewModel.user!.username;
    _bioController.text = _currentUserViewModel.user!.bio;
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
                    return ShowUp(delay: 0, child: _buildDisplayNameNote(context));
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
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.blue),
                    )),
              ),
            )
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
            child: CircleAvatar(
              radius: 40,
              backgroundImage: _currentUserViewModel.user!.avatarUrl.isNotEmpty
                  ? NetworkImage(_currentUserViewModel.user!.avatarUrl)
                  : defaultAvatar,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        TextButton(
            onPressed: () {},
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
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        const SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: () {},
          child: const SizedBox(
            width: kToolbarHeight,
            child: Icon(
              Icons.check,
              color: Colors.blue,
              size: 30,
            ),
          ),
        ),
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
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.grey),
          ),
          TextField(
            focusNode: _editProfileViewModel.displayNameNode,
            controller: _displayNameController,
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
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.grey),
          ),
          TextField(
            focusNode: _editProfileViewModel.usernameNode,
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce?.cancel();

              _debounce = Timer(const Duration(milliseconds: 300), () async {
                _editProfileViewModel.onUsernameFieldChanged(value, _currentUserViewModel.user!.username);
              });

            },
            decoration: InputDecoration(
              suffix: StreamBuilder(
                stream: _editProfileViewModel.usernameCheckingStream,
                initialData: false,
                builder: (context, snapshot) {
                  if (snapshot.data!) {
                    return const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(color: Colors.grey,));
                  } else {
                    return const SizedBox();
                  }
                },
              )
            ),
            controller: _usernameController,
            cursorHeight: 25,
          ),
          const SizedBox(height: 10,),
          StreamBuilder(
              stream: _editProfileViewModel.usernameNotificationStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                } else {
                  return ShowUp(delay: 0, child: snapshot.data!);
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
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.grey),
          ),
          TextField(
            controller: _bioController,
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
            Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
      ),
    );
  }
}
