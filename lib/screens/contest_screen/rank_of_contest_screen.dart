import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/contest_details_view_model.dart';
import 'package:instagram/view_model/contest_view_model.dart';
import 'package:provider/provider.dart';

import '../../models/contest.dart';
import '../../models/post.dart';
import '../../ultis/global_variables.dart';

class RankOfContest extends StatefulWidget {
  const RankOfContest({Key? key, required this.contestId, required this.contestDetailsViewModel}) : super(key: key);
  final String contestId;
  final ContestDetailsViewModel contestDetailsViewModel;
  @override
  State<RankOfContest> createState() => _RankOfContestState();
}

class _RankOfContestState extends State<RankOfContest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Selector<ContestDetailsViewModel, Contest?>(
        selector: (context, contestDetailViewMode) =>
        contestDetailViewMode.contestDetails,
        builder: (context, contest, child) =>
        contest == null
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  contest.name,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineSmall,
                ),
              ],
            ),
          ),
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

  Widget _buildRankingList(BuildContext context,
      ContestDetailsViewModel contestDetailsViewModel) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        if (index > contestDetailsViewModel.top10PostOfContest.length) {
          return _emptyRank(context, index);
        } else if (index == 0) {
          Post post = contestDetailsViewModel.top10PostOfContest[index];
          return _buildTop1ItemOfRankingList(context,
              username: post.username,
              avatarUrl: post.avatarUrl,
              postId: post.uid,
              likeCount: post.likeCount);
        } else {
          Post post = contestDetailsViewModel.top10PostOfContest[index];
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
        required String username,
        required String postId,
        required int likeCount}) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromRGBO(246, 223, 87, 1.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(152, 153, 156, 1.0)),
              child: Text(
                "1",
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge,
              ),
            ),
            CircleAvatar(
              backgroundImage: avatarUrl.isNotEmpty
                  ? CachedNetworkImageProvider(avatarUrl)
                  : defaultAvatar,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              username,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium,
            ),
            const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            Text(
              likeCount.toString(),
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium,
            ),
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
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: secondaryColor),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(152, 153, 156, 1.0)),
            child: Text(
              "1",
              style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge,
            ),
          ),
          CircleAvatar(
            backgroundImage: avatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(avatarUrl)
                : defaultAvatar,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            username,
            style: Theme
                .of(context)
                .textTheme
                .bodyMedium,
          ),
          const Icon(
            Icons.favorite,
            color: Colors.red,
          ),
          Text(
            likeCount.toString(),
            style: Theme
                .of(context)
                .textTheme
                .bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _emptyRank(BuildContext context, int index) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: secondaryColor),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(152, 153, 156, 1.0)),
            child: Text(
              index.toString(),
              style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge,
            ),
          ),
          const SizedBox(width: 10,),
          Text("---", style: Theme.of(context).textTheme.bodyMedium,)
        ],
      ),
    );
  }
}
