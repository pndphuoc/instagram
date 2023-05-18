import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/profile_screens/profile_screen.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/user_view_model.dart';
import 'package:instagram/widgets/shimmer_widgets/user_information_shimmer.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../ultis/colors.dart';
import '../../ultis/ultils.dart';
import '../../view_model/relationship_view_model.dart';
import '../common_widgets/confirm_dialog.dart';

class FollowerCard extends StatefulWidget {
  final String userId;
  final RelationshipViewModel relationshipViewModel;
  const FollowerCard({Key? key, required this.userId, required this.relationshipViewModel}) : super(key: key);

  @override
  State<FollowerCard> createState() => _FollowerCardState();
}

class _FollowerCardState extends State<FollowerCard> {
  final UserViewModel _userViewModel = UserViewModel();
  late Future _getUserData;
  final double avatarSize = 30;

  @override
  void initState() {
    super.initState();
    _getUserData = _userViewModel.getUserDetails(widget.userId);
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
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: avatarSize,
                    backgroundImage: snapshot.data.avatarUrl.isNotEmpty
                        ? CachedNetworkImageProvider(snapshot.data.avatarUrl)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
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
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          snapshot.data.displayName,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                  Consumer<CurrentUserViewModel>(
                    builder: (context, currentUser, child) {
                      return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: secondaryColor),
                          onPressed: () async {
                            _onTap(currentUser.user!, snapshot);
                          },
                          child: Text(
                            "Delete",
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black87),
                          ));
                    },
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }

  _onTap(User currentUser, final snapshot) async {
    bool? result = await showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        confirmButtonText: "Delete",
        confirmText: "Delete this follower?",
        description:
        "instagram won't let ${snapshot.data.username} know you removed them from your follower list",
        imageUrl: snapshot.data.avatarUrl,
      ),
    );

    if (result == true) {
      widget.relationshipViewModel.unfollow(
          snapshot.data.uid,
          snapshot.data.followingListId,
          currentUser.uid,
          currentUser.followerListId);
      widget.relationshipViewModel.followerIds.remove(snapshot.data.uid);
    }
  }
}
