import 'package:chat_application/models/user.dart';
import 'package:chat_application/screens/home.dart';
import 'package:chat_application/screens/login.dart';
import 'package:chat_application/screens/messages.dart';
import 'package:chat_application/screens/register.dart';
import 'package:chat_application/screens/settings.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String login = "/login";
  static const String register = "/register";
  static const String home = "/home";
  static const String settings = "/settings";
  static const String messages = "/messages";

  static Route<dynamic> generateRoute(RouteSettings route) {
    final args = route.arguments;

    switch (route.name) {
      case "/":
        return MaterialPageRoute(builder: (context) => const Login());
      case login:
        return MaterialPageRoute(builder: (context) => const Login());
      case register:
        return MaterialPageRoute(builder: (context) => const Register());
      case home:
        return MaterialPageRoute(builder: (context) => const Home());
      case settings:
        return MaterialPageRoute(builder: (context) => const Settings());
      case messages:
        return MaterialPageRoute(
            builder: (context) => Messages(args as UserModel));
      default:
        return unknownRoute();
    }
  }

  static Route<dynamic> unknownRoute() {
    return MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Error"),
          ),
          body: const Center(
            child: Text("Page not found"),
          ),
        );
      },
    );
  }
}
