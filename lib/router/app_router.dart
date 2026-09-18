import 'package:flutter/material.dart';

import 'package:hsdaily_toon/features/auth/screen/landing_screen.dart';
import 'package:hsdaily_toon/features/auth/screen/login_choice_screen.dart';
import 'package:hsdaily_toon/features/auth/screen/login_email_screen.dart';
import 'package:hsdaily_toon/features/auth/screen/login_phone_screen.dart';
import 'package:hsdaily_toon/features/auth/screen/my_page_screen.dart';
import 'package:hsdaily_toon/features/auth/screen/nickname_welcome_screen.dart';
import 'package:hsdaily_toon/features/auth/screen/signup_choice_screen.dart';
import 'package:hsdaily_toon/features/auth/screen/signup_email_screen.dart';
import 'package:hsdaily_toon/features/auth/screen/signup_phone_screen.dart';
import 'package:hsdaily_toon/features/diary/screen/diary_screen.dart';
import 'package:hsdaily_toon/features/gallery/screen/gallery_screen.dart';
import 'package:hsdaily_toon/features/home/screen/home_screen.dart';

/// Application route names and navigation scaffolding.
class AppRouter {
  AppRouter._();

  static const String landing = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String loginEmail = '/login/email';
  static const String loginPhone = '/login/phone';
  static const String signup = '/signup';
  static const String signupEmail = '/signup/email';
  static const String signupPhone = '/signup/phone';
  static const String nicknameWelcome = '/welcome/nickname';
  static const String mypage = '/mypage';
  static const String diary = '/diary';
  static const String gallery = '/gallery';

  /// Legacy alias used by older nav links.
  static const String auth = login;

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case landing:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LandingScreen(),
        );
      case home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      case login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginChoiceScreen(),
        );
      case loginEmail:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginEmailScreen(),
        );
      case loginPhone:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginPhoneScreen(),
        );
      case signup:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SignupChoiceScreen(),
        );
      case signupEmail:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SignupEmailScreen(),
        );
      case signupPhone:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SignupPhoneScreen(),
        );
      case nicknameWelcome:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const NicknameWelcomeScreen(),
        );
      case mypage:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MyPageScreen(),
        );
      case diary:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const DiaryScreen(),
        );
      case gallery:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const GalleryScreen(),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LandingScreen(),
        );
    }
  }
}
