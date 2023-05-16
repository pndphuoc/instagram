import 'package:flutter/material.dart';
import 'package:instagram/models/contest.dart';
import 'package:instagram/screens/contest_screens/components/contest_tab.dart';
import 'package:instagram/screens/contest_screens/create_contest_screen.dart';
import 'package:instagram/screens/contest_screens/personal_contest_screens.dart';
import 'package:instagram/ultis/colors.dart';

class ContestListScreen extends StatefulWidget {
  final String? ownerId;
  const ContestListScreen({Key? key, this.ownerId}) : super(key: key);

  @override
  State<ContestListScreen> createState() => _ContestListScreenState();
}

class _ContestListScreenState extends State<ContestListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          indicatorColor: primaryColor,
          controller: _tabController,
          tabs: [
            Text(
              ContestStatus.inProgress['name'],
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              ContestStatus.upcoming['name'],
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              ContestStatus.expired['name'],
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
          labelPadding: const EdgeInsets.symmetric(vertical: 8),
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalContestsScreen(),));
              },
              icon: const Icon(Icons.collections_bookmark_outlined)),
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateContestScreen(),));
              },
              icon: const Icon(Icons.add_circle_outline_outlined)),
          IconButton(
              onPressed: () {
              },
              icon: const Icon(Icons.search)),

        ],
        title: Text(
          'Contest List',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: mobileBackgroundColor,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ContestTab(typeOfContest: ContestStatus.inProgress['status']),
          ContestTab(typeOfContest: ContestStatus.upcoming['status']),
          ContestTab(typeOfContest: ContestStatus.expired['status']),
        ],
      ),
    );
  }
}
