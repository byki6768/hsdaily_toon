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
}

/// Result of [ScenarioService.generateFromDiary].
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

/// Calls Cloud Function `generateComicScenario`.
/// Gemini API key stays on the server (Firebase Secret / env).
class ScenarioService {
  ScenarioService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'asia-northeast3');

  final FirebaseFunctions _functions;

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
}
