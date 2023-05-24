import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/profile_screens/profile_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/view_model/suggestion_view_model.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart' as model;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          _buildWelcomeText(context),
          Expanded(flex: 1, child: Container()),
          _usersSuggestion(context),
          Expanded(flex: 2, child: Container()),
        ],
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      children: [
        Text(
          "Welcome to Instashare",
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Follow people to start viewing the photos and videos they share",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  Widget _usersSuggestion(BuildContext context) {
    return ListenableProvider(
      create: (context) =>
          SuggestionViewModel(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, child) =>
          Selector<SuggestionViewModel, List<model.User>>(
        builder: (context, value, child) => CarouselSlider(
            items: value.map((e) => _buildUserBox(context, e)).toList(),
            options: CarouselOptions()),
        selector: (_, viewModel) => viewModel.usersSuggested,
      ),
    );
  }

  Widget _buildUserBox(BuildContext context, model.User user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: user.uid),
            ));
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 2 / 3,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.white30),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            CircleAvatar(
              radius: 40,
              backgroundImage: user.avatarUrl.isNotEmpty
                  ? CachedNetworkImageProvider(
                      user.avatarUrl,
                    )
                  : defaultAvatar,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              user.username,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              user.displayName,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                child: Text(
                  "Follow",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                ))
          ],
        ),
      ),
    );
  }
}
