import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// Home brand header — title + short description.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width >= 769 ? 64.0 : 48.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '4컷 일기',
          style: GoogleFonts.gaegu(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '오늘의 마음을 네 칸의 만화로 남겨 보세요.\n따뜻하게, 천천히, 당신만의 하루를 그립니다.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: width >= 769 ? 17 : 15,
              ),
        ),
      ],
    );
  }
}

/// Primary home actions.
class HomeActions extends StatelessWidget {
  const HomeActions({super.key});

  @override
  Widget build(BuildContext context) {
    final writeBtn = FilledButton.icon(
      onPressed: () => Navigator.of(context).pushNamed(AppRouter.diary),
      icon: const Icon(Icons.edit_note_rounded, size: 22),
      label: const Text('오늘의 일기 쓰기'),
    );

    final galleryBtn = OutlinedButton.icon(
      onPressed: () => Navigator.of(context).pushNamed(AppRouter.gallery),
      icon: const Icon(Icons.auto_stories_outlined, size: 20),
      label: const Text('내 만화 갤러리 보기'),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 520;

        if (isWide) {
          return Row(
            children: [
              Flexible(child: writeBtn),
              const SizedBox(width: 12),
              Flexible(child: galleryBtn),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            writeBtn,
            const SizedBox(height: 10),
            galleryBtn,
          ],
        );
      },
    );
  }
}

/// Soft decorative panels suggesting a four-panel comic strip.
class HomeComicHint extends StatelessWidget {
  const HomeComicHint({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(160.0, 420.0)
            : 320.0;

        return SizedBox(
          width: maxW,
          child: AspectRatio(
            aspectRatio: 1.15,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.panel.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
              ),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _Panel(label: '1', tint: Color(0xFFFFD9CE)),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _Panel(label: '2', tint: Color(0xFFFFE6DC)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _Panel(label: '3', tint: Color(0xFFF5D4D4)),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _Panel(label: '4', tint: Color(0xFFFFEFE8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.label, required this.tint});

  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.8)),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.gaegu(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.rose.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}
