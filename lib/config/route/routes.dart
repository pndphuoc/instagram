import 'package:instagram/route/route_name.dart';
import 'package:instagram/screens/post_screens/add_caption_screen.dart';
import 'package:instagram/screens/post_screens/add_post_screen.dart';
import 'package:instagram/screens/search_screen.dart';
import 'package:instagram/screens/authentication_screens/signup_screen.dart';
import 'package:flutter/material.dart';



final routes = {
  //RouteName.home: (context) => const ResponsiveLayout(webScreenLayout: WebScreenLayout(), mobileScreenLayout: MobileScreenLayout(),),
  RouteName.signup: (context) => const SignUpScreen(),
  RouteName.addPost: (context) => const AddPostScreen(),
  RouteName.addCaption: (context) => const AddCaptionScreen(),
  RouteName.search: (context) => const SearchScreen(),
};

/*
transitionRightToLeftPage(RouteSettings settings) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        switch (settings.name) {
          case RouteName.boardinghouse:
            return const BoardingHousePage();
          case RouteName.blogSale:
            return const ForumPage();
          case RouteName.roomManage:
            return const RoomManage();
          case RouteName.interactManage:
            return const InteractManage();
          case RouteName.statisticalManage:
            return const StatisticalManage();
          case RouteName.addRoom:
            return const AddRoomPage();
          case RouteName.removeRoom:
            return const RemoveRoomPage();
          case RouteName.login:
            return const LoginPage();
          case RouteName.register:
            return const RegisterPage();
          case RouteName.editProfile:
            return const EditProfile();
          case RouteName.profile:
            return const UserInfoPage();
          case RouteName.rentHistory:
            return const RentHistory();
          case RouteName.favorite:
            return const FavoritePage();
          case RouteName.postHistory:
            return const PostHistory();
          case RouteName.atm:
            return const ATMPage();
          case RouteName.hospital:
            return const HospitalPage();
          case RouteName.superMarket:
            return const SuperMarketPage();
          case RouteName.householdGoods:
            return const HouseholdGood();
          case RouteName.qrcode:
            return const QRCodeScanner();
          case RouteName.myActivity:
            return const MyActivity();
          case RouteName.transpot:
            return const TranspotPages();
          case RouteName.nearby:
            return const NearByLocation();

          default:
            return const Layout(selectedIndex: 0);
        }
      },
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      settings: RouteSettings(name: settings.name));
}*/
