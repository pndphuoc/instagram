import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/provider/home_screen_provider.dart';
import 'package:instagram/route/route_name.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/asset_view_model.dart';
import 'package:instagram/view_model/post_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/widgets/image_thumbail.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';

class AddCaptionScreen extends StatefulWidget {
  const AddCaptionScreen({Key? key}) : super(key: key);

  @override
  State<AddCaptionScreen> createState() => _AddCaptionScreenState();
}

class _AddCaptionScreenState extends State<AddCaptionScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final double previewMediaSize = MediaQuery.of(context).size.width / 6;
    return Scaffold(
      appBar: _appBar(context),
      body: Container(
        color: mobileBackgroundColor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: CachedNetworkImageProvider(
                      "https://firebasestorage.googleapis.com/v0/b/instagram-b3812.appspot.com/o/unnamed.jpg?alt=media&token=ceed00bc-6ebb-4b51-9dc8-6e0d95707fd2"),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    minLines: 3,
                    decoration: const InputDecoration(
                        hintText: "Write caption",
                        contentPadding: EdgeInsets.all(5),
                        filled: true,
                        fillColor: postCardBackgroundColor,
                        disabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide.none)),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Consumer<AssetViewModel>(
                  builder: (context, value, child) => SizedBox(
                    height: previewMediaSize,
                    width: previewMediaSize,
                    child: ImageItemWidget(
                        entity: value.selectedEntities.isEmpty
                            ? value.selectedEntity!
                            : value.selectedEntities.first,
                        option: const ThumbnailOption(
                            size: ThumbnailSize.square(100))),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _uploadNewPost(BuildContext context) {
    final user = context.read<CurrentUserViewModel>();
    final asset = context.read<AssetViewModel>();
    context.read<HomeScreenProvider>().currentIndex = 0;
    asset.firstAsset = asset.selectedEntities.isEmpty
        ? asset.selectedEntity
        : asset.selectedEntities.first;
    Navigator.popUntil(context, (route) => route.isFirst);
    Post post = Post(
        caption: _controller.text,
        userId: _auth.currentUser!.uid,
        username: user.user!.username,
        avatarUrl: user.user!.avatarUrl,
        likeCount: 0,
        commentCount: 0,
        createAt: DateTime.now(),
        mediaUrls: [],
        uid: '',
        commentListId: '',
        isDeleted: false,
        likedListId: '',
        updateAt: DateTime.now(),
        viewedListId: '');

    context.read<PostViewModel>().handleUploadNewPost(post, asset);
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text(
        "Add caption",
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      actions: [
        GestureDetector(
          onTap: () async {
            _uploadNewPost(context);
          },
          child: const SizedBox(
            height: kToolbarHeight,
            width: kToolbarHeight,
            child: Icon(
              Icons.done_outlined,
              color: Colors.blue,
              size: 30,
            ),
          ),
        )
      ],
    );
  }
}
