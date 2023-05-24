import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/notification_view_model.dart';
import 'package:instagram/widgets/animation_widgets/show_right.dart';
import 'package:instagram/widgets/notification_widgets/notification_card.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: ListenableProvider<NotificationViewModel>(
          create: (_) => NotificationViewModel(userId: FirebaseAuth.instance.currentUser!.uid),
          child: Consumer<NotificationViewModel>(
            builder: (context, value, child) {
              switch (value.isLoading) {
                case false:
                  return ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(height: 10,),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: value.notifications.length,
                    itemBuilder: (context, index) => NotificationCard(notification: value.notifications[index]),);
                default:
                  return const Center(child: CircularProgressIndicator(),);
              }
            }
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text("Notifications", style: Theme.of(context).textTheme.titleLarge,),
    );
  }
}
