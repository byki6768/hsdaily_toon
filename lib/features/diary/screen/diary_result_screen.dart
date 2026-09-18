import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/diary/model/comic_models.dart';
import 'package:hsdaily_toon/features/diary/ui/comic_strip_frame.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_flow_background.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_widgets.dart';
import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// Dummy 4-cut result with home / save actions.
class DiaryResultScreen extends StatefulWidget {
  const DiaryResultScreen({super.key, required this.result});

  final ComicResult result;

  @override
  State<DiaryResultScreen> createState() => _DiaryResultScreenState();
}

class _DiaryResultScreenState extends State<DiaryResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
    _fade = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic));
    _enter.forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRouter.home,
      (route) => false,
    );
  }

  void _savePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        content: const Text('데모에서는 저장 미리보기만 지원해요. 곧 실제 저장이 연결됩니다.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 769;
    final horizontal = wide ? 48.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.blush,
      body: DiaryFlowBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontal,
                        wide ? 28 : 20,
                        horizontal,
                        12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            widget.result.strip.title,
                            style: GoogleFonts.gaegu(
                              fontSize: wide ? 40 : 34,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '더미 결과예요. 나중에 AI가 진짜 만화를 그려 줄 예정이에요.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: AppColors.inkSoft,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: FourCutComicFrame(
                              strip: widget.result.strip,
                              maxWidth: wide ? 520 : 420,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.panel.withValues(alpha: 0.94),
                      border: const Border(
                        top: BorderSide(color: AppColors.line),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontal,
                        16,
                        horizontal,
                        wide ? 20 : 18,
                      ),
                      child: DiaryResultActions(
                        onGoHome: _goHome,
                        onSavePhoto: _savePhoto,
                      ),
                    ),
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
