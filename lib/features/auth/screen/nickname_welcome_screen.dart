import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/auth/ui/auth_form_widgets.dart';
import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/services/auth_service.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

class NicknameWelcomeScreen extends StatefulWidget {
  const NicknameWelcomeScreen({super.key});

  @override
  State<NicknameWelcomeScreen> createState() => _NicknameWelcomeScreenState();
}

class _NicknameWelcomeScreenState extends State<NicknameWelcomeScreen> {
  late final TextEditingController _nick;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final id = authService?.profile?.publicId ?? '';
    _nick = TextEditingController();
    _nick.value = TextEditingValue(
      text: '',
      selection: const TextSelection.collapsed(offset: 0),
    );
    // Placeholder shows publicId via decoration.
    _placeholderId = id;
  }

  late String _placeholderId;

  @override
  void dispose() {
    _nick.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() => _busy = true);
    try {
      await authService!.saveNickname(_nick.text);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.home,
        (r) => false,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF8F4), AppColors.blush, AppColors.blushDeep],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    Icon(
                      Icons.celebration_outlined,
                      size: 56,
                      color: AppColors.rose.withValues(alpha: 0.9),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '가입을 축하해요!',
                      style: GoogleFonts.gaegu(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '오늘의 네 컷이 기다릴게요.\n나를 부를 닉네임을 정해 볼까요?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.inkSoft,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      '나의 닉네임',
                      style: GoogleFonts.gaegu(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nick,
                      decoration: InputDecoration(
                        hintText: _placeholderId,
                        filled: true,
                        fillColor: AppColors.panel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '비워 두면 고유 ID가 닉네임이 돼요.',
                      style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                    ),
                    const SizedBox(height: 28),
                    AuthPrimaryButton(
                      label: '확인',
                      busy: _busy,
                      onPressed: _confirm,
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
