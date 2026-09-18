import 'package:flutter/material.dart';

import 'package:hsdaily_toon/features/auth/screen/auth_screen.dart';
import 'package:hsdaily_toon/features/diary/screen/diary_screen.dart';
import 'package:hsdaily_toon/features/gallery/screen/gallery_screen.dart';
import 'package:hsdaily_toon/features/home/screen/home_screen.dart';

/// Application route names and navigation scaffolding.
class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String auth = '/auth';
  static const String diary = '/diary';
  static const String gallery = '/gallery';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      case auth:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AuthScreen(),
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
          builder: (_) => const HomeScreen(),
        );
    }
  }
}
