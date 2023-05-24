import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/screens/post_screens/post_details_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/view_model/common_contest_view_model.dart';
import 'package:instagram/view_model/contest_details_view_model.dart';
import 'package:provider/provider.dart';

import '../../models/post.dart';
import '../../models/prize.dart';

class AwardModificationScreen extends StatefulWidget {
  const AwardModificationScreen(
      {Key? key, required this.contestDetailsViewModel})
      : super(key: key);
  final ContestDetailsViewModel contestDetailsViewModel;

  @override
  State<AwardModificationScreen> createState() =>
      _AwardModificationScreenState();
}

class _AwardModificationScreenState extends State<AwardModificationScreen> {
  late Future _getPostOfContest;

  @override
  void initState() {
    _getPostOfContest = context
        .read<CommonContestViewModel>()
        .getPostsOfContest(widget.contestDetailsViewModel.contestId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => widget.contestDetailsViewModel,
      builder: (context, child) => Scaffold(
        appBar: _buildAppBar(context),
        body: FutureBuilder(
          future: _getPostOfContest,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              return Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                    itemCount: widget
                        .contestDetailsViewModel.contestDetails!.prizes.length,
                    itemBuilder: (context, index) => _buildPrizeBlock(
                        context,
                        widget
                            .contestDetailsViewModel.contestDetails!.prizes[index]),
                  ),
                  const SizedBox(height: 20,),
                  _buildConfirmButton(context)
                ],
              );
            }
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text(
        "Award modification",
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildPrizeBlock(BuildContext context, Prize prize) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
                child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Image.asset(
                  "assets/award_icon.png",
                  width: 100,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  prize.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            )),
            prize.winnerId == null
                ? Expanded(
                    child: GestureDetector(
                    onTap: () {
                      _showPostSelectorModal(context, prize);
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(width: 2, color: Colors.white)),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  ))
                : Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _showPostSelectorModal(context, prize);
                      },
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          margin: const EdgeInsets.all(20.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: widget
                                  .contestDetailsViewModel
                                  .winningPosts[widget
                                      .contestDetailsViewModel.prizes
                                      .indexOf(prize)]
                                  .medias
                                  .first
                                  .url,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
          ],
        ));
  }

  _showPostSelectorModal(BuildContext context, Prize prize) {
    List<Post> posts = context.read<CommonContestViewModel>().posts;
    return showModalBottomSheet(
      context: context,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20))),
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 1,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          color: secondaryColor,
          child: Column(
            children: [
              const Center(
                child: Icon(
                  Icons.remove_rounded,
                  size: 40,
                ),
              ),
              GridView.builder(
                controller: scrollController,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                    childAspectRatio: 1),
                itemCount: posts.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () async {
                    await _showConfirmDialog(context, posts[index])
                        .then((value) {
                      if (value) {
                        Navigator.pop(context);
                        setState(() {
                          widget.contestDetailsViewModel
                              .chooseWinner(post: posts[index], prize: prize);
                        });
                        //Provider.of<ContestDetailsViewModel>(context, listen: false).chooseWinner(post: posts[index], prize: prize);
                      }
                    });
                  },
                  child: CachedNetworkImage(
                    imageUrl: posts[index].medias.first.url,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _showConfirmDialog(BuildContext context, Post post) {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: post.avatarUrl.isNotEmpty
                      ? CachedNetworkImageProvider(post.avatarUrl)
                      : defaultAvatar,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  post.username,
                  style: Theme.of(context).textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          CarouselSlider(
              items: post.medias
                  .map((e) => AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: e.url,
                        fit: BoxFit.cover,
                      )))
                  .toList(),
              options: CarouselOptions(
                  aspectRatio: 1, viewportFraction: 1, reverse: false)),
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                post.caption,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              Expanded(
                  child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PostDetailsScreen(postId: post.uid),
                      ));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(10))),
                child: Text(
                  "Details",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              )),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                  child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(10))),
                child: Text(
                  "Cancel",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              )),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                  child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Text(
                  "Choose",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              )),
              const SizedBox(
                width: 5,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        width: MediaQuery.of(context).size.width,
        height: 40,
        child: ElevatedButton(onPressed: () {
          widget.contestDetailsViewModel.updateAward().whenComplete(() {
            Fluttertoast.showToast(msg: 'Update award successful');
            Navigator.pop(context);
          });
        },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
              )
            ),
            child: Text("Confirm", style: Theme.of(context).textTheme.titleLarge,)));
  }
}
