import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';

class AddAIPostScreen extends StatefulWidget {
  const AddAIPostScreen({Key? key}) : super(key: key);

  @override
  State<AddAIPostScreen> createState() => _AddAIPostScreenState();
}

class _AddAIPostScreenState extends State<AddAIPostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text("AI photos generation", style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
