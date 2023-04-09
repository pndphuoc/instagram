import 'package:instagram/route/route_name.dart';
import 'package:instagram/screens/add_caption_screen.dart';
import 'package:instagram/screens/add_post_screen.dart';
import 'package:instagram/screens/infomation_input_screen.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/screens/search_screen.dart';
import 'package:instagram/screens/signup_screen.dart';



final routes = {
  //RouteName.home: (context) => const ResponsiveLayout(webScreenLayout: WebScreenLayout(), mobileScreenLayout: MobileScreenLayout(),),
  RouteName.signup: (context) => const SignUpScreen(),
  RouteName.completeRegistration: (context) => const InformationInputScreen(),
  RouteName.addPost: (context) => const AddPostScreen(),
  RouteName.addCaption: (context) => const AddCaptionScreen(),
  RouteName.search: (context) => const SearchScreen(),
};