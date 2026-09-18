import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:hsdaily_toon/features/auth/model/auth_validators.dart';
import 'package:hsdaily_toon/features/auth/model/member_profile.dart';
import 'package:hsdaily_toon/services/firestore_paths.dart';

/// Firestore reads/writes for membership profiles and lookup indexes.
class UserRepository {
  UserRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection(FirestorePaths.users).doc(uid);

  DocumentReference<Map<String, dynamic>> _lookupRef(String key) =>
      _db.collection('auth_lookup').doc(key);

  static String emailLookupKey(String email) =>
      'email_${email.trim().toLowerCase()}';

  static String phoneLookupKey(String countryCode, String national) =>
      'phone_${AuthValidators.normalizeCountryCode(countryCode)}_'
      '${AuthValidators.digitsOnly(national)}';

  Future<MemberProfile?> getProfile(String authUid) async {
    final snap = await _userRef(authUid).get();
    if (!snap.exists || snap.data() == null) return null;
    return MemberProfile.fromDoc(authUid, snap.data()!);
  }

  Future<bool> emailExists(String email) async {
    final snap = await _lookupRef(emailLookupKey(email)).get();
    return snap.exists;
  }

  Future<bool> phoneExists(String countryCode, String national) async {
    final snap =
        await _lookupRef(phoneLookupKey(countryCode, national)).get();
    return snap.exists;
  }

  Future<String> _uniquePublicId() async {
    for (var i = 0; i < 8; i++) {
      final id = AuthValidators.makePublicId();
      final snap =
          await _db.collection(FirestorePaths.publicIds).doc(id).get();
      if (!snap.exists) return id;
    }
    throw StateError('Could not allocate publicId');
  }

  /// Creates user + public_ids + auth_lookup after first successful Auth signup.
  Future<MemberProfile> createMember({
    required String authUid,
    String? email,
    String? googleEmail,
    String? countryCode,
    String? nationalNumber,
    required List<String> authProviders,
    String? photoUrl,
  }) async {
    final publicId = await _uniquePublicId();
    final now = FieldValue.serverTimestamp();
    final phone = (countryCode != null && nationalNumber != null)
        ? {
            'countryCode': AuthValidators.normalizeCountryCode(countryCode),
            'nationalNumber': AuthValidators.digitsOnly(nationalNumber),
          }
        : null;
    final phoneDisplay = phone == null
        ? null
        : '${phone['countryCode']} ${phone['nationalNumber']}';

    final batch = _db.batch();
    batch.set(_userRef(authUid), {
      'publicId': publicId,
      'nickname': null,
      'nicknameSet': false,
      'email': email?.trim().toLowerCase(),
      'googleEmail': googleEmail?.trim().toLowerCase(),
      'phone': phone,
      'phoneDisplay': phoneDisplay,
      'authProviders': authProviders,
      'photoUrl': photoUrl,
      'status': 'active',
      'isWithdrawn': false,
      'withdrawnAt': null,
      'createdAt': now,
      'updatedAt': now,
      'lastLoginAt': now,
      'lastComicDate': null,
      'comicCountTotal': 0,
    });
    batch.set(_db.collection(FirestorePaths.publicIds).doc(publicId), {
      'publicId': publicId,
      'authUid': authUid,
      'status': 'active',
      'createdAt': now,
      'releasedAt': null,
    });

    if (email != null && email.trim().isNotEmpty) {
      batch.set(_lookupRef(emailLookupKey(email)), {
        'authUid': authUid,
        'type': 'email',
        'value': email.trim().toLowerCase(),
      });
    }
    if (googleEmail != null && googleEmail.trim().isNotEmpty) {
      batch.set(_lookupRef(emailLookupKey(googleEmail)), {
        'authUid': authUid,
        'type': 'googleEmail',
        'value': googleEmail.trim().toLowerCase(),
      });
    }
    if (phone != null) {
      batch.set(
        _lookupRef(
          phoneLookupKey(
            phone['countryCode'] as String,
            phone['nationalNumber'] as String,
          ),
        ),
        {
          'authUid': authUid,
          'type': 'phone',
          'countryCode': phone['countryCode'],
          'nationalNumber': phone['nationalNumber'],
        },
      );
    }

    await batch.commit();
    debugPrint('Created member $authUid publicId=$publicId');
    return (await getProfile(authUid))!;
  }

  Future<void> touchLogin(String authUid) async {
    await _userRef(authUid).set({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveNickname(String authUid, String nickname) async {
    final trimmed = nickname.trim();
    final profile = await getProfile(authUid);
    final value =
        trimmed.isEmpty ? (profile?.publicId ?? authUid) : trimmed;
    await _userRef(authUid).update({
      'nickname': value,
      'nicknameSet': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNickname(String authUid, String nickname) async {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) return;
    await _userRef(authUid).update({
      'nickname': trimmed,
      'nicknameSet': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> syncSession(String authUid) async {
    await _userRef(authUid).set({
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
