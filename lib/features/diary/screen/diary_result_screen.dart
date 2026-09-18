import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/diary/model/comic_models.dart';
import 'package:hsdaily_toon/features/diary/screen/diary_loading_screen.dart';
import 'package:hsdaily_toon/features/diary/ui/comic_strip_frame.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_flow_background.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_widgets.dart';
import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/router/page_transitions.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// 4-cut result — step 1 shows scenario captions; step 2 shows finished art.
class DiaryResultScreen extends StatefulWidget {
  const DiaryResultScreen({super.key, required this.result});

  final ComicResult result;

  @override
  State<DiaryResultScreen> createState() => _DiaryResultScreenState();
}

class _DiaryResultScreenState extends State<DiaryResultScreen>
    with SingleTickerProviderStateMixin {
  late ComicResult _result;
  late final AnimationController _enter;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _result = widget.result;
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

  Future<void> _makeComicImages() async {
    await Navigator.of(context).push(
      AppPageTransitions.fadeSlide(
        DiaryLoadingScreen(
          diaryText: _result.diaryText,
          phase: DiaryLoadingPhase.images,
          scenarioResult: _result,
        ),
      ),
    );
    // On image failure, loading pops back here with scenario still shown.
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 769;
    final horizontal = wide ? 48.0 : 24.0;
    final isScenario = !_result.hasImages;

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
                            _result.strip.title,
                            style: GoogleFonts.gaegu(
                              fontSize: wide ? 40 : 34,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isScenario
                                ? '네 컷 시나리오가 준비됐어요. 다시 버튼을 누르면 그림을 그려 줄게요.'
                                : '일기에서 만든 오늘의 네 컷이에요.',
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: AppColors.inkSoft,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: FourCutComicFrame(
                              strip: _result.strip,
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
                      child: isScenario
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DiaryMakeComicButton(
                                  enabled: true,
                                  onPressed: _makeComicImages,
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: _goHome,
                                  child: const Text('홈으로 돌아가기'),
                                ),
                              ],
                            )
                          : DiaryResultActions(
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
