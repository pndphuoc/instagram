import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/change_password_view_model.dart';
import 'package:instagram/widgets/text_form_field.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _reenterNewPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<ChangePasswordViewModel>(
      create: (_) => ChangePasswordViewModel(),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _oldPasswordTextField(context),
                  const SizedBox(
                    height: 20,
                  ),
                  _newPasswordTextField(context),
                  const SizedBox(height: 20,),
                  _reenterNewPasswordTextField(context),
                  const SizedBox(
                    height: 30,
                  ),
                  _changePasswordButton(context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: mobileBackgroundColor,
      title: Text(
        "Change password",
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _reenterNewPasswordTextField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reenter new password",
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(
          height: 10,
        ),
        TextFormFieldInput.password(
            textEditingController: _reenterNewPasswordController,
            hintText: "Reenter the new password",
            textInputType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next),
      ],
    );
  }

  Widget _newPasswordTextField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "New password",
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(
          height: 10,
        ),
        TextFormFieldInput.password(
            textEditingController: _newPasswordController,
            hintText: "Enter the new password",
            textInputType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done),
      ],
    );
  }

  Widget _oldPasswordTextField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Old password",
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(
          height: 10,
        ),
        TextFormFieldInput.password(
            textEditingController: _oldPasswordController,
            hintText: "Enter the old password",
            textInputType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next),
      ],
    );
  }

  Widget _changePasswordButton(BuildContext context) {
    return Consumer<ChangePasswordViewModel>(
      builder: (context, value, child) => SizedBox(
          width: double.infinity,
          height: 50,
          child: value.isChanging
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      value.onChangeButtonTap(
                          FirebaseAuth.instance.currentUser!.email!,
                          _oldPasswordController.text,
                          _newPasswordController.text,
                          _reenterNewPasswordController.text);
                    }
                  },
                  child: Text(
                    "Change",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ))),
    );
  }
}
