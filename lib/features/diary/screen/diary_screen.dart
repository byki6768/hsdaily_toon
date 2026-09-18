import 'package:flutter/material.dart';

import 'package:hsdaily_toon/features/diary/model/diary_state.dart';
import 'package:hsdaily_toon/features/diary/screen/diary_loading_screen.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_flow_background.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_widgets.dart';
import 'package:hsdaily_toon/router/page_transitions.dart';
import 'package:hsdaily_toon/shared/layout/app_nav.dart';
import 'package:hsdaily_toon/shared/layout/responsive_layout.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// Diary writing screen — freeform journal + "만화로 만들기".
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  DiaryState _state = const DiaryState();

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
    super.dispose();
  }

  void _onMakeComic() {
    FocusScope.of(context).unfocus();
    final text = _controller.text;
    Navigator.of(context).push(
      AppPageTransitions.fadeSlide(
        DiaryLoadingScreen(diaryText: text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      resizeToAvoidBottomInset: true,
      body: ResponsiveLayout(
        sidebar: const AppNav(selected: AppNavItem.diary),
        content: _DiaryBody(
          controller: _controller,
          focusNode: _focusNode,
          canMakeComic: _state.hasContent,
          onMakeComic: _onMakeComic,
        ),
      ),
    );
  }
}

class _DiaryBody extends StatelessWidget {
  const _DiaryBody({
    required this.controller,
    required this.focusNode,
    required this.canMakeComic,
    required this.onMakeComic,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canMakeComic;
  final VoidCallback onMakeComic;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final wide = width >= kDesktopBreakpoint;

    final horizontal = wide ? 48.0 : 24.0;
    final top = wide ? 36.0 : 24.0;
    final bottomPad = (wide ? 28.0 : 28.0) + viewInsets.bottom;
    final gapAboveButton = wide ? 20.0 : 28.0;

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
