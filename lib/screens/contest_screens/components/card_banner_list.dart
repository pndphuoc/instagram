import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/contest.dart';
import 'package:instagram/view_model/common_contest_view_model.dart';
import 'package:provider/provider.dart';

import '../contest_detail_screen.dart';

class ContestTab extends StatefulWidget {
  const ContestTab({Key? key, required this.typeOfContest}) : super(key: key);
  final String typeOfContest;
  @override
  State<ContestTab> createState() => _ContestTabState();
}

class _ContestTabState extends State<ContestTab> {

  @override
  Widget build(BuildContext context) {
    return Selector<CommonContestViewModel, List<Contest>>(
      selector: (context, contestViewModel) {
        if (widget.typeOfContest == ContestStatus.upcoming['status']) {
          return contestViewModel.upcomingContests;
        } else if (widget.typeOfContest == ContestStatus.inProgress['status']) {
          return contestViewModel.progressingContests;
        } else {
          return contestViewModel.expiredContests;
        }
      },
      builder: (context, list, child) {
        return ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 10,),
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) => buildCardBannerItem(context,
              contest: list[index]),
          itemCount: list.length,
        );
      },
    );
  }

  Widget buildCardBannerItem(BuildContext context, {required Contest contest}) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ContestDetailScreen(contest: contest),));
      },
      child: AspectRatio(
        aspectRatio: 16/9,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(contest.banner),
                      fit: BoxFit.cover)),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.all(8),
                child: Text(
                  contest.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
