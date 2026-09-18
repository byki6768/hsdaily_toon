import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/auth/model/auth_validators.dart';
import 'package:hsdaily_toon/features/auth/ui/auth_form_widgets.dart';
import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/services/auth_service.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

class LoginPhoneScreen extends StatefulWidget {
  const LoginPhoneScreen({super.key});

  @override
  State<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  final _country = TextEditingController(text: '82');
  final _phone = TextEditingController();
  final _pw = TextEditingController();
  final _phoneFocus = FocusNode();
  final _pwFocus = FocusNode();
  String _phoneBubble = '';
  String _pwBubble = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(() async {
      if (_phoneFocus.hasFocus) return;
      if (!AuthValidators.isNationalPhone(_phone.text)) {
        setState(() => _phoneBubble = '휴대폰 번호를 입력하세요');
        return;
      }
      final cc = AuthValidators.normalizeCountryCode(_country.text);
      final nn = AuthValidators.digitsOnly(_phone.text);
      final exists = await authService!.phoneRegistered(cc, nn);
      if (!mounted) return;
      setState(() {
        _phoneBubble = exists ? '' : '없는 휴대폰 전화번호 ID입니다';
      });
    });
  }

  @override
  void dispose() {
    _country.dispose();
    _phone.dispose();
    _pw.dispose();
    _phoneFocus.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!AuthValidators.isNationalPhone(_phone.text)) {
      setState(() => _phoneBubble = '휴대폰 번호를 입력하세요');
      return;
    }
    final cc = AuthValidators.normalizeCountryCode(_country.text);
    final nn = AuthValidators.digitsOnly(_phone.text);
    setState(() => _busy = true);
    try {
      final exists = await authService!.phoneRegistered(cc, nn);
      if (!exists) {
        setState(() {
          _phoneBubble = '없는 휴대폰 전화번호 ID입니다';
          _busy = false;
        });
        return;
      }
      final profile = await authService!.signInPhone(
        countryCode: cc,
        nationalNumber: nn,
        password: _pw.text,
      );
      if (!mounted) return;
      final next = profile.nicknameSet
          ? AppRouter.home
          : AppRouter.nicknameWelcome;
      Navigator.of(context).pushNamedAndRemoveUntil(next, (r) => false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _phoneBubble = '없는 휴대폰 전화번호 ID입니다';
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
          '휴대폰 로그인',
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
                            labelText: '휴대폰 번호 로그인 ID',
                            hintText: '10-1234-5678',
                            filled: true,
                            fillColor: AppColors.panel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onEditingComplete: () => _pwFocus.requestFocus(),
                        ),
                      ),
                    ],
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
