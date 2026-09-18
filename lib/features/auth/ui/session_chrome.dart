import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/services/auth_service.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// Top-right logout + mypage actions (shown when signed in).
class SessionChrome extends StatelessWidget {
  const SessionChrome({super.key});

  Future<void> _logout(BuildContext context) async {
    await authService?.syncAndSignOut();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRouter.landing,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = authService;
    if (auth == null) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        if (!auth.isSignedIn) return const SizedBox.shrink();
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 12, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ChromeChip(
                    icon: Icons.logout_rounded,
                    label: '로그아웃',
                    onTap: () => _logout(context),
                  ),
                  const SizedBox(width: 8),
                  _ChromeChip(
                    icon: Icons.person_outline_rounded,
                    label: '마이페이지',
                    onTap: () {
                      final name = ModalRoute.of(context)?.settings.name;
                      if (name == AppRouter.mypage) return;
                      Navigator.of(context).pushNamed(AppRouter.mypage);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChromeChip extends StatelessWidget {
  const _ChromeChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.panel.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(999),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.roseDeep),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.notoSansKr(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
