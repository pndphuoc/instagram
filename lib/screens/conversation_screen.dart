import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/chat_user.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/models/message.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/message_view_model.dart';
import 'package:instagram/widgets/avatar_with_status.dart';
import 'package:instagram/widgets/received_message_card.dart';
import 'package:instagram/widgets/sent_message_card.dart';
import 'package:provider/provider.dart';

class ConversationScreen extends StatefulWidget {
  final ChatUser restUser;

  const ConversationScreen({Key? key, required this.restUser})
      : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final double avatarSize = 20;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MessageViewModel _messageViewModel = MessageViewModel();
  final TextEditingController _messageController = TextEditingController();
  late CurrentUserViewModel _currentUserViewModel;
  late String conversationId;
  late Stream<Conversation> _getConversationData;
  late Stream<List<Message>> _getMessages;
  @override
  void initState() {
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _messageViewModel.users
        .addAll([widget.restUser, _currentUserViewModel.chatUser]);
    _messageViewModel.createConversationIdFromUsers();
    _getConversationData = _messageViewModel.getConversationData(_messageViewModel.conversationId);
    _getMessages = _messageViewModel.getMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
            stream: _getConversationData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return StreamBuilder(
                  stream: _getMessages,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return ListView.separated(
                        reverse: true,
                        separatorBuilder: (context, index) => const SizedBox(height: 5,),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          if (!snapshot.hasData) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(snapshot.error.toString()),
                            );
                          } else if (snapshot.data![index].senderId ==
                              _auth.currentUser!.uid) {
                            return SentMessageCard(
                                message: snapshot.data![index]);
                          } else {
                            return ReceivedMessageCard(
                                message: snapshot.data![index],
                                user: widget.restUser);
                          }
                        },
                      );
                  }
                  },
                );
              } else {
                return const Center(
                  child: Text("Let's chat to each other"),
                );
              }
            },
          )),
          _buildWriteMessage(context)
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Row(
        children: [
          AvatarWithStatus(
              radius: avatarSize,
              imageUrl: widget.restUser.avatarUrl,
              isOnline: false),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.restUser.displayName.isNotEmpty
                      ? widget.restUser.displayName
                      : widget.restUser.username,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  widget.restUser.isOnline == null || widget.restUser.isOnline!
                      ? "Online"
                      : widget.restUser.username,
                  style: Theme.of(context).textTheme.labelMedium,
                )
              ],
            ),
          )
        ],
      ),
      actions: const [
        Icon(
          Icons.phone_outlined,
          color: Colors.white,
        ),
        SizedBox(
          width: 10,
        ),
        Icon(
          Icons.video_camera_front_outlined,
          color: Colors.white,
        ),
        SizedBox(
          width: 20,
        )
      ],
    );
  }

  Widget _buildWriteMessage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
          color: const Color.fromRGBO(65, 65, 65, 1.0),
          borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor,
            ),
            width: 40,
            height: 40,
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextField(
              onChanged: (value) {
                _messageViewModel.onChange(value);
              },
              maxLines: null,
              controller: _messageController,
              decoration: const InputDecoration(
                  hintText: "Texting",
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          StreamBuilder<String>(
              stream: _messageViewModel.writingMessageStream,
              initialData: '',
              builder: (context, snapshot) {
                if (snapshot.data!.trim().isEmpty) {
                  return Row(
                    children: const [
                      Icon(Icons.photo_outlined, color: Colors.white, size: 30),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  );
                } else {
                  return GestureDetector(
                    onTap: () async {
                      if (_messageController.text.trim().isNotEmpty) {
                        _messageViewModel.sendTextMessage(
                            senderId: _auth.currentUser!.uid,
                            messageType: 'text',
                            messageContent: _messageController.text.trim(),
                            timestamp: DateTime.now());
                        _messageController.clear();
                      }
                    },
                    child: const Text("Send",
                        style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 17)),
                  );
                }
              }),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
