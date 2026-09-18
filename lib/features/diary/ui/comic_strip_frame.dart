import 'package:flutter/material.dart';

import 'package:hsdaily_toon/features/diary/model/comic_models.dart';
import 'package:hsdaily_toon/features/diary/ui/comic_panel_cell.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// Single comic page: 2×2 equal panels inside one outer frame.
///
/// Gutters are the page ink color so panels feel printed on one sheet,
/// not four separate cards.
class FourCutComicFrame extends StatelessWidget {
  const FourCutComicFrame({
    super.key,
    required this.strip,
    this.gutter = 3,
    this.borderWidth = 3,
    this.outerRadius = 14,
    this.maxWidth = 520,
    this.showCaptions = true,
  });

  final ComicStrip strip;

  /// Ink gap between panels (same color as outer border).
  final double gutter;

  final double borderWidth;
  final double outerRadius;
  final double maxWidth;
  final bool showCaptions;

  /// Overall frame is square (2×2 of square panels + gutters).
  static const double frameAspectRatio = 1;

  @override
  Widget build(BuildContext context) {
    final ink = AppColors.ink;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: AspectRatio(
          aspectRatio: frameAspectRatio,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: ink,
              borderRadius: BorderRadius.circular(outerRadius),
              border: Border.all(color: ink, width: borderWidth),
              boxShadow: [
                BoxShadow(
                  color: AppColors.rose.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                (outerRadius - borderWidth).clamp(0, outerRadius),
              ),
              child: Padding(
                padding: EdgeInsets.all(gutter),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ComicPanelCell(
                              panel: strip.panel1,
                              showCaption: showCaptions,
                            ),
                          ),
                          SizedBox(width: gutter),
                          Expanded(
                            child: ComicPanelCell(
                              panel: strip.panel2,
                              showCaption: showCaptions,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: gutter),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ComicPanelCell(
                              panel: strip.panel3,
                              showCaption: showCaptions,
                            ),
                          ),
                          SizedBox(width: gutter),
                          Expanded(
                            child: ComicPanelCell(
                              panel: strip.panel4,
                              showCaption: showCaptions,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
