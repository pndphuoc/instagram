import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/route/route_name.dart';
import 'package:instagram/view_model/authentication_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/widgets/text_form_field.dart';
import 'package:provider/provider.dart';

import '../ultis/ultils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthenticationViewModel _authService = AuthenticationViewModel();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void _loginUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await _authService.login(email: _emailController.text, password: _passwordController.text);

    if (res != 'Login successful') {
     if (!mounted) return;
      showSnackBar(context, res);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
                SvgPicture.asset(
                  'assets/ic_instagram.svg',
                  height: 64,
                ),
                const SizedBox(
                  height: 64,
                ),
                TextFormFieldInput(
                    textEditingController: _emailController,
                    hintText: 'Enter your email',
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.emailAddress),
                const SizedBox(
                  height: 10,
                ),
                TextFormFieldInput(
                  textEditingController: _passwordController,
                  hintText: 'Enter your password',
                  textInputAction: TextInputAction.done,
                  textInputType: TextInputType.text,
                  isPass: true,
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
                _isLoading ? const Center(child: CircularProgressIndicator(),) :  GestureDetector(
                  onTap: _loginUser,
                  child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      child: const Text(
                        'Log In',
                      )),
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
                      await _authService.signInWithGoogle();
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.blue),
                          )),
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
