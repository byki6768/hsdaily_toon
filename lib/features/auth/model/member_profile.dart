import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore member profile for `users/{authUid}`.
class MemberProfile {
  const MemberProfile({
    required this.authUid,
    required this.publicId,
    this.nickname,
    this.nicknameSet = false,
    this.email,
    this.googleEmail,
    this.countryCode,
    this.nationalNumber,
    this.phoneDisplay,
    this.authProviders = const [],
    this.photoUrl,
    this.status = 'active',
    this.isWithdrawn = false,
    this.withdrawnAt,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  final String authUid;
  final String publicId;
  final String? nickname;
  final bool nicknameSet;
  final String? email;
  final String? googleEmail;
  final String? countryCode;
  final String? nationalNumber;
  final String? phoneDisplay;
  final List<String> authProviders;
  final String? photoUrl;
  final String status;
  final bool isWithdrawn;
  final DateTime? withdrawnAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  String get displayName {
    final n = nickname?.trim();
    if (n != null && n.isNotEmpty) return n;
    return publicId;
  }

  factory MemberProfile.fromDoc(
    String authUid,
    Map<String, dynamic> data,
  ) {
    final phone = data['phone'];
    Map<String, dynamic>? phoneMap;
    if (phone is Map) {
      phoneMap = Map<String, dynamic>.from(phone);
    }

    DateTime? ts(dynamic v) {
      if (v is Timestamp) return v.toDate();
      return null;
    }

    return MemberProfile(
      authUid: authUid,
      publicId: data['publicId'] as String? ?? '',
      nickname: data['nickname'] as String?,
      nicknameSet: data['nicknameSet'] as bool? ?? false,
      email: data['email'] as String?,
      googleEmail: data['googleEmail'] as String?,
      countryCode: phoneMap?['countryCode'] as String?,
      nationalNumber: phoneMap?['nationalNumber'] as String?,
      phoneDisplay: data['phoneDisplay'] as String?,
      authProviders: (data['authProviders'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      photoUrl: data['photoUrl'] as String?,
      status: data['status'] as String? ?? 'active',
      isWithdrawn: data['isWithdrawn'] as bool? ?? false,
      withdrawnAt: ts(data['withdrawnAt']),
      createdAt: ts(data['createdAt']),
      updatedAt: ts(data['updatedAt']),
      lastLoginAt: ts(data['lastLoginAt']),
    );
  }
}
