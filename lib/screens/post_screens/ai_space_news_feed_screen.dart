import 'package:flutter/material.dart';
import 'package:instagram/screens/post_screens/post_details_screen.dart';
import 'package:instagram/view_model/ai_space_view_model.dart';
import 'package:instagram/widgets/post_widgets/mini_post_card.dart';
import 'package:provider/provider.dart';

import '../../ultis/ultils.dart';

class AISpaceNewsFeedScreen extends StatefulWidget {
  const AISpaceNewsFeedScreen({Key? key}) : super(key: key);

  @override
  State<AISpaceNewsFeedScreen> createState() => _AISpaceNewsFeedScreenState();
}

class _AISpaceNewsFeedScreenState extends State<AISpaceNewsFeedScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListenableProvider<AISpaceViewModel>(create: (context) => AISpaceViewModel(),
      builder: (context, child) => Selector<AISpaceViewModel, bool>(
        builder: (context, value, child) => value ? const Center(child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator())) :
        RefreshIndicator(
          onRefresh: () => context.read<AISpaceViewModel>().getAIPosts(),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
              childAspectRatio: 1
            ),
            itemCount: context.read<AISpaceViewModel>().posts.length,
            itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, animation, secondaryAnimation) =>
                          PostDetailsScreen(post: context.read<AISpaceViewModel>().posts[index],),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return buildSlideTransition(animation, child);
                      },
                      transitionDuration: const Duration(milliseconds: 150),
                      reverseTransitionDuration:
                      const Duration(milliseconds: 150),
                    ),
                  );
                },
                child: MiniPostCard(post: context.read<AISpaceViewModel>().posts[index])),
          ),
        ),
        selector: (_, viewModel) => viewModel.isLoadingPosts,
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
