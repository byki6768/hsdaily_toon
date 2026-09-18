import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/auth/ui/auth_form_widgets.dart';
import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

class SignupChoiceScreen extends StatelessWidget {
  const SignupChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(
        title: Text(
          '신규 회원 가입',
          style: GoogleFonts.gaegu(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '어떻게 가입할까요?',
                    style: GoogleFonts.gaegu(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '이메일이나 휴대폰 번호로 나만의 4컷 일기를 시작해요.',
                    style: TextStyle(color: AppColors.inkSoft, height: 1.45),
                  ),
                  const SizedBox(height: 32),
                  AuthPrimaryButton(
                    label: '이메일 가입',
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRouter.signupEmail),
                  ),
                  const SizedBox(height: 12),
                  AuthSecondaryButton(
                    label: '휴대폰 번호 가입',
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRouter.signupPhone),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
