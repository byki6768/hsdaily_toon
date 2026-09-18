import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// One scene in a Gemini-generated 4-cut scenario.
class ScenarioPanel {
  const ScenarioPanel({
    required this.index,
    required this.description,
    this.label = '',
  });

  final int index;
  final String description;
  final String label;

  factory ScenarioPanel.fromMap(Map<String, dynamic> map) {
    return ScenarioPanel(
      index: (map['index'] as num?)?.toInt() ?? 0,
      description: (map['description'] as String?)?.trim() ?? '',
      label: (map['label'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'index': index,
        'description': description,
        'label': label,
      };
}

/// Result of step 1 — [ScenarioService.generateFromDiary].
class GeneratedScenario {
  const GeneratedScenario({
    required this.scenarioId,
    required this.diaryId,
    required this.publicId,
    required this.title,
    required this.model,
    required this.text,
    required this.panels,
  });

  final String scenarioId;
  final String diaryId;
  final String publicId;
  final String title;
  final String model;
  final String text;
  final List<ScenarioPanel> panels;

  factory GeneratedScenario.fromMap(Map<String, dynamic> data) {
    final rawPanels = (data['panels'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => ScenarioPanel.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    return GeneratedScenario(
      scenarioId: data['scenarioId'] as String? ?? '',
      diaryId: data['diaryId'] as String? ?? '',
      publicId: data['publicId'] as String? ?? '',
      title: data['title'] as String? ?? '오늘의 4컷 일기',
      model: data['model'] as String? ?? '',
      text: data['text'] as String? ?? '',
      panels: rawPanels,
    );
  }
}

/// Result of step 2 — [ScenarioService.generateImages].
class GeneratedComicImages {
  const GeneratedComicImages({
    required this.comicId,
    required this.imageUrls,
    this.title = '',
    this.scenarioId = '',
  });

  final String comicId;
  final List<String> imageUrls;
  final String title;
  final String scenarioId;

  factory GeneratedComicImages.fromMap(Map<String, dynamic> data) {
    final rawUrls = (data['imageUrls'] as List<dynamic>? ?? const [])
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    return GeneratedComicImages(
      comicId: data['comicId'] as String? ?? '',
      imageUrls: rawUrls,
      title: data['title'] as String? ?? '',
      scenarioId: data['scenarioId'] as String? ?? '',
    );
  }
}

/// Calls Cloud Functions for scenario (step 1) and images (step 2).
class ScenarioService {
  ScenarioService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'asia-northeast3');

  final FirebaseFunctions _functions;

  /// Step 1: diary text → 4 panel scenario descriptions.
  Future<GeneratedScenario> generateFromDiary(String diaryText) async {
    final callable = _functions.httpsCallable(
      'generateComicScenario',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 120)),
    );

    try {
      final result = await callable.call(<String, dynamic>{
        'diaryText': diaryText,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      final scenario = GeneratedScenario.fromMap(data);
      if (scenario.panels.length != 4) {
        throw StateError('Expected 4 panels, got ${scenario.panels.length}');
      }
      return scenario;
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint('generateComicScenario failed: ${e.code} ${e.message}\n$st');
      rethrow;
    }
  }

  /// Step 2: scenario panels → 4 comic image URLs.
  Future<GeneratedComicImages> generateImages(
    GeneratedScenario scenario,
  ) async {
    final callable = _functions.httpsCallable(
      'generateComicImages',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 540)),
    );

    try {
      final result = await callable.call(<String, dynamic>{
        'scenarioId': scenario.scenarioId,
        'publicId': scenario.publicId,
        'diaryId': scenario.diaryId,
        'title': scenario.title,
        'panels': [for (final p in scenario.panels) p.toMap()],
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      final images = GeneratedComicImages.fromMap(data);
      if (images.imageUrls.length != 4) {
        throw StateError(
          'Expected 4 imageUrls, got ${images.imageUrls.length}',
        );
      }
      return images;
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint('generateComicImages failed: ${e.code} ${e.message}\n$st');
      rethrow;
    }
  }
}
