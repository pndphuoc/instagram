import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/post_screens/post_details_screen.dart';
import 'package:instagram/screens/profile_screens/profile_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/contest_details_view_model.dart';
import 'package:instagram/view_model/contest_view_model.dart';
import 'package:provider/provider.dart';

import '../../models/contest.dart';
import '../../models/post.dart';
import '../../ultis/global_variables.dart';

class RankOfContest extends StatefulWidget {
  const RankOfContest({Key? key, required this.contestId, required this.rankingList, }) : super(key: key);
  final String contestId;
  final List<Post> rankingList;
  @override
  State<RankOfContest> createState() => _RankOfContestState();
}

class _RankOfContestState extends State<RankOfContest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildRankingList(context),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text(
        'Ranking',
        style: Theme
            .of(context)
            .textTheme
            .titleLarge,
      ),
    );
  }

  Widget _buildRankingList(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10,),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) {
        if (index >= widget.rankingList.length) {
          return _emptyRank(context, index);
        } else if (index == 0) {
          Post post = widget.rankingList[index];
          return _buildTop1ItemOfRankingList(context,
              username: post.username,
              avatarUrl: post.avatarUrl,
              userId: post.userId,
              postId: post.uid,
              likeCount: post.likeCount);
        } else {
          Post post = widget.rankingList[index];
          return _buildItemOfRankingList(context, avatarUrl: post.avatarUrl,
              username: post.username,
              postId: post.uid,
              rank: index,
              likeCount: post.likeCount);
        }
      },
    );
  }

  Widget _buildTop1ItemOfRankingList(BuildContext context,
      {required String avatarUrl,
        required String userId,
        required String username,
        required String postId,
        required int likeCount}) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromRGBO(246, 223, 87, 1.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              height: 25,
              width: 25,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(152, 153, 156, 0.5)),
              child: Center(
                child: Text(
                  "1",
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium,
                ),
              ),
            ),
            const SizedBox(width: 10,),
            CircleAvatar(
              backgroundImage: avatarUrl.isNotEmpty
                  ? CachedNetworkImageProvider(avatarUrl)
                  : defaultAvatar,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: userId),));
                },
                child: Text(
                  username,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium?.copyWith(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            const SizedBox(width: 5,),
            Text(
              likeCount.toString(),
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium,
            ),
            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailsScreen(postId: postId),));
            }, icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.black,))
          ],
        ),
      ),
    );
  }

  Widget _buildItemOfRankingList(BuildContext context,
      {required String avatarUrl,
        required String username,
        required String postId,
        required int rank,
        required int likeCount}) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: secondaryColor),
      child: Row(
        children: [
          Container(
            height: 25,
            width: 25,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(152, 153, 156, 0.5)),
            child: Center(
              child: Text(
                "${rank + 1}",
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          CircleAvatar(
            backgroundImage: avatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(avatarUrl)
                : defaultAvatar,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              username,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ),
          const Icon(
            Icons.favorite,
            color: Colors.red,
          ),
          const SizedBox(width: 5,),
          Text(
            likeCount.toString(),
            style: Theme
                .of(context)
                .textTheme
                .bodyMedium,
          ),
          IconButton(onPressed: (){}, icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.white,))
        ],
      ),
    );
  }

  Widget _emptyRank(BuildContext context, int rank) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: 70,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: secondaryColor),
      child: Row(
        children: [
          Container(
            height: 25,
            width: 25,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(152, 153, 156, 0.5)),
            child: Center(
              child: Text(
                "${rank + 1}",
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          Text("---", style: Theme.of(context).textTheme.bodyMedium,)
        ],
      ),
    );
  }
}
