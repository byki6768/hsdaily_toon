import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Picked file payload for Vision OCR.
class DiaryPickedFile {
  const DiaryPickedFile({
    required this.bytes,
    required this.mimeType,
    required this.name,
  });

  final Uint8List bytes;
  final String mimeType;
  final String name;

  String get dataBase64 => base64Encode(bytes);
}

/// Opens a file picker for images / PDF (web + mobile).
class DiaryFilePicker {
  static const _extensions = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'pdf'];

  static Future<DiaryPickedFile?> pickImageOrPdf() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _extensions,
    );
    if (files.isEmpty) return null;

    final file = files.first;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw StateError('empty_file');
    }
    if (bytes.lengthInBytes > 5 * 1024 * 1024) {
      throw StateError('file_too_large');
    }

    final name = file.name;
    final mime = _mimeFromName(name, file.extension);
    return DiaryPickedFile(bytes: bytes, mimeType: mime, name: name);
  }

  static String _mimeFromName(String name, String? extension) {
    final ext = (extension ?? name.split('.').last).toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'pdf' => 'application/pdf',
      _ => 'application/octet-stream',
    };
  }
}
