import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/auth/model/auth_validators.dart';
import 'package:hsdaily_toon/features/auth/ui/auth_form_widgets.dart';
import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/services/auth_service.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

class SignupPhoneScreen extends StatefulWidget {
  const SignupPhoneScreen({super.key});

  @override
  State<SignupPhoneScreen> createState() => _SignupPhoneScreenState();
}

class _SignupPhoneScreenState extends State<SignupPhoneScreen> {
  final _country = TextEditingController(text: '82');
  final _phone = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  final _phoneFocus = FocusNode();
  final _pwFocus = FocusNode();
  final _pw2Focus = FocusNode();

  String _phoneBubble = '';
  String _pwBubble = '';
  String _pw2Bubble = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(() {
      if (!_phoneFocus.hasFocus) _validatePhone();
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
    _country.dispose();
    _phone.dispose();
    _pw.dispose();
    _pw2.dispose();
    _phoneFocus.dispose();
    _pwFocus.dispose();
    _pw2Focus.dispose();
    super.dispose();
  }

  bool _validatePhone() {
    final ok = AuthValidators.isNationalPhone(_phone.text);
    setState(() {
      _phoneBubble = ok ? '' : '휴대폰 번호를 입력하세요';
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
    final pOk = _validatePhone();
    final wOk = _validatePw();
    final w2Ok = _validatePw2();
    if (!pOk || !wOk || !w2Ok) return;

    final cc = AuthValidators.normalizeCountryCode(_country.text);
    final nn = AuthValidators.digitsOnly(_phone.text);

    setState(() => _busy = true);
    try {
      final auth = authService!;
      if (await auth.phoneRegistered(cc, nn)) {
        setState(() => _phoneBubble = '이미 가입된 휴대폰 번호예요');
        return;
      }
      await auth.signUpPhone(
        countryCode: cc,
        nationalNumber: nn,
        password: _pw.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.nicknameWelcome,
        (r) => false,
      );
    } on FirebaseAuthException {
      setState(() => _phoneBubble = '가입에 실패했어요. 다시 시도해 주세요');
    } catch (_) {
      setState(() => _phoneBubble = '가입에 실패했어요. 다시 시도해 주세요');
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
          '휴대폰 번호 가입',
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
                  AuthFieldBubble(message: _phoneBubble),
                  Row(
                    children: [
                      SizedBox(
                        width: 96,
                        child: TextField(
                          controller: _country,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            prefixText: '+ ',
                            hintText: '82',
                            filled: true,
                            fillColor: AppColors.panel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _phone,
                          focusNode: _phoneFocus,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '10-1234-5678',
                            filled: true,
                            fillColor: AppColors.panel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AuthFieldBubble(message: _pwBubble),
                  AuthPasswordField(controller: _pw, focusNode: _pwFocus),
                  const SizedBox(height: 16),
                  AuthFieldBubble(message: _pw2Bubble),
                  AuthPasswordField(controller: _pw2, focusNode: _pw2Focus),
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
