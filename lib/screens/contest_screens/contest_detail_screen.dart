import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/contest_screens/contest_entries_screen.dart';
import 'package:instagram/view_model/contest_details_view_model.dart';
import 'package:instagram/widgets/common_widgets/bottom_navigator_bar.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

import '../../models/contest.dart';
import '../contest_screens/rank_of_contest_screen.dart';

class ContestDetailScreen extends StatelessWidget {
  const ContestDetailScreen({Key? key, required this.contest})
      : super(key: key);
  final Contest contest;

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<ContestDetailsViewModel>(
      create: (context) => ContestDetailsViewModel(contestId: contest.uid!),
      builder: (context, child) => Consumer<ContestDetailsViewModel>(
        builder: (context, value, child) => Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    leading: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    pinned: true,
                    expandedHeight: 200.0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: CachedNetworkImage(
                        imageUrl: contest.banner,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  buildSliverHeaderBody(context),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(width: 1, color: Colors.grey))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ReadMoreText(
                            contest.description,
                            trimLines: 5,
                            trimMode: TrimMode.Line,
                            trimCollapsedText: ' Show more',
                            trimExpandedText: ' Show less',
                            style: Theme.of(context).textTheme.titleSmall,
                            moreStyle: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                            lessStyle: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  buildListTileItem(context,
                      title: 'Rules',
                      onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16))),
                            builder: (context) => SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Column(children: [
                                IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Ionicons.chevron_down)),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(contest.rules!),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          )),
                  buildListTileItem(context, title: 'Leaderboard', onTap: () {
                    value.getTop10PostOfContest().whenComplete(() => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RankOfContest(
                              contestId: contest.uid!,
                              rankingList: value.top10PostOfContest)),
                    ));

                  }),
                  buildListTileItem(context,
                      title: 'Prize details', onTap: () {}),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100,
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ContestEntriesScreen(contestId: contest.uid!, contestName: contest.name),));
                        },
                        child: Container(
                            color: const Color.fromRGBO(179, 204, 227, 1.0),
                            height: 60,
                            child: Center(
                                child: Text(
                              'Entries'.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                            ))),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                            color: const Color.fromRGBO(246, 200, 200, 1.0),
                            height: 60,
                            child: Center(
                                child: Text(
                              'Join the contest'.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                            ))),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          bottomNavigationBar: const BottomNavBar(),
        ),
      ),
    );
  }

  SliverToBoxAdapter buildListTileItem(BuildContext context,
      {required String title, VoidCallback? onTap}) {
    return SliverToBoxAdapter(
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        trailing: IconButton(
          onPressed: onTap,
          icon: const Icon(Ionicons.chevron_forward),
        ),
      ),
    );
  }

  SliverToBoxAdapter buildSliverHeaderBody(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    contest.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (contest.status == ContestStatus.inProgress['status'])
                    ? Colors.green
                    : (contest.status == ContestStatus.upcoming['status'])
                        ? Colors.amber
                        : Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                contest.status,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            Text.rich(TextSpan(
                text: 'Topic: ',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                children: <InlineSpan>[
                  TextSpan(
                    text: contest.topic,
                    style: Theme.of(context).textTheme.titleSmall,
                  )
                ])),
            const SizedBox(height: 8),
            Text.rich(TextSpan(
                text: 'Time event: ',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                children: <InlineSpan>[
                  TextSpan(
                    text:
                        '${DateFormat('yyyy-MM-dd').format(contest.startTime)} • ${DateFormat('yyyy-MM-dd').format(contest.endTime)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  )
                ])),
            const SizedBox(height: 8),
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(
                      'https://cdn-icons-png.flaticon.com/512/149/149071.png'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Người nhà đài',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
