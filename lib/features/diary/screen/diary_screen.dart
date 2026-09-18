import 'package:flutter/material.dart';

import 'package:hsdaily_toon/features/auth/ui/session_chrome.dart';
import 'package:hsdaily_toon/features/diary/model/diary_state.dart';
import 'package:hsdaily_toon/features/diary/model/soft_error_message.dart';
import 'package:hsdaily_toon/features/diary/screen/diary_loading_screen.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_error_bubble.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_flow_background.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_input_tools.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_widgets.dart';
import 'package:hsdaily_toon/router/page_transitions.dart';
import 'package:hsdaily_toon/services/diary_file_picker.dart';
import 'package:hsdaily_toon/services/diary_speech_service.dart';
import 'package:hsdaily_toon/services/vision_ocr_service.dart';
import 'package:hsdaily_toon/shared/layout/app_nav.dart';
import 'package:hsdaily_toon/shared/layout/responsive_layout.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Diary writing screen — freeform journal + speech/OCR + "만화로 만들기".
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _speech = DiarySpeechService();
  final _ocr = VisionOcrService();

  DiaryState _state = const DiaryState();
  bool _listening = false;
  bool _ocrBusy = false;
  String? _bubbleMessage;

  /// Snapshot of text before the current dictation session.
  String _speechBase = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _state = _state.copyWith(text: _controller.text);
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    _focusNode.dispose();
    if (_listening) {
      _speech.cancel();
    }
    super.dispose();
  }

  void _showBubble(String message) {
    setState(() => _bubbleMessage = message);
  }

  void _appendOrReplaceSpeech(String spoken, {required bool isFinal}) {
    final base = _speechBase.trimRight();
    final piece = spoken.trim();
    final next = piece.isEmpty
        ? base
        : (base.isEmpty ? piece : '$base $piece');
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    if (isFinal) {
      _speechBase = next;
    }
  }

  Future<void> _onMicPressed() async {
    if (_ocrBusy) return;

    if (_listening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _listening = false);
      return;
    }

    try {
      _speechBase = _controller.text;
      setState(() => _listening = true);
      await _speech.start(
        onResult: (text, isFinal) {
          if (!mounted) return;
          _appendOrReplaceSpeech(text, isFinal: isFinal);
          if (isFinal) {
            _speechBase = _controller.text;
          }
        },
        onStatus: (status) {
          if (!mounted) return;
          final done = status == 'done' ||
              status == 'notListening' ||
              status == SpeechToText.notListeningStatus;
          if (done && _listening) {
            setState(() => _listening = false);
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _listening = false);
      _showBubble(softInputErrorMessage(e));
    }
  }

  Future<void> _onUploadPressed() async {
    if (_listening || _ocrBusy) return;

    try {
      final picked = await DiaryFilePicker.pickImageOrPdf();
      if (picked == null) return;

      setState(() => _ocrBusy = true);
      final text = await _ocr.extractText(
        mimeType: picked.mimeType,
        dataBase64: picked.dataBase64,
      );
      if (!mounted) return;

      if (text.isEmpty) {
        _showBubble('글자를 찾지 못했어요. 다른 사진이나 PDF로 시도해 볼까요?');
        return;
      }

      final existing = _controller.text.trimRight();
      final next = existing.isEmpty ? text : '$existing\n$text';
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
      _focusNode.requestFocus();
    } catch (e) {
      if (!mounted) return;
      _showBubble(softInputErrorMessage(e));
    } finally {
      if (mounted) setState(() => _ocrBusy = false);
    }
  }

  Future<void> _onMakeComic() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
    }
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    final text = _controller.text;
    await Navigator.of(context).push<void>(
      AppPageTransitions.fadeSlide(
        DiaryLoadingScreen(diaryText: text),
      ),
    );

    if (!mounted) return;
    if (_controller.text.trim().isNotEmpty) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          ResponsiveLayout(
            sidebar: const AppNav(selected: AppNavItem.diary),
            content: _DiaryBody(
              controller: _controller,
              focusNode: _focusNode,
              canMakeComic: _state.hasContent && !_ocrBusy,
              isListening: _listening,
              isOcrBusy: _ocrBusy,
              onMakeComic: _onMakeComic,
              onMicPressed: _onMicPressed,
              onUploadPressed: _onUploadPressed,
            ),
          ),
          const SessionChrome(),
          if (_bubbleMessage != null)
            DiaryErrorBubble(
              key: ValueKey(_bubbleMessage),
              message: _bubbleMessage!,
              onDismissed: () {
                if (!mounted) return;
                setState(() => _bubbleMessage = null);
              },
            ),
        ],
      ),
    );
  }
}

class _DiaryBody extends StatelessWidget {
  const _DiaryBody({
    required this.controller,
    required this.focusNode,
    required this.canMakeComic,
    required this.isListening,
    required this.isOcrBusy,
    required this.onMakeComic,
    required this.onMicPressed,
    required this.onUploadPressed,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canMakeComic;
  final bool isListening;
  final bool isOcrBusy;
  final VoidCallback onMakeComic;
  final VoidCallback onMicPressed;
  final VoidCallback onUploadPressed;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final wide = width >= kDesktopBreakpoint;

    final horizontal = wide ? 48.0 : 24.0;
    final top = wide ? 36.0 : 24.0;
    final bottomPad = (wide ? 28.0 : 28.0) + viewInsets.bottom;
    final gapAboveButton = wide ? 16.0 : 18.0;

    return DiaryFlowBackground(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DiaryHeader(),
              SizedBox(height: wide ? 24 : 20),
              Expanded(
                child: DiaryEditor(
                  controller: controller,
                  focusNode: focusNode,
                ),
              ),
              SizedBox(height: gapAboveButton),
              DiaryInputTools(
                isListening: isListening,
                isOcrBusy: isOcrBusy,
                onMicPressed: onMicPressed,
                onUploadPressed: onUploadPressed,
              ),
              SizedBox(height: gapAboveButton),
              DiaryMakeComicButton(
                enabled: canMakeComic,
                onPressed: onMakeComic,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
