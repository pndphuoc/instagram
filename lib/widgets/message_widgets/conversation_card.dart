import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:instagram/models/user_summary_information.dart';
import 'package:instagram/screens/message_screens/messaging_camera_preview_screen.dart';
import 'package:instagram/screens/post_screens/camera_preview_screen.dart';
import 'package:instagram/view_model/conversation_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/message_view_model.dart';
import 'package:instagram/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

import '../../screens/message_screens/conversation_screen.dart';
import '../../ultis/colors.dart';
import '../../ultis/ultils.dart';
import '../avatar_with_status.dart';
import '../shimmer_widgets/conversation_card_shimmer.dart';

class ConversationCard extends StatelessWidget {
  final String conversationId;

  const ConversationCard({Key? key, required this.conversationId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConversationViewModel conversationViewModel = ConversationViewModel();
    final UserViewModel userViewModel = UserViewModel();
    const double avatarSize = 30;
    late UserSummaryInformation restUser;
    return Consumer<CurrentUserViewModel>(
      builder: (context, value, child) {
        return StreamBuilder(
          stream: conversationViewModel.getConversationData(conversationId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Column(
                children: const [
                  ConversationCardShimmer(),
                  ConversationCardShimmer(),
                  ConversationCardShimmer(),
                ],
              );
            } else if (!snapshot.hasData) {
              return Container();
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              restUser = snapshot.data!.users
                  .where((element) =>
                      element.userId != FirebaseAuth.instance.currentUser!.uid)
                  .first;
              return Slidable(
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    StreamBuilder(
                        stream:
                            conversationViewModel.isTurnOffNotificationStream(
                                conversationId: conversationId),
                        initialData: false,
                        builder: (context, snapshot) {
                          if (snapshot.data!) {
                            return SlidableAction(
                              autoClose: true,
                              onPressed: (context) {
                                conversationViewModel.changeNotificationSetting(
                                    conversationId: conversationId,
                                    isTurnOffNotification: !snapshot.data!);
                              },
                              backgroundColor: mobileBackgroundColor,
                              foregroundColor: Colors.white,
                              icon: Icons.notifications_on_rounded,
                              label: 'Turn on notification',
                            );
                          } else {
                            return SlidableAction(
                              autoClose: true,
                              onPressed: (context) {
                                conversationViewModel.changeNotificationSetting(
                                    conversationId: conversationId,
                                    isTurnOffNotification: !snapshot.data!);
                              },
                              backgroundColor: mobileBackgroundColor,
                              foregroundColor: Colors.white,
                              icon: Icons.notifications_off_rounded,
                              label: 'Turn off notification',
                            );
                          }
                        }),
                    SlidableAction(
                      autoClose: true,
                      onPressed: (context) {},
                      backgroundColor: mobileBackgroundColor,
                      foregroundColor: Colors.red,
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ConversationScreen(restUser: restUser),
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
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    child: Row(
                      children: [
                        StreamBuilder(
                            stream:
                                userViewModel.getOnlineStatus(restUser.userId),
                            builder: (context, snapshot) {
                              return AvatarWithStatus(
                                userId: restUser.userId,
                                radius: avatarSize,
                                imageUrl: restUser.avatarUrl,
                              );
                            }),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restUser.displayName.isNotEmpty
                                    ? restUser.displayName
                                    : restUser.username,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: snapshot.data!.isSeen
                                        ? FontWeight.normal
                                        : FontWeight.w700,
                                    fontSize: 13),
                                overflow: TextOverflow.fade,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Flexible(
                                      child: Text(
                                          snapshot.data!.lastMessageContent,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: snapshot.data!.isSeen
                                                  ? Colors.grey
                                                  : Colors.white,
                                              fontWeight: snapshot.data!.isSeen
                                                  ? FontWeight.normal
                                                  : FontWeight.w600),
                                          overflow: TextOverflow.ellipsis)),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                      getElapsedTime(
                                          snapshot.data!.lastMessageTime),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ))
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        if (!snapshot.data!.isSeen)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor,
                            ),
                          ),
                        if (!snapshot.data!.isSeen)
                          const SizedBox(
                            width: 15,
                          ),
                        StreamBuilder(
                            stream: conversationViewModel
                                .isTurnOffNotificationStream(
                                    conversationId: conversationId),
                            initialData: false,
                            builder: (context, snapshot) {
                              if (snapshot.data!) {
                                return const Icon(
                                  Icons.notifications_off_outlined,
                                  color: Colors.grey,
                                );
                              } else {
                                return Container();
                              }
                            }),
                        const SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            _onCameraTap(context, restUser.username);
                          },
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: snapshot.data!.isSeen
                                ? Colors.grey
                                : Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  _onCameraTap(BuildContext context, String username) {
    availableCameras().then((value) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraPreviewScreen(
              cameras: value,
              isOnlyTakePhoto: false,
              isSendMessage: true,
              username: username),
        ))).then((media) {
      MessageViewModel.onTapSendMediaFromCamera(conversationId: conversationId, file: media[0], isVideo: media[1] == 'video' ? true : false,);
    });
  }
}
