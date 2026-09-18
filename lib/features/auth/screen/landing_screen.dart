import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/auth/ui/auth_form_widgets.dart';
import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// First screen — brand, warm copy, Login / New member.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 769;

    return Scaffold(
      backgroundColor: AppColors.blush,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF6F1),
              AppColors.blush,
              AppColors.blushDeep,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 48 : 28,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      '4컷 일기',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.gaegu(
                        fontSize: wide ? 64 : 52,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daily-toon',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 15,
                        letterSpacing: 2,
                        color: AppColors.rose,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.panel.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '오늘의 마음을 네 칸에 담아 보세요',
                              style: GoogleFonts.gaegu(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '일기를 쓰면 AI가 따뜻한 4컷 시나리오를 만들고, '
                              '이어서 만화 그림까지 그려 줘요. '
                              '말로 적어도, 사진·PDF로 올려도 괜찮아요.',
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.55,
                                color: AppColors.inkSoft,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '작은 하루도, 네 칸이면 충분히 아름다워요.',
                              style: GoogleFonts.gaegu(
                                fontSize: 17,
                                color: AppColors.roseDeep,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    AuthPrimaryButton(
                      label: '로그인',
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AppRouter.login),
                    ),
                    const SizedBox(height: 12),
                    AuthSecondaryButton(
                      label: '신규 회원',
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AppRouter.signup),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
