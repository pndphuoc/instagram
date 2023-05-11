import 'package:flutter/material.dart';
import 'package:instagram/models/contest.dart';
import 'package:instagram/screens/contest_screens/components/contest_tab.dart';
import 'package:instagram/ultis/colors.dart';

class ContestListScreen extends StatefulWidget {
  const ContestListScreen({Key? key}) : super(key: key);

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
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back)),
        bottom: TabBar(
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
              },
              icon: const Icon(Icons.search))
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
