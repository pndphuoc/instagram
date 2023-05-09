import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/view_model/relationship_view_model.dart';
import 'package:provider/provider.dart';

import '../../screens/profile_screens/profile_screen.dart';
import '../../ultis/colors.dart';
import '../../ultis/ultils.dart';
import '../../view_model/current_user_view_model.dart';
import '../../view_model/user_view_model.dart';
import '../shimmer_widgets/user_information_shimmer.dart';

class LikedUserCard extends StatefulWidget {
  final String userId;
  const LikedUserCard({Key? key, required this.userId}) : super(key: key);

  @override
  State<LikedUserCard> createState() => _LikedUserCardState();
}

class _LikedUserCardState extends State<LikedUserCard> {
  final UserViewModel _userViewModel = UserViewModel();
  final RelationshipViewModel _relationshipViewModel = RelationshipViewModel();
  late Future _getUserData;
  late Future _isFollowing;

  final double avatarSize = 30;

  @override
  void initState() {
    super.initState();
    _getUserData = _userViewModel.getUserDetails(widget.userId);
    _isFollowing = RelationshipViewModel.isFollowing(FirebaseAuth.instance.currentUser!.uid, widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUserData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const UserInformationShimmer();
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ProfileScreen(userId: widget.userId),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return buildSlideTransition(animation, child);
                  },
                  transitionDuration: const Duration(milliseconds: 150),
                  reverseTransitionDuration: const Duration(milliseconds: 150),
                ),
              );
            },
            child: Container(
              color: Colors.transparent,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: avatarSize,
                    backgroundImage: snapshot.data.avatarUrl.isNotEmpty
                        ? CachedNetworkImageProvider(snapshot.data.avatarUrl)
                        : defaultAvatar,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          snapshot.data.username,
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          snapshot.data.displayName,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                  FutureBuilder(
                      future: _isFollowing,
                      initialData: false,
                      builder: (context, isFollowingSnapshot) {
                        if (widget.userId == FirebaseAuth.instance.currentUser!.uid) {
                          return Container();
                        } else if (isFollowingSnapshot.data!) {
                          return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: secondaryColor),
                              onPressed: () async {
                                _onUnfollowTap(targetUserId: widget.userId, targetUserFollowerListId: snapshot.data!.followerListId);
                              },
                              child: Text(
                                "Following",
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .labelLarge,
                              ));
                        } else {
                          return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.blue),
                              onPressed: () async {
                                _onFollowTap(targetUserId: widget.userId, targetUserFollowerListId: snapshot.data!.followerListId);
                              },
                              child: Text(
                                "Follow",
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .labelLarge,
                              ));
                        }
                      },)
                ],
              ),
            ),
          );
        }
      },
    );
  }

  _onFollowTap(
      {required String targetUserId, required String targetUserFollowerListId}) async {
    final currentUser = context.read<CurrentUserViewModel>();
    await _relationshipViewModel.follow(currentUser.user!.uid, currentUser.user!.followingListId, targetUserId, targetUserFollowerListId);
  }

  _onUnfollowTap(
      {required String targetUserId, required String targetUserFollowerListId}) async {
    final currentUser = context.read<CurrentUserViewModel>();
    await _relationshipViewModel.unfollow(currentUser.user!.uid, currentUser.user!.followingListId, targetUserId, targetUserFollowerListId);
  }
}
