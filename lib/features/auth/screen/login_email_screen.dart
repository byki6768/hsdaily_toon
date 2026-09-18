import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/auth/model/auth_validators.dart';
import 'package:hsdaily_toon/features/auth/ui/auth_form_widgets.dart';
import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/services/auth_service.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({super.key});

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _emailFocus = FocusNode();
  final _pwFocus = FocusNode();
  String _emailBubble = '';
  String _pwBubble = '';
  bool _busy = false;
  bool _emailKnown = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() async {
      if (_emailFocus.hasFocus) return;
      if (!AuthValidators.isEmail(_email.text)) {
        setState(() => _emailBubble = '이메일을 입력하세요');
        return;
      }
      final exists = await authService!.emailRegistered(_email.text);
      if (!mounted) return;
      setState(() {
        _emailKnown = exists;
        _emailBubble = exists ? '' : '없는 이메일 ID입니다';
      });
    });
    _pwFocus.addListener(() async {
      if (_pwFocus.hasFocus) return;
      if (!_emailKnown || _pw.text.isEmpty) return;
      // Soft check: attempt sign-in only on submit; on blur show hint after failed submit.
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    _emailFocus.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!AuthValidators.isEmail(_email.text)) {
      setState(() => _emailBubble = '이메일을 입력하세요');
      return;
    }
    setState(() => _busy = true);
    try {
      final exists = await authService!.emailRegistered(_email.text);
      if (!exists) {
        setState(() {
          _emailBubble = '없는 이메일 ID입니다';
          _busy = false;
        });
        return;
      }
      final profile = await authService!.signInEmail(
        email: _email.text,
        password: _pw.text,
      );
      if (!mounted) return;
      final next = profile.nicknameSet
          ? AppRouter.home
          : AppRouter.nicknameWelcome;
      Navigator.of(context).pushNamedAndRemoveUntil(next, (r) => false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'invalid-email') {
          _emailBubble = '없는 이메일 ID입니다';
        } else if (e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          _pwBubble = '비밀번호가 틀립니다. 다시 확인해 주세요';
        } else {
          _pwBubble = '로그인에 실패했어요';
        }
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(
        title: Text(
          '이메일 로그인',
          style: GoogleFonts.gaegu(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthFieldBubble(message: _emailBubble),
                  TextField(
                    controller: _email,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: '이메일 로그인 ID',
                      hintText: '*****@*********.com',
                      filled: true,
                      fillColor: AppColors.panel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onEditingComplete: () => _pwFocus.requestFocus(),
                  ),
                  const SizedBox(height: 16),
                  AuthFieldBubble(message: _pwBubble),
                  AuthPasswordField(
                    controller: _pw,
                    focusNode: _pwFocus,
                    onEditingComplete: _submit,
                  ),
                  const SizedBox(height: 28),
                  AuthPrimaryButton(
                    label: '로그인',
                    busy: _busy,
                    onPressed: _submit,
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
