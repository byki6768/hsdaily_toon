import 'package:flutter/material.dart';

import 'package:hsdaily_toon/features/auth/ui/session_chrome.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_flow_background.dart';
import 'package:hsdaily_toon/features/gallery/model/dummy_gallery_data.dart';
import 'package:hsdaily_toon/features/gallery/model/gallery_item.dart';
import 'package:hsdaily_toon/features/gallery/screen/gallery_detail_screen.dart';
import 'package:hsdaily_toon/features/gallery/ui/gallery_widgets.dart';
import 'package:hsdaily_toon/router/page_transitions.dart';
import 'package:hsdaily_toon/shared/layout/app_nav.dart';
import 'package:hsdaily_toon/shared/layout/responsive_layout.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// Gallery list — dummy Daily-toon entries with thumbnail + date.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late final GalleryState _state;

  @override
  void initState() {
    super.initState();
    _state = GalleryState(items: DummyGalleryData.items());
  }

  void _openDetail(GalleryItem item) {
    Navigator.of(context).push(
      AppPageTransitions.fadeSlide(
        GalleryDetailScreen(item: item),
        begin: const Offset(0.04, 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      body: Stack(
        children: [
          ResponsiveLayout(
            sidebar: const AppNav(selected: AppNavItem.gallery),
            content: DiaryFlowBackground(
              child: SafeArea(
                child: _GalleryBody(
                  state: _state,
                  onOpen: _openDetail,
                ),
              ),
            ),
          ),
          const SessionChrome(),
        ],
      ),
    );
  }
}

class _GalleryBody extends StatelessWidget {
  const _GalleryBody({
    required this.state,
    required this.onOpen,
  });

  final GalleryState state;
  final ValueChanged<GalleryItem> onOpen;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    final horizontal = wide ? 48.0 : 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(horizontal, wide ? 36 : 24, horizontal, 8),
          child: GalleryHeader(count: state.items.length),
        ),
        Expanded(
          child: state.isEmpty
              ? const GalleryEmptyState()
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    16,
                    horizontal,
                    wide ? 32 : 24,
                  ),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return GalleryListTile(
                      item: item,
                      onTap: () => onOpen(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
