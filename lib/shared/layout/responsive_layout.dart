import 'package:flutter/material.dart';

import 'package:hsdaily_toon/theme/app_theme.dart';

/// Breakpoint between mobile and desktop layouts.
const double kDesktopBreakpoint = 769;

/// Shared responsive shell.
///
/// - Desktop (≥ [kDesktopBreakpoint]): left sidebar + right main content
/// - Mobile (≤ 768): top horizontal menu + main content below
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.sidebar,
    required this.content,
  });

  final Widget sidebar;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;

        if (isDesktop) {
          return ColoredBox(
            color: AppColors.blush,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 220, child: sidebar),
                Expanded(child: content),
              ],
            ),
          );
        }

        return ColoredBox(
          color: AppColors.blush,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              sidebar,
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}
