import 'package:flutter/material.dart';
import 'package:instagram/view_model/user_view_model.dart';
import 'package:instagram/widgets/follower_card.dart';

import '../ultis/colors.dart';
import '../view_model/relationship_view_model.dart';

class FollowerListTabBarWidget extends StatefulWidget {
  final RelationshipViewModel relationshipViewModel;
  const FollowerListTabBarWidget({Key? key, required this.relationshipViewModel, }) : super(key: key);

  @override
  State<FollowerListTabBarWidget> createState() => _FollowerListTabBarWidgetState();
}

class _FollowerListTabBarWidgetState extends State<FollowerListTabBarWidget> with AutomaticKeepAliveClientMixin<FollowerListTabBarWidget> {
  final searchFieldBorder =
  OutlineInputBorder(borderRadius: BorderRadius.circular(10));

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Column(
          children: [
            _buildSearchBar(context),
            const SizedBox(height: 15,),
            StreamBuilder(
                stream: widget.relationshipViewModel.rebuildStream,
                builder: (context, snapshot) => ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 10,),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.relationshipViewModel.followerIds.length,
                  itemBuilder: (context, index) {
                    return FollowerCard(userId: widget.relationshipViewModel.followerIds[index], relationshipViewModel: widget.relationshipViewModel,);
                  },)
              ,)
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SizedBox(
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}
