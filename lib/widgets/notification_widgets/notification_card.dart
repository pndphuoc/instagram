import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/post_screens/post_details_screen.dart';
import 'package:instagram/screens/profile_screens/profile_screen.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/ultis/ultils.dart';
import 'package:instagram/view_model/relationship_view_model.dart';
import '../../models/notification.dart' as model;
class NotificationCard extends StatelessWidget {
  const NotificationCard({Key? key, required this.notification}) : super(key: key);
  final model.Notification notification;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (notification.type != model.NotificationType.follow) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailsScreen.fromId(notification.postId!),));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: notification.interactiveUserId)));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: notification.interactiveUserAvatarUrl.isNotEmpty ?
              CachedNetworkImageProvider(notification.interactiveUserAvatarUrl) : defaultAvatar,
            ),
            const SizedBox(width: 10,),
            Expanded(
              child: Text.rich(TextSpan(
                children: [
                  WidgetSpan(child: Text(notification.message, style: Theme.of(context).textTheme.bodyMedium,)),
                  const WidgetSpan(child: SizedBox(width: 5,)),
                  WidgetSpan(child: Text(getElapsedTime(notification.updatedAt)))
                ]
              )),
            ),
            notification.type != model.NotificationType.follow ?
                CachedNetworkImage(imageUrl: notification.firstImage!, width: 50, height: 50, fit: BoxFit.cover,) :
                FutureBuilder(
                    future: RelationshipViewModel.isFollowing(FirebaseAuth.instance.currentUser!.uid, notification.interactiveUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(),);
                      } else if (snapshot.hasData) {
                        if (!snapshot.data!) {
                          return ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7)
                              )
                          ), child: const Text("Follow"));
                        } else {
                          return ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7)
                            )
                          ), child: const Text("Unfollow"));
                        }
                      } else {
                        return Center(child: Text(snapshot.error.toString()),);
                      }
                    },)
          ],
        ),
      ),
    );
  }
}
