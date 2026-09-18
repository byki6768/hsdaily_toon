import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Cross-platform speech → text.
/// Web uses the browser Web Speech API (via speech_to_text).
/// Android / iOS use native speech recognition.
class DiarySpeechService {
  DiarySpeechService({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  bool _ready = false;
  String _localeId = 'ko_KR';
  void Function(String status)? _onStatus;

  bool get isAvailable => _ready && _speech.isAvailable;
  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_ready) return _speech.isAvailable;

    if (!kIsWeb) {
      final mic = await Permission.microphone.request();
      if (!mic.isGranted) {
        debugPrint('Microphone permission denied');
        return false;
      }
    }

    _ready = await _speech.initialize(
      onError: (e) => debugPrint('Speech error: ${e.errorMsg}'),
      onStatus: (s) {
        debugPrint('Speech status: $s');
        _onStatus?.call(s);
      },
    );

    if (_ready) {
      final locales = await _speech.locales();
      final ko = locales.where(
        (l) =>
            l.localeId.toLowerCase().startsWith('ko') ||
            l.localeId.toLowerCase().contains('korean'),
      );
      if (ko.isNotEmpty) {
        _localeId = ko.first.localeId;
      }
    }
    return _ready;
  }

  Future<void> start({
    required void Function(String text, bool isFinal) onResult,
    void Function(String status)? onStatus,
  }) async {
    _onStatus = onStatus;
    final ok = await initialize();
    if (!ok) {
      throw StateError('speech_unavailable');
    }

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenOptions: SpeechListenOptions(
        localeId: _localeId,
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
        autoPunctuation: true,
      ),
    );
  }

  Future<void> stop() => _speech.stop();

  Future<void> cancel() => _speech.cancel();
}
