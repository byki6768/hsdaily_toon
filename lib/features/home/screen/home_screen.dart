import 'package:flutter/material.dart';

import 'package:hsdaily_toon/features/auth/ui/session_chrome.dart';
import 'package:hsdaily_toon/features/home/ui/home_widgets.dart';
import 'package:hsdaily_toon/shared/layout/app_nav.dart';
import 'package:hsdaily_toon/shared/layout/responsive_layout.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// Home feature screen — post-login main.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      body: Stack(
        children: [
          ResponsiveLayout(
            sidebar: const AppNav(selected: AppNavItem.home),
            content: const _HomeBody(),
          ),
          const SessionChrome(),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.blush,
            Color(0xFFFFE8DF),
            AppColors.blushDeep,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 56 : 24,
            vertical: wide ? 48 : 28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: wide
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HomeHeader(),
                              SizedBox(height: 36),
                              HomeActions(),
                            ],
                          ),
                        ),
                        SizedBox(width: 40),
                        Expanded(flex: 4, child: HomeComicHint()),
                      ],
                    )
                  : const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeHeader(),
                        SizedBox(height: 28),
                        HomeActions(),
                        SizedBox(height: 36),
                        HomeComicHint(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
