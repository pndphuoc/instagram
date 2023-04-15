import 'package:flutter/material.dart';
import 'package:instagram/models/chat_user.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/message_view_model.dart';
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
  late Stream<List<String>> _getConversationIds;
  final MessageViewModel _messageViewModel = MessageViewModel();
  final double activeAvatarSize = 35;
  final ChatUser fakeData = ChatUser(
      userId: "ccc",
      username: "hiii_chin",
      displayName: "Nguyễn Thùy Chin",
      isOnline: true,
      avatarUrl:
          "https://firebasestorage.googleapis.com/v0/b/instagram-b3812.appspot.com/o/photos%2F1681318354694?alt=media&token=91d18015-746a-4a6b-a9ba-293f5f056a07");
  final searchFieldBorder =
  OutlineInputBorder(borderRadius: BorderRadius.circular(10));
  late Conversation conversation;
  List<Conversation> conversations = [];
  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _getConversationIds = _messageViewModel.getConversationIds(userId: _currentUserViewModel.user!.uid);
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
    return StreamBuilder(
      stream: _getConversationIds,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: Text("No conversation"),);
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()),);
        } else {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => _buildConversationCard(context, snapshot.data![index]));
        }
      }
    );
  }

  Widget _buildConversationCard(BuildContext context, String conversationId) {
    return StreamBuilder(
        stream: _messageViewModel.getConversationData(conversationId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text("No conversation"),);
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()),);
          } else {
            return ConversationCard(conversation: snapshot.data!);
          }
        },);
  }
}
