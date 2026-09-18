import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/auth/model/auth_validators.dart';
import 'package:hsdaily_toon/features/auth/ui/auth_form_widgets.dart';
import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/services/auth_service.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

class SignupEmailScreen extends StatefulWidget {
  const SignupEmailScreen({super.key});

  @override
  State<SignupEmailScreen> createState() => _SignupEmailScreenState();
}

class _SignupEmailScreenState extends State<SignupEmailScreen> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  final _emailFocus = FocusNode();
  final _pwFocus = FocusNode();
  final _pw2Focus = FocusNode();

  String _emailBubble = '';
  String _pwBubble = '';
  String _pw2Bubble = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) _validateEmail();
    });
    _pwFocus.addListener(() {
      if (!_pwFocus.hasFocus) _validatePw();
    });
    _pw2Focus.addListener(() {
      if (!_pw2Focus.hasFocus) _validatePw2();
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    _pw2.dispose();
    _emailFocus.dispose();
    _pwFocus.dispose();
    _pw2Focus.dispose();
    super.dispose();
  }

  bool _validateEmail() {
    final ok = AuthValidators.isEmail(_email.text);
    setState(() {
      _emailBubble = ok ? '' : '이메일을 입력하세요';
    });
    return ok;
  }

  bool _validatePw() {
    final ok = AuthValidators.isPassword(_pw.text);
    setState(() {
      _pwBubble = ok ? '' : '문자 또는 숫자로만 입력하세요';
    });
    return ok;
  }

  bool _validatePw2() {
    final ok = _pw.text == _pw2.text && _pw2.text.isNotEmpty;
    setState(() {
      _pw2Bubble = ok ? '' : '비밀번호가 일치하지 않습니다';
    });
    return ok;
  }

  Future<void> _submit() async {
    final eOk = _validateEmail();
    final pOk = _validatePw();
    final p2Ok = _validatePw2();
    if (!eOk || !pOk || !p2Ok) return;

    setState(() => _busy = true);
    try {
      final auth = authService!;
      if (await auth.emailRegistered(_email.text)) {
        setState(() => _emailBubble = '이미 가입된 이메일이에요');
        return;
      }
      await auth.signUpEmail(email: _email.text, password: _pw.text);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.nicknameWelcome,
        (r) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _emailBubble = switch (e.code) {
          'email-already-in-use' => '이미 가입된 이메일이에요',
          'invalid-email' => '이메일을 입력하세요',
          'weak-password' => '비밀번호를 6자 이상으로 입력해 주세요',
          'operation-not-allowed' => '이메일 가입이 잠시 막혀 있어요. 관리자에게 문의해 주세요',
          _ => '가입에 실패했어요 (${e.code}). 다시 시도해 주세요',
        };
      });
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _emailBubble = (e.message ?? '').trim().isNotEmpty
            ? e.message!
            : '회원 정보 저장에 실패했어요. 다시 시도해 주세요';
      });
    } catch (e) {
      debugPrint('email signup failed: $e');
      setState(() => _emailBubble = '가입에 실패했어요. 다시 시도해 주세요');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(
        title: Text('이메일 가입', style: GoogleFonts.gaegu(fontWeight: FontWeight.w700)),
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
                      hintText: '*****@*********.com',
                      filled: true,
                      fillColor: AppColors.panel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuthFieldBubble(message: _pwBubble),
                  AuthPasswordField(
                    controller: _pw,
                    focusNode: _pwFocus,
                  ),
                  const SizedBox(height: 16),
                  AuthFieldBubble(message: _pw2Bubble),
                  AuthPasswordField(
                    controller: _pw2,
                    focusNode: _pw2Focus,
                  ),
                  const SizedBox(height: 28),
                  AuthPrimaryButton(
                    label: '가입하기',
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
