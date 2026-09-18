import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/shared/layout/responsive_layout.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

enum AppNavItem { home, diary, gallery, auth }

/// App navigation — vertical on desktop, horizontal strip on mobile.
class AppNav extends StatelessWidget {
  const AppNav({
    super.key,
    required this.selected,
  });

  final AppNavItem selected;

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;

    final items = [
      _NavSpec(
        item: AppNavItem.home,
        label: '홈',
        icon: Icons.home_outlined,
        route: AppRouter.home,
      ),
      _NavSpec(
        item: AppNavItem.diary,
        label: '일기 쓰기',
        icon: Icons.edit_note_outlined,
        route: AppRouter.diary,
      ),
      _NavSpec(
        item: AppNavItem.gallery,
        label: '갤러리',
        icon: Icons.auto_stories_outlined,
        route: AppRouter.gallery,
      ),
      _NavSpec(
        item: AppNavItem.auth,
        label: '로그인',
        icon: Icons.person_outline,
        route: AppRouter.auth,
      ),
    ];

    if (isDesktop) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.mist,
          border: Border(
            right: BorderSide(color: AppColors.line),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '4컷 일기',
                  style: GoogleFonts.gaegu(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Daily-toon',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.inkSoft,
                      ),
                ),
                const SizedBox(height: 32),
                for (final spec in items) ...[
                  _NavTile(
                    spec: spec,
                    selected: selected == spec.item,
                    dense: false,
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.mist,
        border: Border(
          bottom: BorderSide(color: AppColors.line),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final spec = items[index];
              return _NavTile(
                spec: spec,
                selected: selected == spec.item,
                dense: true,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec({
    required this.item,
    required this.label,
    required this.icon,
    required this.route,
  });

  final AppNavItem item;
  final String label;
  final IconData icon;
  final String route;
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.spec,
    required this.selected,
    required this.dense,
  });

  final _NavSpec spec;
  final bool selected;
  final bool dense;

  void _go(BuildContext context) {
    final name = ModalRoute.of(context)?.settings.name;
    if (name == spec.route) return;
    Navigator.of(context).pushReplacementNamed(spec.route);
  }

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.blushDeep : Colors.transparent;
    final fg = selected ? AppColors.roseDeep : AppColors.inkSoft;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _go(context),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 14 : 12,
            vertical: dense ? 8 : 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(spec.icon, size: 20, color: fg),
              SizedBox(width: dense ? 6 : 10),
              Text(
                spec.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: fg,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
