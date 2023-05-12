import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/contest_details_view_model.dart';

import '../../models/prize.dart';

class AwardModificationScreen extends StatefulWidget {
  const AwardModificationScreen({Key? key, required this.contestDetailsViewModel}) : super(key: key);
  final ContestDetailsViewModel contestDetailsViewModel;
  @override
  State<AwardModificationScreen> createState() => _AwardModificationScreenState();
}

class _AwardModificationScreenState extends State<AwardModificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 10,),
          itemCount: widget.contestDetailsViewModel.contestDetails!.prizes.length,
          itemBuilder: (context, index) => _buildPrizeBlock(context, widget.contestDetailsViewModel.contestDetails!.prizes[index]),),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text("Award modification", style: Theme.of(context).textTheme.titleLarge,),
    );
  }
  
  Widget _buildPrizeBlock(BuildContext context, Prize prize) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 2, color: Colors.white)
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(prize.name, style: Theme.of(context).textTheme.titleMedium,)),
              const VerticalDivider(width: 2, color: Colors.grey,),
              Expanded(child: Text(prize.award, style: Theme.of(context).textTheme.labelLarge,))
            ],
          ),
          const Divider(color: Colors.grey, height: 2),
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.grey)
            ),
            child: const Center(
              child: Icon(Icons.add, size: 60,),
            ),
          )
        ],
      ),
    );
  }


}
