import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:instagram/view_model/suggestion_view_model.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20,),
          _buildWelcomeText(context),

        ],
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      children: [
        Text("Welcome to Instashare", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center,),
        const SizedBox(height: 20,),
        _usersSuggestion(context)
      ],
    );
  }
  
  Widget _usersSuggestion(BuildContext context) {
    return ListenableProvider(create: (context) => SuggestionViewModel(),
      builder: (context, child) => Selector<SuggestionViewModel, List<User>>(builder: (context, value, child) => CarouselSlider(
          items: value.map((e) => _buildUserBox(context, e)).toList(), options: CarouselOptions(aspectRatio: 16/9, height: 200)),
          selector: (_, viewModel) => viewModel.usersSuggested,),
    );
  }

  Widget _buildUserBox(BuildContext context, User user) {
    return Container(
      child: Text(user.username),
    );
  }
}
