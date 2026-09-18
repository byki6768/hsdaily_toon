import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/auth/model/auth_validators.dart';
import 'package:hsdaily_toon/features/auth/ui/auth_form_widgets.dart';
import 'package:hsdaily_toon/features/auth/ui/session_chrome.dart';
import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/services/auth_service.dart';
import 'package:hsdaily_toon/shared/layout/app_nav.dart';
import 'package:hsdaily_toon/shared/layout/responsive_layout.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  late final TextEditingController _nick;
  final _newPw = TextEditingController();
  final _newPw2 = TextEditingController();

  bool _editingNick = false;
  bool _editingPw = false;
  bool _withdrawArmed = false;
  bool _busy = false;
  String _pwBubble = '';
  String _withdrawBubble = '';

  @override
  void initState() {
    super.initState();
    _nick = TextEditingController(
      text: authService?.profile?.nickname ?? '',
    );
  }

  @override
  void dispose() {
    _nick.dispose();
    _newPw.dispose();
    _newPw2.dispose();
    super.dispose();
  }

  Future<void> _saveNick() async {
    setState(() => _busy = true);
    try {
      await authService!.updateNickname(_nick.text);
      if (!mounted) return;
      setState(() => _editingNick = false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _savePw() async {
    if (!AuthValidators.isPassword(_newPw.text)) {
      setState(() => _pwBubble = '문자 또는 숫자로만 입력하세요');
      return;
    }
    if (_newPw.text != _newPw2.text) {
      setState(() => _pwBubble = '비밀번호가 일치하지 않습니다');
      return;
    }
    setState(() {
      _busy = true;
      _pwBubble = '';
    });
    try {
      await authService!.updatePasswordDirect(_newPw.text);
      if (!mounted) return;
      setState(() {
        _editingPw = false;
        _newPw.clear();
        _newPw2.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 변경되었어요.')),
      );
    } catch (_) {
      setState(() => _pwBubble = '비밀번호 변경에 실패했어요. 다시 로그인해 주세요');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _withdraw() async {
    if (!_withdrawArmed) {
      setState(() {
        _withdrawArmed = true;
        _withdrawBubble = '탈퇴하시면 모든 기록이 사라집니다! 그래도 탈퇴하시겠습니까?';
      });
      return;
    }
    setState(() => _busy = true);
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast3')
          .httpsCallable('withdrawMember');
      await callable.call();
      await authService!.syncAndSignOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('탈퇴가 완료 되었습니다!')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.landing,
        (r) => false,
      );
    } catch (_) {
      setState(() => _withdrawBubble = '탈퇴 처리에 실패했어요. 잠시 후 다시 시도해 주세요');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = authService?.profile;
    final nickHint = profile?.publicId ?? '닉네임을 입력해 주세요';

    return Scaffold(
      backgroundColor: AppColors.blush,
      body: Stack(
        children: [
          ResponsiveLayout(
            sidebar: const AppNav(selected: AppNavItem.mypage),
            content: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 56, 28, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '마이페이지',
                          style: GoogleFonts.gaegu(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text('닉네임', style: GoogleFonts.gaegu(fontSize: 18)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nick,
                                enabled: _editingNick,
                                decoration: InputDecoration(
                                  hintText: nickHint,
                                  filled: true,
                                  fillColor: AppColors.panel,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!_editingNick)
                              TextButton(
                                onPressed: () =>
                                    setState(() => _editingNick = true),
                                child: const Text('수정'),
                              )
                            else
                              TextButton(
                                onPressed: _busy ? null : _saveNick,
                                child: const Text('확인'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text('비밀번호', style: GoogleFonts.gaegu(fontSize: 18)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              AuthValidators.maskPasswordDisplay(),
                              style: const TextStyle(
                                fontSize: 18,
                                letterSpacing: 2,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _editingPw = !_editingPw),
                              child: Text(_editingPw ? '취소' : '수정'),
                            ),
                          ],
                        ),
                        if (_editingPw) ...[
                          const SizedBox(height: 12),
                          AuthFieldBubble(message: _pwBubble),
                          AuthPasswordField(controller: _newPw),
                          const SizedBox(height: 10),
                          AuthPasswordField(controller: _newPw2),
                          const SizedBox(height: 12),
                          AuthPrimaryButton(
                            label: '수정 확인',
                            busy: _busy,
                            onPressed: _savePw,
                          ),
                        ],
                        const SizedBox(height: 28),
                        if (_withdrawBubble.isNotEmpty) ...[
                          AuthFieldBubble(message: _withdrawBubble),
                          const SizedBox(height: 8),
                        ],
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: _busy ? null : _withdraw,
                            style: FilledButton.styleFrom(
                              backgroundColor: _withdrawArmed
                                  ? const Color(0xFF2F6B5A)
                                  : AppColors.roseDeep,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              _withdrawArmed ? '탈퇴 확인' : '회원탈퇴',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SessionChrome(),
        ],
      ),
    );
  }
}
