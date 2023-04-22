import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_summary_information.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/models/message.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/conversation_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/message_view_model.dart';
import 'package:instagram/view_model/user_view_model.dart';
import 'package:instagram/widgets/avatar_with_status.dart';
import 'package:instagram/widgets/message_widgets/received_message_card.dart';
import 'package:instagram/widgets/message_widgets/sending_image_message.dart';
import 'package:instagram/widgets/message_widgets/sent_message_card.dart';
import 'package:instagram/widgets/shimmer_widgets/message_shimmer.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../widgets/image_thumbail.dart';

class ConversationScreen extends StatefulWidget {
  final UserSummaryInformation restUser;

  const ConversationScreen({Key? key, required this.restUser})
      : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final double avatarSize = 20;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late MessageViewModel _messageViewModel;
  final ConversationViewModel _conversationViewModel = ConversationViewModel();
  final TextEditingController _messageController = TextEditingController();
  final UserViewModel _userViewModel = UserViewModel();
  late CurrentUserViewModel _currentUserViewModel;
  late String conversationId;
  late Stream<Conversation> _getConversationData;
  final ScrollController _scrollController = ScrollController();
  late Stream<DateTime?> _lastSeenMessageTimeStream;
  late Future<DateTime?> _getLastSeenMessageTime;
  final double _crossAxisSpacing = 2;
  final double _mainAxisSpacing = 2;
  final double _childAspectRatio = 1;
  final _gridViewCrossAxisCount = 3;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageViewModel.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _currentUserViewModel = context.read<CurrentUserViewModel>();

    _messageViewModel =
        MessageViewModel([widget.restUser, _currentUserViewModel.chatUser]);

    _lastSeenMessageTimeStream = _messageViewModel.lastSeenMessageTimeStream;

    _getLastSeenMessageTime = _messageViewModel.getLastSeenMessageTime();

    _getConversationData = _conversationViewModel
        .getConversationData(_messageViewModel.conversationId);

    //_getMessages = _messageViewModel.getMessages();

    _messageViewModel.firstLoading();

    super.initState();
  }

  double _calculateItemHeight(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth =
        (screenWidth - _crossAxisSpacing * (_gridViewCrossAxisCount - 1)) /
            _gridViewCrossAxisCount;
    double itemHeight = itemWidth / _childAspectRatio + _mainAxisSpacing;
    return itemHeight;
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
            builder: (context, conversationSnapshot) {
              if (conversationSnapshot.hasData) {
                return StreamBuilder(
                  stream: _messageViewModel.messagesStream,
                  builder: (context, messageSnapshot) {
                    if (messageSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (!messageSnapshot.hasData) {
                      return Container();
                    } else if (messageSnapshot.hasError) {
                      return Center(
                        child: Text(messageSnapshot.error.toString()),
                      );
                    } else {
                      //_messageViewModel.messages.addAll(messageSnapshot.data!);
                      return ListView.separated(
                        controller: _messageViewModel.scrollController,
                        cacheExtent: 2000,
                        reverse: true,
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 5,
                        ),
                        itemCount: _messageViewModel.messages.length,
                        itemBuilder: (context, index) {
                          if (_messageViewModel.messages[index].senderId ==
                              _auth.currentUser!.uid) {
                            return FutureBuilder(
                                future: _getLastSeenMessageTime,
                                builder: (context, lastSeenSnapshot) {
                                  if (lastSeenSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const MessageShimmer(isOwnMessage: true);
                                  } else if (lastSeenSnapshot.hasData) {
                                    return StreamBuilder(
                                        stream: _messageViewModel.lastSeenMessageTimeStream,
                                        initialData: lastSeenSnapshot.data!,
                                        builder: (context, snapshot) {
                                          print("heheheh ${snapshot.data!}");
                                          if (snapshot.data == null) {
                                            return SentMessageCard(
                                              message: _messageViewModel
                                                  .messages[index],
                                              restUserAvatarUrl:
                                                  widget.restUser.avatarUrl,
                                            );
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                snapshot.error.toString());
                                          } else {
                                            return SentMessageCard(
                                              message: _messageViewModel
                                                  .messages[index],
                                              lastSeenMessageTimeOfRestUser:
                                                  snapshot.data!,
                                              restUserAvatarUrl:
                                                  widget.restUser.avatarUrl,
                                            );
                                          }
                                        });
                                  } else {
                                    return Container();
                                  }
                                });
                          } else {
                            return ReceivedMessageCard(
                                message: _messageViewModel.messages[index],
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
          _buildSendingMessage(context),
          _buildWriteMessage(context)
        ],
      ),
    );
  }

  Widget _buildSendingMessage(BuildContext context) {
    return StreamBuilder(
      stream: _messageViewModel.sendingMessageStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              height: 30,
              width: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: Text("Sending (${snapshot.data!.length}) medias",
                    style: const TextStyle(color: Colors.black)),
              ),
              //child: SendingImageMessage(image: ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Row(
        children: [
          AvatarWithStatus(
            userId: widget.restUser.userId,
            radius: avatarSize,
            imageUrl: widget.restUser.avatarUrl,
          ),
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
                StreamBuilder(
                    stream:
                        _userViewModel.getOnlineStatus(widget.restUser.userId),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? widget.restUser.username,
                        style: Theme.of(context).textTheme.labelMedium,
                      );
                    })
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
                    children: [
                      GestureDetector(
                          onTap: _showMediasSelector,
                          child: const Icon(Icons.photo_outlined,
                              color: Colors.white, size: 30)),
                      const SizedBox(
                        width: 10,
                      ),
                      const Icon(
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

  _showMediasSelector() {
    return showModalBottomSheet(
      enableDrag: true,
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20))),
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 1,
          minChildSize: 0.5,
          expand: true,
          builder: (context, scrollController) {
            return Container(
              color: secondaryColor,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: GestureDetector(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _messageViewModel.selectedPath.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(Icons.keyboard_arrow_up)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(child: _mediasGrid(context, scrollController)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _mediasGrid(BuildContext context, ScrollController scrollController) {
    double itemHeight = _calculateItemHeight(context);
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        const double threshold = 0.5; // 90% of the list length
        final double extentAfter = scrollNotification.metrics.extentAfter;
        final double maxScrollExtent =
            scrollNotification.metrics.maxScrollExtent;
        if (scrollNotification is ScrollEndNotification &&
            extentAfter / maxScrollExtent < threshold &&
            _messageViewModel.hasMoreToLoad) {
          _messageViewModel.loadAssetsOfPath();
          _messageViewModel.page++;
        }
        return true;
      },
      child: StreamBuilder<List<AssetEntity>>(
          stream: _messageViewModel.selectedEntitiesStream,
          initialData: const [],
          builder: (context, snapshot) {
            return Stack(
              children: [
                GridView.builder(
                  cacheExtent: 500,
                  controller: scrollController,
                  itemCount: _messageViewModel.entities.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridViewCrossAxisCount,
                      mainAxisSpacing: _mainAxisSpacing,
                      crossAxisSpacing: _crossAxisSpacing,
                      childAspectRatio: _childAspectRatio),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        scrollController.animateTo(
                            index ~/ _gridViewCrossAxisCount * itemHeight,
                            curve: Curves.bounceInOut,
                            duration: const Duration(milliseconds: 200));
                        _messageViewModel
                            .onTapMedia(_messageViewModel.entities[index]);
                      },
                      child: Stack(
                        children: [
                          ImageItemWidget(
                            entity: _messageViewModel.entities[index],
                            option: const ThumbnailOption(
                              size: ThumbnailSize(300, 300),
                            ),
                          ),
                          if (snapshot.data!.isEmpty ||
                              !snapshot.data!
                                  .contains(_messageViewModel.entities[index]))
                            Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                  height: 25,
                                  width: 25,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.fromBorderSide(BorderSide(
                                          color: Colors.white, width: 1)),
                                      color: blueColor),
                                ))
                          else
                            Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                  height: 25,
                                  width: 25,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.fromBorderSide(BorderSide(
                                          color: Colors.white, width: 1)),
                                      color: Colors.blue),
                                  child: Center(
                                      child: Text((_messageViewModel
                                                  .selectedEntities
                                                  .indexOf(_messageViewModel
                                                      .entities[index]) +
                                              1)
                                          .toString())),
                                ))
                        ],
                      ),
                    );
                  },
                ),
                if (snapshot.data!.isNotEmpty)
                  Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            _messageViewModel.onTapSendImageMessages();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          child: Text(
                            "Send",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ))
              ],
            );
          }),
    );
  }
}
