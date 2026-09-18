import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/diary/model/comic_models.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// Renders a single panel image from [ComicImageSource].
/// Swap sources (network / asset / memory) without changing the frame UI.
class ComicPanelImage extends StatelessWidget {
  const ComicPanelImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
  });

  final ComicImageSource source;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return switch (source) {
      NetworkComicImage(:final url) => Image.network(
          url,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, _, _) => const _BrokenImage(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const ColoredBox(
              color: AppColors.mist,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      AssetComicImage(:final assetPath) => Image.asset(
          assetPath,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, _, _) => const _BrokenImage(),
        ),
      MemoryComicImage(:final bytes) => Image.memory(
          bytes,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, _, _) => const _BrokenImage(),
        ),
      PlaceholderComicImage(:final tint, :final label) =>
        _DummyPanelImage(tint: tint, label: label),
    };
  }
}

class _BrokenImage extends StatelessWidget {
  const _BrokenImage();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.mist,
      child: Center(
        child: Icon(Icons.broken_image_outlined, color: AppColors.inkSoft),
      ),
    );
  }
}

/// Soft illustrated placeholder that reads as a panel image.
class _DummyPanelImage extends StatelessWidget {
  const _DummyPanelImage({required this.tint, required this.label});

  final Color tint;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint,
            Color.lerp(tint, AppColors.petal, 0.35)!,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -12,
            bottom: -18,
            child: Icon(
              Icons.auto_stories_rounded,
              size: 88,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.gaegu(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'dummy',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    color: AppColors.inkSoft.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One square cell inside the strip (no card chrome — frame owns borders).
class ComicPanelCell extends StatelessWidget {
  const ComicPanelCell({
    super.key,
    required this.panel,
    this.showCaption = true,
  });

  final ComicPanel panel;
  final bool showCaption;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ComicPanelImage(source: panel.image),
        if (showCaption && panel.caption.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.ink.withValues(alpha: 0.55),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
                child: Text(
                  panel.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 6,
          left: 6,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.panel.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                '${panel.index}',
                style: GoogleFonts.gaegu(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.roseDeep,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
