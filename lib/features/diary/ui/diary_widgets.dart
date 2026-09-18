import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/theme/app_theme.dart';

/// Diary screen title and short prompt.
class DiaryHeader extends StatelessWidget {
  const DiaryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 769;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 일기',
          style: GoogleFonts.gaegu(
            fontSize: wide ? 44 : 36,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '오늘 하루를 편하게 적어 보세요.\n말로 하거나 사진·PDF를 올려도 좋아요.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: wide ? 16 : 15,
                color: AppColors.inkSoft,
              ),
        ),
      ],
    );
  }
}

/// Multiline journal editor with warm paper-like styling.
class DiaryEditor extends StatelessWidget {
  const DiaryEditor({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 769;

    return Material(
      color: AppColors.panel,
      elevation: 0,
      borderRadius: BorderRadius.circular(22),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: AppColors.rose.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: TextStyle(
            fontSize: wide ? 16.5 : 16,
            height: 1.65,
            color: AppColors.ink,
          ),
          cursorColor: AppColors.rose,
          decoration: InputDecoration(
            hintText: '예) 오늘은 비가 와서 창밖을 오래 바라봤어. 커피 향이 유난히 좋았고…',
            hintStyle: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.inkSoft.withValues(alpha: 0.55),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.fromLTRB(
              wide ? 28 : 22,
              wide ? 24 : 22,
              wide ? 28 : 22,
              wide ? 24 : 22,
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom CTA — "만화로 만들기".
class DiaryMakeComicButton extends StatelessWidget {
  const DiaryMakeComicButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.rose,
          disabledBackgroundColor: AppColors.petal.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.75),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          '만화로 만들기',
          style: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

/// Result screen actions — always shows both required buttons.
class DiaryResultActions extends StatelessWidget {
  const DiaryResultActions({
    super.key,
    required this.onGoHome,
    required this.onSavePhoto,
  });

  final VoidCallback onGoHome;
  final VoidCallback onSavePhoto;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 520;

        final homeBtn = OutlinedButton.icon(
          onPressed: onGoHome,
          icon: const Icon(Icons.home_outlined, size: 20),
          label: const Text('홈으로 돌아가기'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            foregroundColor: AppColors.roseDeep,
            side: const BorderSide(color: AppColors.rose, width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        );

        final saveBtn = FilledButton.icon(
          onPressed: onSavePhoto,
          icon: const Icon(Icons.download_outlined, size: 20),
          label: const Text('사진 저장하기'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: AppColors.rose,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        );

        if (sideBySide) {
          return Row(
            children: [
              Expanded(child: homeBtn),
              const SizedBox(width: 12),
              Expanded(child: saveBtn),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            saveBtn,
            const SizedBox(height: 12),
            homeBtn,
          ],
        );
      },
    );
  }
}
