import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Extracts diary text from an image or PDF via Cloud Function (Gemini Vision).
/// API key stays on the server (Firebase Secret / local .env.local).
class VisionOcrService {
  VisionOcrService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'asia-northeast3');

  final FirebaseFunctions _functions;

  Future<String> extractText({
    required String mimeType,
    required String dataBase64,
  }) async {
    final callable = _functions.httpsCallable(
      'extractDiaryText',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 120)),
    );

    try {
      final result = await callable.call(<String, dynamic>{
        'mimeType': mimeType,
        'dataBase64': dataBase64,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      return (data['text'] as String?)?.trim() ?? '';
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint('extractDiaryText failed: ${e.code} ${e.message}\n$st');
      rethrow;
    }
  }
}
