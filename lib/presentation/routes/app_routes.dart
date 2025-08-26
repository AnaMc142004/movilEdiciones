import 'package:flutter/material.dart';
import 'package:ediciones_hispanicas/presentation/pages/login/login_page.dart';
import 'package:ediciones_hispanicas/presentation/pages/login/forgot_password_page.dart';
import 'package:ediciones_hispanicas/presentation/pages/home/home_page.dart';
import 'package:ediciones_hispanicas/presentation/pages/work/work_page.dart';

class AppRoutes {
  static const String login = '/';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String work = '/work';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case work:
        return MaterialPageRoute(builder: (_) => const WorkPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
