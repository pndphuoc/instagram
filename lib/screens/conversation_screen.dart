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
  final Conversation? conversation;
  final ChatUser restUser;

  const ConversationScreen(
      {Key? key, this.conversation, required this.restUser})
      : super(key: key);

  factory ConversationScreen.fromProfileScreen(
      {required String conversationId, required ChatUser restUser}) {
    return ConversationScreen(restUser: restUser);
  }

  factory ConversationScreen.fromChatScreen(
      {required Conversation conversation, required ChatUser restUser}) {
    return ConversationScreen(
      restUser: restUser,
      conversation: conversation,
    );
  }

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final double avatarSize = 20;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MessageViewModel _messageViewModel = MessageViewModel();
  final TextEditingController _messageController = TextEditingController();
  late CurrentUserViewModel _currentUserViewModel;
  List<Message> messages = [];
  List<ChatUser> users = [];
  late Conversation conversation;
  late Future _getConversationId;
  String conversationId = '';

  @override
  void initState() {
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    users.addAll([
      widget.restUser,
      ChatUser(
          userId: _auth.currentUser!.uid,
          username: _currentUserViewModel.user!.username,
          avatarUrl: _currentUserViewModel.user!.avatarUrl,
          displayName: _currentUserViewModel.user!.displayName,
          isOnline: true)
    ]);
    _getConversationId = _messageViewModel.getConversationId(
    _auth.currentUser!.uid, widget.restUser.userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context),
      body: Stack(children: [
        SizedBox(
          child: Column(
            children: [
              Expanded(
                  child: widget.conversation == null
                      ? FutureBuilder(
                          future: _getConversationId,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text(snapshot.error.toString()),
                              );
                            } else {
                              conversationId = snapshot.data;
                              return StreamBuilder(
                                  stream: _messageViewModel.getMessage(conversationId),
                                  builder: (context, streamSnapshot) {
                                    if (streamSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (streamSnapshot.hasError) {
                                      return Center(
                                        child: Text(streamSnapshot.error.toString()),
                                      );
                                    } else if (streamSnapshot.hasData) {
                                      return ListView.separated(
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(
                                                height: 10,
                                              ),
                                          padding: const EdgeInsets.only(
                                              bottom: 40, left: 10, right: 10),
                                          reverse: true,
                                          itemCount: (streamSnapshot.data as List<Message>).length,
                                          itemBuilder: (context, index) {
                                            if ((streamSnapshot.data as List<Message>)[index].senderId ==
                                                _auth.currentUser!.uid) {
                                              return SentMessageCard(
                                                  message: (streamSnapshot.data as List<Message>)[index]);
                                            } else {
                                              return ReceivedMessageCard(
                                                  message: (streamSnapshot.data as List<Message>)[index],
                                                  user: widget.restUser);
                                            }
                                          });
                                    } else {
                                      return Container();
                                    }
                                  });
                            }
                          },
                        )
                      : StreamBuilder<Object>(
                          stream: _messageViewModel
                              .getMessage(widget.conversation!.uid),
                          builder: (context, snapshot) {
                            conversationId = widget.conversation!.uid;
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text(snapshot.error.toString()),
                              );
                            } else if (snapshot.hasData) {
                              messages.addAll(snapshot.data as List<Message>);
                              return ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(
                                        height: 10,
                                      ),
                                  padding: const EdgeInsets.only(
                                      bottom: 40, left: 10, right: 10),
                                  reverse: true,
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    if (messages[index].senderId ==
                                        _auth.currentUser!.uid) {
                                      return SentMessageCard(
                                          message: messages[index]);
                                    } else {
                                      return ReceivedMessageCard(
                                          message: messages[index],
                                          user: widget.restUser);
                                    }
                                  });
                            } else {
                              return Container();
                            }
                          })),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 35,
                color: mobileBackgroundColor,
              )
            ],
          ),
        ),
        Positioned(
            bottom: 0, right: 0, left: 0, child: _buildWriteMessage(context))
      ]),
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
              isOnline: widget.restUser.isOnline!),
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
                  widget.restUser.isOnline!
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
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                if (snapshot.data!.isEmpty) {
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
/*                      late String conversationId;
                      if (widget.conversation == null) {
                        conversationId =
                            await _messageViewModel.createConversation(users);
                      }*/
                      if (conversationId.isEmpty) {
                        conversationId = await _messageViewModel.createConversation(users);
                      }
                      await _messageViewModel.sendMessage(
                          conversationId: conversationId,
                          senderId: _currentUserViewModel.user!.uid,
                          messageType: 'text',
                          messageContent: _messageController.text,
                          timestamp: DateTime.now());
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
