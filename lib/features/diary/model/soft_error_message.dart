import 'package:cloud_functions/cloud_functions.dart';

/// Soft, user-facing copy for comic-generation failures (no codes / jargon).
String softComicErrorMessage(Object error) {
  if (error is FirebaseFunctionsException) {
    switch (error.code) {
      case 'invalid-argument':
        return '일기를 조금만 더 적어 볼까요?';
      case 'resource-exhausted':
        return '지금은 조금 붐비네요. 잠시 후에 다시 만들어 볼까요?';
      case 'deadline-exceeded':
        return '시간이 조금 오래 걸렸어요. 문장을 확인한 뒤 다시 시도해 볼까요?';
      case 'unavailable':
        return '연결이 잠시 불안정해요. 네트워크를 확인한 뒤 다시 시도해 볼까요?';
      default:
        final detail = (error.message ?? '').trim();
        if (detail.contains('이미지')) {
          return '그림을 그리다 잠깐 숨을 고르고 있어요. 문장을 살짝 다듬어 다시 시도해 볼까요?';
        }
        if (detail.contains('시나리오')) {
          return '이야기를 엮는 중에 잠깐 멈칫했어요. 다시 시도해 볼까요?';
        }
        if (detail.contains('글자')) {
          return '글자를 읽는 중에 잠깐 문제가 생겼어요. 다시 시도해 볼까요?';
        }
        return '만화를 만드는 중에 잠깐 문제가 생겼어요. 일기를 확인한 뒤 다시 시도해 볼까요?';
    }
  }

  return '연결이 잠시 불안정해요. 네트워크를 확인한 뒤 다시 시도해 볼까요?';
}

/// Soft copy for speech / file upload / OCR failures.
String softInputErrorMessage(Object error) {
  if (error is FirebaseFunctionsException) {
    final detail = (error.message ?? '').trim();
    if (detail.isNotEmpty &&
        !RegExp(r'^\d+$').hasMatch(detail) &&
        !detail.contains('INTERNAL')) {
      return detail;
    }
    switch (error.code) {
      case 'invalid-argument':
        return '올릴 수 있는 파일인지 확인해 볼까요?';
      case 'resource-exhausted':
        return '지금은 조금 붐비네요. 잠시 후에 다시 시도해 볼까요?';
      default:
        return '글자를 읽는 중에 잠깐 문제가 생겼어요. 다시 시도해 볼까요?';
    }
  }

  final msg = error.toString();
  if (msg.contains('speech_unavailable')) {
    return '마이크를 사용할 수 없어요. 권한과 브라우저 설정을 확인해 볼까요?';
  }
  if (msg.contains('file_too_large')) {
    return '파일이 조금 커요. 5MB 이하로 올려 볼까요?';
  }
  if (msg.contains('empty_file')) {
    return '파일이 비어 있어요. 다른 파일을 골라 볼까요?';
  }

  return '잠시 문제가 생겼어요. 다시 한번 시도해 볼까요?';
}
