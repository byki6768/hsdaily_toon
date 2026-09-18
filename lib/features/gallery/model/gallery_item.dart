import 'package:hsdaily_toon/features/diary/model/comic_models.dart';

/// One saved Daily-toon entry in the gallery.
/// Swap [strip] images later without changing list/detail UI.
class GalleryItem {
  const GalleryItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.strip,
    this.diarySnippet = '',
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final ComicStrip strip;
  final String diarySnippet;

  /// Representative thumbnail source (panel 1 by default).
  ComicImageSource get thumbnailImage => strip.panel1.image;
}

/// Gallery screen state (dummy list for now).
class GalleryState {
  const GalleryState({this.items = const []});

  final List<GalleryItem> items;

  bool get isEmpty => items.isEmpty;
}
