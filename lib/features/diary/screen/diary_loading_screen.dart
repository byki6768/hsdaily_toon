import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/diary/model/comic_models.dart';
import 'package:hsdaily_toon/features/diary/model/soft_error_message.dart';
import 'package:hsdaily_toon/features/diary/screen/diary_result_screen.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_error_bubble.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_flow_background.dart';
import 'package:hsdaily_toon/router/page_transitions.dart';
import 'package:hsdaily_toon/services/scenario_service.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// What the loading screen should produce.
enum DiaryLoadingPhase {
  /// Step 1: diary → 4 scenario captions.
  scenario,

  /// Step 2: scenario → 4 panel images.
  images,
}

/// Loading bridge for scenario or image generation.
/// On failure, shows a soft speech bubble for 3s then pops back.
class DiaryLoadingScreen extends StatefulWidget {
  const DiaryLoadingScreen({
    super.key,
    required this.diaryText,
    this.phase = DiaryLoadingPhase.scenario,
    this.scenarioResult,
  }) : assert(
          phase == DiaryLoadingPhase.scenario || scenarioResult != null,
          'scenarioResult is required for image generation',
        );

  final String diaryText;
  final DiaryLoadingPhase phase;

  /// Existing scenario result when [phase] is [DiaryLoadingPhase.images].
  final ComicResult? scenarioResult;

  @override
  State<DiaryLoadingScreen> createState() => _DiaryLoadingScreenState();
}

class _DiaryLoadingScreenState extends State<DiaryLoadingScreen>
    with SingleTickerProviderStateMixin {
  static const _scenarioMessages = [
    '오늘의 장면을 고르고 있어요…',
    '네 칸의 결을 맞추는 중…',
    '이야기의 흐름을 다듬는 중…',
  ];

  static const _imageMessages = [
    '따뜻하게 그림을 그리는 중…',
    '컷마다 색을 입히는 중…',
    '네 칸에 숨을 불어넣는 중…',
  ];

  late final AnimationController _pulse;
  int _messageIndex = 0;
  Timer? _messageTimer;
  String? _errorMessage;
  bool _returning = false;

  List<String> get _messages => widget.phase == DiaryLoadingPhase.images
      ? _imageMessages
      : _scenarioMessages;

  String get _title =>
      widget.phase == DiaryLoadingPhase.images ? '그림을 그리는 중' : '시나리오 만드는 중';

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _messageTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted || _errorMessage != null) return;
      setState(() {
        _messageIndex = (_messageIndex + 1) % _messages.length;
      });
    });

    unawaited(_generate());
  }

  Future<void> _generate() async {
    try {
      if (widget.phase == DiaryLoadingPhase.scenario) {
        await _generateScenario();
      } else {
        await _generateImages();
      }
    } catch (e) {
      await _showErrorThenReturn(softComicErrorMessage(e));
    }
  }

  Future<void> _generateScenario() async {
    final generated =
        await ScenarioService().generateFromDiary(widget.diaryText);
    if (!mounted) return;

    final result = ComicResult.fromGeneratedScenario(
      diaryText: widget.diaryText,
      title: generated.title,
      scenario: generated,
      stage: ComicResultStage.scenario,
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
  }

  Future<void> _generateImages() async {
    final base = widget.scenarioResult!;
    final scenario = base.scenario;
    if (scenario == null) {
      throw StateError('Missing scenario for image generation');
    }

    final images = await ScenarioService().generateImages(scenario);
    if (!mounted) return;

    final result = base.withImages(images.imageUrls);

    await Navigator.of(context).pushReplacement(
      AppPageTransitions.fadeSlide(
        DiaryResultScreen(result: result),
        begin: const Offset(0, 0.08),
        duration: const Duration(milliseconds: 560),
      ),
    );
  }

  Future<void> _showErrorThenReturn(String message) async {
    if (!mounted || _returning) return;
    _returning = true;
    _pulse.stop();
    setState(() => _errorMessage = message);

    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.of(context).pop();
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
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.92, end: 1.06).animate(
                          CurvedAnimation(
                            parent: _pulse,
                            curve: Curves.easeInOut,
                          ),
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
                          child: Icon(
                            _errorMessage == null
                                ? (widget.phase == DiaryLoadingPhase.images
                                    ? Icons.brush_outlined
                                    : Icons.auto_awesome)
                                : Icons.favorite_border_rounded,
                            color: AppColors.rose,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        _errorMessage == null ? _title : '잠시만요',
                        style: GoogleFonts.gaegu(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_errorMessage == null) ...[
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: Text(
                            _messages[_messageIndex],
                            key: ValueKey('${widget.phase}-$_messageIndex'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: AppColors.inkSoft,
                            ),
                          ),
                        ),
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
                      ] else
                        Text(
                          widget.phase == DiaryLoadingPhase.images
                              ? '시나리오 화면으로 돌아갈게요.'
                              : '방금 쓰신 일기로 돌아갈게요.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: AppColors.inkSoft,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (_errorMessage != null)
              DiaryErrorBubble(
                message: _errorMessage!,
                duration: const Duration(seconds: 3),
              ),
          ],
        ),
      ),
    );
  }
}
