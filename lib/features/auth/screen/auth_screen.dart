import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/shared/layout/app_nav.dart';
import 'package:hsdaily_toon/shared/layout/responsive_layout.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// Auth feature screen — login UI shell (logic later).
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        sidebar: const AppNav(selected: AppNavItem.auth),
        content: _PlaceholderBody(
          title: '로그인',
          subtitle: '계정으로 일기를 동기화할 수 있어요.\n인증 연동은 다음 단계에서 연결됩니다.',
        ),
      ),
    );
  }
}

/// Shared soft placeholder for feature screens not yet fully built.
class _PlaceholderBody extends StatelessWidget {
  const _PlaceholderBody({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blush, Color(0xFFFFE8DF), AppColors.blushDeep],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.gaegu(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
