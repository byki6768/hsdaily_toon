import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:hsdaily_toon/services/scenario_service.dart';

/// Whether the result screen is showing scenario text only or finished art.
enum ComicResultStage { scenario, images }

/// Where a panel image comes from — swap dummy → AI later without UI changes.
sealed class ComicImageSource {
  const ComicImageSource();
}

/// Remote URL (e.g. Firebase Storage / CDN).
class NetworkComicImage extends ComicImageSource {
  const NetworkComicImage(this.url);
  final String url;
}

/// Bundled asset path (e.g. `assets/comics/panel_1.png`).
class AssetComicImage extends ComicImageSource {
  const AssetComicImage(this.assetPath);
  final String assetPath;
}

/// In-memory bytes (generated or downloaded image).
class MemoryComicImage extends ComicImageSource {
  const MemoryComicImage(this.bytes);
  final Uint8List bytes;
}

/// Local demo placeholder until real images are wired.
class PlaceholderComicImage extends ComicImageSource {
  const PlaceholderComicImage({
    required this.tint,
    required this.label,
  });

  final Color tint;
  final String label;
}

/// One cut inside a 4-panel strip.
class ComicPanel {
  const ComicPanel({
    required this.index,
    required this.image,
    this.caption = '',
  });

  /// 1–4
  final int index;

  /// Image payload — replace [PlaceholderComicImage] with network/asset later.
  final ComicImageSource image;

  final String caption;
}

/// A complete 4-cut Daily-toon (always 4 panels in reading order).
class ComicStrip {
  ComicStrip({
    required this.panels,
    this.title = '오늘의 4컷 일기',
  }) : assert(panels.length == 4, 'ComicStrip requires exactly 4 panels');

  final String title;
  final List<ComicPanel> panels;

  ComicPanel get panel1 => panels[0];
  ComicPanel get panel2 => panels[1];
  ComicPanel get panel3 => panels[2];
  ComicPanel get panel4 => panels[3];
}

/// Result of the diary → comic flow (diary text + strip).
class ComicResult {
  const ComicResult({
    required this.diaryText,
    required this.strip,
    this.scenario,
    this.stage = ComicResultStage.scenario,
  });

  final String diaryText;
  final ComicStrip strip;

  /// Server scenario payload — needed for step-2 image generation.
  final GeneratedScenario? scenario;

  /// Whether this result is scenario-only or has finished images.
  final ComicResultStage stage;

  List<ComicPanel> get panels => strip.panels;

  bool get hasImages => stage == ComicResultStage.images;

  /// Builds a strip from Gemini scenario + optional panel image URLs.
  factory ComicResult.fromGeneratedScenario({
    required String diaryText,
    required String title,
    required List<({int index, String description, String label})> panels,
    List<String> imageUrls = const [],
    GeneratedScenario? scenario,
    ComicResultStage? stage,
  }) {
    assert(panels.length == 4);
    const tints = <Color>[
      Color(0xFFFFD4C4),
      Color(0xFFFFE0D2),
      Color(0xFFF3C8C8),
      Color(0xFFFFE8DE),
    ];
    final hasImages = imageUrls.length == 4 &&
        imageUrls.every((url) => url.trim().isNotEmpty);

    return ComicResult(
      diaryText: diaryText,
      scenario: scenario,
      stage: stage ??
          (hasImages ? ComicResultStage.images : ComicResultStage.scenario),
      strip: ComicStrip(
        title: title,
        panels: [
          for (var i = 0; i < 4; i++)
            ComicPanel(
              index: panels[i].index,
              caption: panels[i].description,
              image: hasImages
                  ? NetworkComicImage(imageUrls[i])
                  : PlaceholderComicImage(
                      tint: tints[i],
                      label: panels[i].label.isEmpty
                          ? '${panels[i].index}'
                          : panels[i].label,
                    ),
            ),
        ],
      ),
    );
  }

  ComicResult withImages(List<String> imageUrls) {
    assert(imageUrls.length == 4);
    return ComicResult.fromGeneratedScenario(
      diaryText: diaryText,
      title: strip.title,
      scenario: scenario,
      imageUrls: imageUrls,
      stage: ComicResultStage.images,
      panels: [
        for (final p in panels)
          (
            index: p.index,
            description: p.caption,
            label: switch (p.image) {
              PlaceholderComicImage(:final label) => label,
              _ => '${p.index}',
            },
          ),
      ],
    );
  }

  /// Dummy 4-cut for offline / fallback.
  factory ComicResult.dummyFromDiary(String diaryText) {
    final snippet = diaryText.trim().replaceAll(RegExp(r'\s+'), ' ');
    final hint = snippet.isEmpty
        ? '평범한 하루'
        : (snippet.length > 28 ? '${snippet.substring(0, 28)}…' : snippet);

    return ComicResult(
      diaryText: diaryText,
      strip: ComicStrip(
        panels: [
          ComicPanel(
            index: 1,
            caption: '창가에서 하루를 연다 · $hint',
            image: const PlaceholderComicImage(
              tint: Color(0xFFFFD4C4),
              label: '아침',
            ),
          ),
          ComicPanel(
            index: 2,
            caption: '작은 일들로 마음이 분주해진다',
            image: const PlaceholderComicImage(
              tint: Color(0xFFFFE0D2),
              label: '낮',
            ),
          ),
          ComicPanel(
            index: 3,
            caption: '하루의 결을 천천히 만져 본다',
            image: const PlaceholderComicImage(
              tint: Color(0xFFF3C8C8),
              label: '저녁',
            ),
          ),
          ComicPanel(
            index: 4,
            caption: '네 칸에 담은 오늘, 내일을 향해',
            image: const PlaceholderComicImage(
              tint: Color(0xFFFFE8DE),
              label: '밤',
            ),
          ),
        ],
      ),
    );
  }
}
