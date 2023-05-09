import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/like_view_model.dart';
import 'package:instagram/widgets/post_widgets/liked_user_card.dart';

class LikeListScreen extends StatefulWidget {
  final String likeListId;
  const LikeListScreen({Key? key, required this.likeListId}) : super(key: key);

  @override
  State<LikeListScreen> createState() => _LikeListScreenState();
}

class _LikeListScreenState extends State<LikeListScreen> {
  final searchFieldBorder =
  OutlineInputBorder(borderRadius: BorderRadius.circular(10));
  final LikeViewModel _likeViewModel = LikeViewModel();
  late Future _getLikedList;

  @override
  void initState() {
    _getLikedList = _likeViewModel.getLikedByList(widget.likeListId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10,),
              _buildSearchBar(context),
              const SizedBox(height: 10,),
              _buildLikedUserList(context)
            ],
          ),
        ),
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text("Likes", style: Theme.of(context).textTheme.titleLarge,),
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

  Widget _buildLikedUserList(BuildContext context) {
    return FutureBuilder(
        future: _getLikedList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          } else {
            return ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 10,),
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _likeViewModel.likeBy.length,
                itemBuilder: (context, index) => LikedUserCard(userId: _likeViewModel.likeBy[index]),);
          }
        },);
  }


}
