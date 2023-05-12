import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/contest_screens/contest_detail_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/manage_contest_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/contest.dart';

class PersonalContestsScreen extends StatefulWidget {
  const PersonalContestsScreen({Key? key}) : super(key: key);

  @override
  State<PersonalContestsScreen> createState() => _PersonalContestsScreenState();
}

class _PersonalContestsScreenState extends State<PersonalContestsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late Future _getJoinedContest;
  late Future _getOwnContest;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ListenableProvider<ManageContestViewModel>(
      create: (context) => ManageContestViewModel(FirebaseAuth.instance.currentUser!.uid),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildJoinedContest(context),
            _buildOwnContest(context)
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text("Contest manager", style: Theme.of(context).textTheme.titleLarge),
      bottom: TabBar(
        controller: _tabController,
        tabs: [
          Tab(child: Text("Joined contest", style: Theme.of(context).textTheme.titleMedium,),),
          Tab(child: Text("Own contest", style: Theme.of(context).textTheme.titleMedium,),)
        ],
      ),
    );
  }

  Widget _buildJoinedContest(BuildContext context) {
    return Selector<ManageContestViewModel, List<Contest>>(
      selector: (context, managerContest) => managerContest.joinedContest,
      builder: (context, value, child) {
        return ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) => _buildContestCard(context, value[index]),);
      },
    );
  }

  Widget _buildContestCard(BuildContext context, Contest contest) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ContestDetailScreen(contest: contest),));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                  aspectRatio: 16/9,
                  child: CachedNetworkImage(imageUrl: contest.banner, width: MediaQuery.of(context).size.width / 3, fit: BoxFit.cover,)),
            ),
            const SizedBox(width: 10,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contest.name, style: Theme.of(context).textTheme.titleLarge,),
                  DateTime.now().isBefore(contest.endTime) ?
                  Text("End at: ${DateFormat("yyyy-MM-dd").format(contest.endTime)}", style: Theme.of(context).textTheme.labelLarge,) :
                      Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text("Ended", style: Theme.of(context).textTheme.labelLarge,))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOwnContest(BuildContext context) {
    return Selector<ManageContestViewModel, List<Contest>>(
      selector: (context, managerContest) => managerContest.ownContest,
      builder: (context, value, child) {
        return ListView.builder(
          itemCount: value.length,
          itemBuilder: (context, index) => _buildContestCard(context, value[index]),);
      },
    );
  }
}
