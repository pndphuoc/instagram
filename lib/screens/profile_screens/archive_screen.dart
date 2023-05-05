import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/post_screens/post_details_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:provider/provider.dart';

import '../../ultis/ultils.dart';
import '../../widgets/post_widgets/video_player_widget.dart';
import '../post_screens/post_list_screen.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({Key? key}) : super(key: key);

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late CurrentUserViewModel _currentUserViewModel;
  late Future _getArchivedPosts;
  @override
  void initState() {
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _getArchivedPosts = _currentUserViewModel.getArchivedPosts(FirebaseAuth.instance.currentUser!.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: _postGrid(context),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text("Posts archives", style: Theme.of(context).textTheme.titleLarge,),
    );
  }

  Widget _postGrid(BuildContext context) {
    return FutureBuilder(
        future: _getArchivedPosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()),);
          } else {
            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentUserViewModel.archivedPost.length,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 1),
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              PostDetailsScreen(post:_currentUserViewModel.archivedPost[index]),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return buildSlideTransition(animation, child);
                          },
                          transitionDuration: const Duration(milliseconds: 150),
                          reverseTransitionDuration:
                          const Duration(milliseconds: 150),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        if (_currentUserViewModel.archivedPost[index].medias.first.type == 'image')
                          CachedNetworkImage(
                            imageUrl: _currentUserViewModel.archivedPost[index].medias.first.url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            fadeInDuration: const Duration(milliseconds: 100),
                          )
                        else
                          Positioned.fill(
                            child: VideoPlayerWidget.network(
                              url: _currentUserViewModel.archivedPost[index].medias.first.url,
                              isPlay: false,
                            ),
                          ),
                        if (_currentUserViewModel.archivedPost[index].medias.length > 1)
                          const Positioned(
                              top: 5,
                              right: 5,
                              child: Icon(
                                Icons.layers_rounded,
                                color: Colors.white,
                              ))
                        else if (_currentUserViewModel.archivedPost[index].medias.first.type == 'video')
                          const Positioned(
                              top: 5,
                              right: 5,
                              child: Icon(
                                Icons.slow_motion_video_rounded,
                                color: Colors.white,
                              ))
                      ],
                    ));
              },
            );
          }
        },);
  }
}
