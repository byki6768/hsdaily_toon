import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import 'package:hsdaily_toon/features/auth/model/member_profile.dart';

/// Calls Cloud Function [provisionMember] after Firebase Auth succeeds.
class MemberProvisionService {
  MemberProvisionService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'asia-northeast3');

  final FirebaseFunctions _functions;

  Future<MemberProfile> provision({
    String? email,
    String? googleEmail,
    String? countryCode,
    String? nationalNumber,
    required List<String> authProviders,
    String? photoUrl,
  }) async {
    final callable = _functions.httpsCallable(
      'provisionMember',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
    );

    try {
      final result = await callable.call(<String, dynamic>{
        if (email != null) 'email': email,
        if (googleEmail != null) 'googleEmail': googleEmail,
        if (countryCode != null) 'countryCode': countryCode,
        if (nationalNumber != null) 'nationalNumber': nationalNumber,
        'authProviders': authProviders,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      final uid = data['authUid'] as String? ?? '';
      return MemberProfile.fromDoc(uid, data);
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint('provisionMember failed: ${e.code} ${e.message}\n$st');
      rethrow;
    }
  }
}
