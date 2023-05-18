import 'package:flutter/material.dart';


import '../../ultis/colors.dart';
import '../../view_model/relationship_view_model.dart';
import 'following_card.dart';

class FollowingListTabBarWidget extends StatefulWidget {
  final RelationshipViewModel relationshipViewModel;
  const FollowingListTabBarWidget({Key? key, required this.relationshipViewModel, }) : super(key: key);

  @override
  State<FollowingListTabBarWidget> createState() => _FollowingListTabBarWidgetState();
}

class _FollowingListTabBarWidgetState extends State<FollowingListTabBarWidget> with AutomaticKeepAliveClientMixin<FollowingListTabBarWidget> {
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
                  itemCount: widget.relationshipViewModel.followingIds.length,
                  itemBuilder: (context, index) {
                    return FollowingCard(userId: widget.relationshipViewModel.followingIds[index], relationshipViewModel: widget.relationshipViewModel,);
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
            fillColor: Colors.white24),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}
