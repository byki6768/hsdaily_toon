import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/auth/ui/auth_form_widgets.dart';
import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/services/auth_service.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

class LoginChoiceScreen extends StatefulWidget {
  const LoginChoiceScreen({super.key});

  @override
  State<LoginChoiceScreen> createState() => _LoginChoiceScreenState();
}

class _LoginChoiceScreenState extends State<LoginChoiceScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _google() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final profile = await authService!.signInWithGoogle();
      if (!mounted) return;
      final next = profile.nicknameSet
          ? AppRouter.home
          : AppRouter.nicknameWelcome;
      Navigator.of(context).pushNamedAndRemoveUntil(next, (r) => false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Google 로그인에 실패했어요. 다시 시도해 주세요');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(
        title: Text('로그인', style: GoogleFonts.gaegu(fontWeight: FontWeight.w700)),
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
                  if (_error != null) ...[
                    AuthFieldBubble(message: _error!),
                    const SizedBox(height: 8),
                  ],
                  AuthPrimaryButton(
                    label: 'Google 로그인',
                    busy: _busy,
                    onPressed: _google,
                  ),
                  const SizedBox(height: 12),
                  AuthSecondaryButton(
                    label: '이메일 로그인',
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRouter.loginEmail),
                  ),
                  const SizedBox(height: 12),
                  AuthSecondaryButton(
                    label: '휴대폰 전화번호 로그인',
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRouter.loginPhone),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRouter.signup),
                    child: const Text('신규 회원 가입'),
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
