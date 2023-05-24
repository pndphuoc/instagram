import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/route/route_name.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/authentication_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/widgets/common_widgets/text_form_field.dart';
import 'package:provider/provider.dart';

import '../../ultis/ultils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthenticationViewModel _authViewModel = AuthenticationViewModel();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void _loginUser() async {
    await _authViewModel
        .login(email: _emailController.text, password: _passwordController.text)
        .then((value) {
      if (value != 'Login successful') {
        if (!mounted) return;
        showSnackBar(context, value);
      } else {
        final newUserProvider = CurrentUserViewModel();
        ListenableProvider<CurrentUserViewModel>.value(
          value: newUserProvider,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldMessengerKey,
      resizeToAvoidBottomInset: false,
      body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
        width: MediaQuery.of(context).size.width,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: Container(),
        ),
        Image.asset(
          'assets/logo.png',
          height: MediaQuery.of(context).size.height / 4.5,
        ),
        const SizedBox(
          height: 64,
        ),
        SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: TextFormFieldInput(
              textEditingController: _emailController,
              hintText: 'Enter your email',
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.emailAddress),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: TextFormFieldInput(
            textEditingController: _passwordController,
            hintText: 'Enter your password',
            textInputAction: TextInputAction.done,
            textInputType: TextInputType.text,
            isPass: true,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {},
            child: Text(
              "Forgotten password?",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        StreamBuilder(
          stream: _authViewModel.loadingStream,
          initialData: false,
          builder: (context, snapshot) {
            if (!snapshot.data!) {
              return GestureDetector(
                onTap: _loginUser,
                child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                    child: Text(
                      'Log In', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                    )),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        const SizedBox(
          height: 10,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Expanded(
                flex: 2,
                child: Divider(
                  height: 1,
                  color: Colors.grey,
                )),
            Expanded(flex: 1, child: Center(child: Text("OR"))),
            Expanded(
                flex: 2,
                child: Divider(
                  height: 1,
                  color: Colors.grey,
                ))
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () async {
            await _authViewModel.signInWithGoogle();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/ic_google.svg',
                height: 20,
              ),
              const SizedBox(
                width: 10,
              ),
              const Text("Log in with Google"),
            ],
          ),
        ),
        Flexible(
          flex: 4,
          child: Container(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text("Don't have an account?")),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RouteName.signup);
              },
              child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 10),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: primaryColor),
                  )),
            ),
          ],
        )
      ],
      ),
      ),
    );
  }
}
