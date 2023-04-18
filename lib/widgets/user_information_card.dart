import 'package:flutter/material.dart';
import 'package:instagram/view_model/user_view_model.dart';

class UserInformationCard extends StatelessWidget {
  final String userId;
  const UserInformationCard({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserViewModel _userViewModel = UserViewModel();
    return Container();
  }

}
