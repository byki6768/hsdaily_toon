import 'package:flutter/material.dart';

import 'package:hsdaily_toon/features/diary/model/comic_models.dart';
import 'package:hsdaily_toon/features/diary/ui/comic_panel_cell.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// Compact 2×2 preview used as a gallery list thumbnail.
class ComicStripThumbnail extends StatelessWidget {
  const ComicStripThumbnail({
    super.key,
    required this.strip,
    this.size = 72,
    this.gutter = 2,
  });

  final ComicStrip strip;
  final double size;
  final double gutter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.all(gutter),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _ThumbCell(image: strip.panel1.image)),
                      SizedBox(width: gutter),
                      Expanded(child: _ThumbCell(image: strip.panel2.image)),
                    ],
                  ),
                ),
                SizedBox(height: gutter),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _ThumbCell(image: strip.panel3.image)),
                      SizedBox(width: gutter),
                      Expanded(child: _ThumbCell(image: strip.panel4.image)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThumbCell extends StatelessWidget {
  const _ThumbCell({required this.image});

  final ComicImageSource image;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ComicPanelImage(source: image),
    );
  }
}
