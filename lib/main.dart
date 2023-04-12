import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/config/route/routes.dart';
import 'package:instagram/provider/home_screen_provider.dart';
import 'package:instagram/responsive/mobile_screen_layout.dart';
import 'package:instagram/responsive/responsive_layout_screen.dart';
import 'package:instagram/responsive/web_screen_layout.dart';
import 'package:instagram/screens/infomation_input_screen.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/ultis/colors.dart';
import 'package:instagram/view_model/asset_view_model.dart';
import 'package:instagram/view_model/authentication_view_model.dart';
import 'package:instagram/view_model/elastic_view_model.dart';
import 'package:instagram/view_model/post_view_model.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:instagram/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyC-LNRr4ya2nJ4m_j8pj-VTt0IYDZHjA1A",
          appId: '1:264062629818:web:3ea78b16a7dfaf5dc8cf83',
          messagingSenderId: '264062629818',
          projectId: 'instagram-b3812',
          storageBucket: 'instagram-b3812.appspot.com'),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CurrentUserViewModel()),
        ChangeNotifierProvider(create: (context) => AssetViewModel()),
        ChangeNotifierProvider(create: (context) => HomeScreenProvider()),
        ChangeNotifierProvider(create: (context) => PostViewModel()),
        ChangeNotifierProvider(create: (context) => AuthenticationViewModel()),
        ChangeNotifierProvider(create: (context) => ElasticViewModel()),
        ChangeNotifierProvider(create: (context) => UserViewModel())
      ],
      child: MaterialApp(
          routes: routes,
          debugShowCheckedModeBanner: false,
          title: 'Instagram Clone',
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: mobileBackgroundColor,
            textTheme: GoogleFonts.readexProTextTheme().copyWith(
              bodyLarge: const TextStyle(
                  color: onBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.normal),
              bodyMedium: const TextStyle(
                color: onBackground,
              ),
              bodySmall: const TextStyle(color: onBackground),
              labelLarge: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.w300),
              displayLarge: const TextStyle(color: onBackground),
              displayMedium: const TextStyle(color: onBackground),
              displaySmall: const TextStyle(color: onBackground),
              headlineMedium: const TextStyle(color: onBackground),
              headlineSmall: const TextStyle(color: onBackground),
              titleLarge: const TextStyle(color: onBackground),
              labelSmall: const TextStyle(color: onBackground),
              titleMedium: const TextStyle(color: onBackground),
              titleSmall: const TextStyle(color: onBackground),
            ),
          ),
          /*   home: const ResponsiveLayout(
          mobileScreenLayout: MobileScreenLayout(),
          webScreenLayout: WebScreenLayout(),
        ),*/
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
                        if (snapshot.connectionState == ConnectionState.done) {
                          return const ResponsiveLayout(
                            webScreenLayout: WebScreenLayout(),
                            mobileScreenLayout: MobileScreenLayout(),
                          );
                        } else {
                          return const Center(
                            child:
                                CircularProgressIndicator(color: primaryColor),
                          );
                        }
                      },
                    );
                  }
                },
              );
            },
          )),
    );
  }
}
