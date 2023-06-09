import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:instagram/config/route/routes.dart';
import 'package:instagram/provider/home_screen_provider.dart';
import 'package:instagram/repository/authentication_repository.dart';
import 'package:instagram/responsive/mobile_screen_layout.dart';
import 'package:instagram/responsive/responsive_layout_screen.dart';
import 'package:instagram/responsive/web_screen_layout.dart';
import 'package:instagram/screens/authentication_screens/login_screen.dart';
import 'package:instagram/theme.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/asset_message_view_model.dart';
import 'package:instagram/view_model/asset_view_model.dart';
import 'package:instagram/view_model/authentication_view_model.dart';
import 'package:instagram/view_model/common_contest_view_model.dart';
import 'package:instagram/view_model/conversation_view_model.dart';
import 'package:instagram/view_model/elastic_view_model.dart';
import 'package:instagram/view_model/notification_controller.dart';
import 'package:instagram/view_model/notification_view_model.dart';
import 'package:instagram/view_model/post_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await NotificationController.initializeLocalNotifications(debug: true);
  await NotificationController.initializeRemoteNotifications(debug: true);
  await NotificationController.getInitialNotificationAction();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final UserViewModel _userViewModel = UserViewModel();
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    NotificationController.startListeningNotificationEvents();
    NotificationController.requestFirebaseToken();
    WidgetsBinding.instance.addObserver(this);
    if (FirebaseAuth.instance.currentUser != null) {
      _userViewModel.setOnlineStatus(true);
      _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
        _userViewModel.setOnlineStatus(true);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userStatusDatabaseRef =
        FirebaseDatabase.instance.ref().child('userStatus');
    if (FirebaseAuth.instance.currentUser != null) {
      userStatusDatabaseRef
          .child(FirebaseAuth.instance.currentUser!.uid)
          .onDisconnect()
          .update({
        'online': false,
        'lastOnline': ServerValue.timestamp,
      });
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CurrentUserViewModel()),
        ChangeNotifierProvider(create: (context) => AssetViewModel()),
        ChangeNotifierProvider(create: (context) => HomeScreenProvider()),
        ChangeNotifierProvider(create: (context) => PostViewModel()),
        ChangeNotifierProvider(create: (context) => ElasticViewModel()),
        ChangeNotifierProvider(create: (context) => UserViewModel()),
        ChangeNotifierProvider(create: (context) => AssetMessageViewModel()),
        ChangeNotifierProvider(create: (context) => ConversationViewModel()),
        ChangeNotifierProvider(create: (context) => CommonContestViewModel(),)
      ],
      builder: (context, child) {
        return MaterialApp(
            routes: routes,
            debugShowCheckedModeBanner: false,
            title: 'Instagram Clone',
            theme: theme,
            home: Consumer<CurrentUserViewModel>(
              builder: (context, value, child) {
                return StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else if (!snapshot.hasData) {
                      return const LoginScreen();
                    } else {
                      return FutureBuilder(
                        future: value.getCurrentUserDetails(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(),);
                          } else if (snapshot.data!) {
                            return const ResponsiveLayout(
                              webScreenLayout: WebScreenLayout(),
                              mobileScreenLayout: MobileScreenLayout(),
                            );
                          } else if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator(),);
                          }
                          else {
                            AuthenticationViewModel.logout();
                            return Container();
                          }
                        },
                      );
                    }
                  },
                );
              },
            ));
      },
    );
  }
}
