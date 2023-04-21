import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/message_view_model.dart';
import 'package:instagram/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class AvatarWithStatus extends StatelessWidget {
  final String userId;
  final String imageUrl;
  final double radius;
  final bool? isOnline;

  const AvatarWithStatus(
      {Key? key,
      required this.radius,
      required this.imageUrl,
      required this.userId, this.isOnline = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserViewModel userViewModel = UserViewModel();
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: imageUrl.isNotEmpty
              ? CachedNetworkImageProvider(imageUrl)
              : const AssetImage('assets/default_avatar.png') as ImageProvider,
        ),
        StreamBuilder(
          stream: userViewModel.getOnlineStatus(userId),
          builder: (context, snapshot) {
            if (snapshot.data == 'Online') {
              return Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                        border: Border.fromBorderSide(
                            BorderSide(color: mobileBackgroundColor, width: 2))),
                    width: radius / 2,
                    height: radius / 2,
                  ));
            } else {
              return Container();
            }
          },
        )
      ],
    );
  }
}
