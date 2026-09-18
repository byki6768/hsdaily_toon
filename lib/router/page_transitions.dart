import 'package:flutter/material.dart';

/// Soft transitions for the diary → loading → result flow.
abstract final class AppPageTransitions {
  /// Gentle fade + slight upward slide (default forward motion).
  static Route<T> fadeSlide<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    Offset begin = const Offset(0, 0.06),
    Duration duration = const Duration(milliseconds: 480),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: const Duration(milliseconds: 340),
      opaque: true,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final exit = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
            child: FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0.86).animate(exit),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(0, -0.02),
                ).animate(exit),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
