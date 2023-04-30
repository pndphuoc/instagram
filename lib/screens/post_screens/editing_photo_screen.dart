import 'dart:io';

import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/asset_view_model.dart';
import 'package:instagram/view_model/edit_profile_view_model.dart';
import 'package:provider/provider.dart';

import '../../ultis/ultils.dart';
import 'add_caption_screen.dart';

class EditingPhotoScreen extends StatefulWidget {
  final File photo;
  final bool isChangeAvatar;
  final EditProfileViewModel? editProfileViewModel;

  const EditingPhotoScreen({Key? key, required this.photo, this.isChangeAvatar = false, this.editProfileViewModel}) : super(key: key);

  @override
  State<EditingPhotoScreen> createState() => _EditingPhotoScreenState();
}

class _EditingPhotoScreenState extends State<EditingPhotoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Image.file(
              widget.photo,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
            ),
            const SizedBox(height: 100,),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(left: 20),
                itemCount: 9,
                separatorBuilder: (context, index) => const SizedBox(
                  width: 10,
                ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return _buildColorFilterBlock(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      actions: [
        IconButton(
            onPressed: () {
              if (widget.isChangeAvatar) {
                widget.editProfileViewModel?.onConfirmNewAvatar(widget.photo);
                Navigator.pop(context);
              } else {
                context.read<AssetViewModel>().selectedFile = widget.photo;
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                        AddCaptionScreen(media: widget.photo),
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
              }
            },
            icon: const Icon(
              Icons.arrow_forward,
              size: 30,
            ))
      ],
    );
  }

  Widget _buildColorFilterBlock(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3.7,
      child: Column(
        children: [
          Text("Black and White",
              style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.fade),
          const SizedBox(
            height: 5,
          ),
          Image.file(
            widget.photo,
            width: MediaQuery.of(context).size.width / 3.7,
            height: MediaQuery.of(context).size.width / 3.7,
      fit: BoxFit.cover,
          )
        ],
      ),
    );
  }
}
