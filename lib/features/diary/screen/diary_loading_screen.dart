import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/diary/model/comic_models.dart';
import 'package:hsdaily_toon/features/diary/screen/diary_result_screen.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_flow_background.dart';
import 'package:hsdaily_toon/router/page_transitions.dart';
import 'package:hsdaily_toon/services/scenario_service.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// Loading bridge: Gemini scenario generation → result screen.
class DiaryLoadingScreen extends StatefulWidget {
  const DiaryLoadingScreen({super.key, required this.diaryText});

  final String diaryText;

  @override
  State<DiaryLoadingScreen> createState() => _DiaryLoadingScreenState();
}

class _DiaryLoadingScreenState extends State<DiaryLoadingScreen>
    with SingleTickerProviderStateMixin {
  static const _messages = [
    '오늘의 장면을 고르고 있어요…',
    '네 칸의 결을 맞추는 중…',
    '따뜻하게 색을 입히는 중…',
  ];

  late final AnimationController _pulse;
  int _messageIndex = 0;
  Timer? _messageTimer;
  String? _errorMessage;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _messageTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted || !_busy) return;
      setState(() {
        _messageIndex = (_messageIndex + 1) % _messages.length;
      });
    });

    unawaited(_generate());
  }

  Future<void> _generate() async {
    setState(() {
      _busy = true;
      _errorMessage = null;
    });

    try {
      final generated =
          await ScenarioService().generateFromDiary(widget.diaryText);
      if (!mounted) return;

      final result = ComicResult.fromGeneratedScenario(
        diaryText: widget.diaryText,
        title: generated.title,
        panels: [
          for (final p in generated.panels)
            (index: p.index, description: p.description, label: p.label),
        ],
      );

      await Navigator.of(context).pushReplacement(
        AppPageTransitions.fadeSlide(
          DiaryResultScreen(result: result),
          begin: const Offset(0, 0.08),
          duration: const Duration(milliseconds: 560),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        final detail = (e.message ?? '').trim();
        _errorMessage = detail.isEmpty
            ? '시나리오 생성에 실패했어요. (${e.code})'
            : detail;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _errorMessage = '시나리오 생성에 실패했어요. 네트워크를 확인해 주세요.';
      });
    }
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      body: DiaryFlowBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.92, end: 1.06).animate(
                      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                    ),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.line),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.rose.withValues(alpha: 0.18),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.rose,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _errorMessage == null ? '만화로 만드는 중' : '잠시만요',
                    style: GoogleFonts.gaegu(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_errorMessage == null)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: Text(
                        _messages[_messageIndex],
                        key: ValueKey(_messageIndex),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    )
                  else ...[
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _busy ? null : _generate,
                      child: const Text('다시 시도'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('돌아가기'),
                    ),
                  ],
                  if (_errorMessage == null) ...[
                    const SizedBox(height: 36),
                    const SizedBox(
                      width: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(99)),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          backgroundColor: AppColors.line,
                          color: AppColors.rose,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
