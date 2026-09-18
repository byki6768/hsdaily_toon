/// Domain models mirroring Firestore collections (hsdaily-toon).
/// See docs/DATA_MODEL.md for full schema.
library;

/// Permanent 16-char member id: letter + [A-Za-z0-9]{15}
const String kPublicIdPattern = r'^[A-Za-z][A-Za-z0-9]{15}$';

abstract final class FirestorePaths {
  static const users = 'users';
  static const publicIds = 'public_ids';
  static const diaries = 'diaries';
  static const scenarios = 'scenarios';
  static const comics = 'comics';
  static const usageDaily = 'usage_daily';
  static const appConfig = 'app_config';

  static String user(String authUid) => '$users/$authUid';
  static String publicId(String id) => '$publicIds/$id';
  static String diary(String id) => '$diaries/$id';
  static String scenario(String id) => '$scenarios/$id';
  static String comic(String id) => '$comics/$id';
  static String usageDailyDoc(String publicId, String yyyymmdd) =>
      '$usageDaily/${publicId}_$yyyymmdd';
  static const appConfigLimits = '$appConfig/limits';
}

abstract final class StoragePaths {
  /// comics/{publicId}/{comicId}/panel_{1-4}.webp
  static String panel({
    required String publicId,
    required String comicId,
    required int panelIndex,
  }) {
    assert(panelIndex >= 1 && panelIndex <= 4);
    return 'comics/$publicId/$comicId/panel_$panelIndex.webp';
  }

  static String thumb({
    required String publicId,
    required String comicId,
  }) =>
      'comics/$publicId/$comicId/thumb.webp';
}
