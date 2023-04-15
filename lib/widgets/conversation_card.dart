import 'package:flutter/material.dart';
import 'package:instagram/models/chat_user.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/screens/conversation_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/ultis/ultils.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/widgets/avatar_with_status.dart';
import 'package:provider/provider.dart';

class ConversationCard extends StatefulWidget {
  final Conversation conversation;

  const ConversationCard({Key? key, required this.conversation})
      : super(key: key);

  @override
  State<ConversationCard> createState() => _ConversationCardState();
}

class _ConversationCardState extends State<ConversationCard> {
  final double avatarSize = 30;
  late CurrentUserViewModel _currentUserViewModel;
  late ChatUser restUser;

  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    restUser = widget.conversation.users
        .where((element) => element.userId != _currentUserViewModel.user!.uid)
        .first;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                ConversationScreen(restUser: restUser),
            transitionsBuilder: (context, animation,
                secondaryAnimation, child) {
              return buildSlideTransition(animation, child);
            },
            transitionDuration:
            const Duration(milliseconds: 150),
            reverseTransitionDuration:  const Duration(milliseconds: 150),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Row(
          children: [
            AvatarWithStatus(
                radius: avatarSize,
                imageUrl: restUser.avatarUrl,
                isOnline: true),
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
                        fontWeight: widget.conversation.isSeen
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
                          child: Text(widget.conversation.lastMessageContent,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: widget.conversation.isSeen
                                      ? Colors.grey
                                      : Colors.white,
                                  fontWeight: widget.conversation.isSeen
                                      ? FontWeight.normal
                                      : FontWeight.w600),
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(getElapsedTime(widget.conversation.lastMessageTime),
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
            if (!widget.conversation.isSeen)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                ),
              ),
            if (!widget.conversation.isSeen)
              const SizedBox(
                width: 15,
              ),
            InkWell(
              onTap: () {},
              child: Icon(
                Icons.camera_alt_outlined,
                color: widget.conversation.isSeen ? Colors.grey : Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
