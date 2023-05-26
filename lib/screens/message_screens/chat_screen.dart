import 'package:flutter/material.dart';
import 'package:instagram/models/user_summary_information.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/conversation_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/widgets/animation_widgets/show_right.dart';
import 'package:instagram/widgets/common_widgets/avatar_with_status.dart';
import 'package:instagram/widgets/message_widgets/conversation_card.dart';
import 'package:instagram/widgets/shimmer_widgets/conversation_card_shimmer.dart';
import 'package:provider/provider.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late CurrentUserViewModel _currentUserViewModel;
  late Stream<List<String>> _getConversationIds;
  final ConversationViewModel _conversationViewModel = ConversationViewModel();
  final double activeAvatarSize = 35;
  final searchFieldBorder =
      OutlineInputBorder(borderRadius: BorderRadius.circular(10));
  late Conversation conversation;
  List<Conversation> conversations = [];

  @override
  void initState() {
    super.initState();
    _currentUserViewModel = context.read<CurrentUserViewModel>();
    _getConversationIds = _conversationViewModel.getConversationIds(
        userId: _currentUserViewModel.user!.uid);
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
            //_buildActiveFriendList(context),
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
            const SizedBox(
              height: 20,
            )
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
            fillColor: Colors.white38),
      ),
    );
  }

  Widget _buildConversationList(BuildContext context) {
    return StreamBuilder(
        stream: _getConversationIds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
            return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => ShowRight(
                  delay: 100 * index,
                  child: ConversationCard(
                        conversationId: snapshot.data![index],
                      ),
                ));
          }
        });
  }
}
