import 'package:firebase_auth/firebase_auth.dart';
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
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = switch (e.code) {
          'popup-closed-by-user' || 'cancelled-popup-request' =>
            '로그인이 취소되었어요. 다시 시도해 볼까요?',
          'account-exists-with-different-credential' =>
            '같은 이메일로 다른 방식 가입이 되어 있어요.',
          'unauthorized-domain' =>
            '이 도메인에서는 Google 로그인을 쓸 수 없어요. 관리자에게 문의해 주세요.',
          'user-disabled' => '탈퇴한 계정입니다',
          _ => e.message?.trim().isNotEmpty == true
              ? e.message!
              : 'Google 로그인에 실패했어요. 다시 시도해 주세요',
        };
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('Google login failed: $e');
      setState(() => _error = 'Google 로그인에 실패했어요. 팝업 차단을 해제한 뒤 다시 시도해 주세요');
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
