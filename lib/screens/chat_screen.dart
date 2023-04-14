import 'package:flutter/material.dart';
import 'package:instagram/models/chat_user.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/widgets/avatar_with_status.dart';
import 'package:instagram/widgets/conversation_card.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late CurrentUserViewModel _currentUserViewModel;

  final double activeAvatarSize = 35;
  final ChatUser fakeData = ChatUser(
      userId: "ccc",
      username: "hiii_chin",
      displayName: "Nguyễn Thùy Chin",
      isOnline: true,
      avatarUrl:
          "https://firebasestorage.googleapis.com/v0/b/instagram-b3812.appspot.com/o/photos%2F1681318354694?alt=media&token=91d18015-746a-4a6b-a9ba-293f5f056a07");

  late Conversation conversation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    conversation = Conversation(
        uid: "sdfasdf",
        lastMessageContent: "em iu anhhhhh hhhhhhhhhhhh hhhhhhhh hhhhhh hhhhhhhhhhh",
        isSeen: true,
        lastMessageTime: DateTime.now(),
        users: [
          ChatUser(
              userId: "abc",
              username: "hiii_chin",
              displayName: "Nguyễn Thùy Chin",
              isOnline: true,
              avatarUrl:
                  "https://firebasestorage.googleapis.com/v0/b/instagram-b3812.appspot.com/o/photos%2F1681318354694?alt=media&token=91d18015-746a-4a6b-a9ba-293f5f056a07"),
          ChatUser(
              userId: _currentUserViewModel.user!.uid,
              username: _currentUserViewModel.user!.username,
              displayName: _currentUserViewModel.user!.displayName,
              isOnline: true,
              avatarUrl: _currentUserViewModel.user!.avatarUrl)
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context),
            const SizedBox(
              height: 20,
            ),
            _buildActiveFriendList(context),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Messages",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            _buildConversationList(context),
            const SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text(
        _currentUserViewModel.user!.username,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildActiveFriendList(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: activeAvatarSize * 2 + 25,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 20),
        separatorBuilder: (context, index) => const SizedBox(
          width: 20,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) => _buildActiveUser(context, fakeData),
      ),
    );
  }

  Widget _buildActiveUser(BuildContext context, ChatUser user) {
    return SizedBox(
      width: activeAvatarSize * 2,
      height: activeAvatarSize * 2 + 25,
      child: Column(
        children: [
          AvatarWithStatus(
            radius: activeAvatarSize,
            imageUrl: user.avatarUrl,
            isOnline: true,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            user.username,
            style: Theme.of(context).textTheme.labelMedium,
          )
        ],
      ),
    );
  }

  final searchFieldBorder =
      OutlineInputBorder(borderRadius: BorderRadius.circular(10));

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: TextField(
        decoration: InputDecoration(
            hintText: "Search",
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.grey,
            ),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0),
            border: searchFieldBorder,
            enabledBorder: searchFieldBorder,
            focusedBorder: searchFieldBorder,
            disabledBorder: searchFieldBorder,
            filled: true,
            fillColor: secondaryColor),
      ),
    );
  }

  Widget _buildConversationList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) =>
          ConversationCard(conversation: conversation),
    );
  }
}
