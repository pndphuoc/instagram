import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/ultis/ultils.dart';
import '../../models/notification.dart' as model;
class NotificationCard extends StatelessWidget {
  const NotificationCard({Key? key, required this.notification}) : super(key: key);
  final model.Notification notification;
  @override
  Widget build(BuildContext context) {
    return Container(
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
              CachedNetworkImage(imageUrl: notification.firstImage, width: 50, height: 50,) :
              ElevatedButton(onPressed: (){}, child: const Text("Follow back"))
        ],
      ),
    );
  }
}
