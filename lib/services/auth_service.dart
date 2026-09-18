import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:hsdaily_toon/features/auth/model/auth_validators.dart';
import 'package:hsdaily_toon/features/auth/model/member_profile.dart';
import 'package:hsdaily_toon/services/user_repository.dart';

/// Central auth + membership session.
class AuthService extends ChangeNotifier {
  AuthService({
    FirebaseAuth? auth,
    UserRepository? users,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _users = users ?? UserRepository(),
        _google = googleSignIn ?? GoogleSignIn.instance {
    _sub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  final FirebaseAuth _auth;
  final UserRepository _users;
  final GoogleSignIn _google;

  StreamSubscription<User?>? _sub;
  MemberProfile? _profile;
  bool _booting = true;
  bool _googleReady = false;

  MemberProfile? get profile => _profile;
  User? get firebaseUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null && _profile != null && !(_profile!.isWithdrawn);
  bool get needsNickname =>
      isSignedIn && _profile != null && !_profile!.nicknameSet;
  bool get isBooting => _booting;

  Future<void> _ensureGoogle() async {
    if (_googleReady) return;
    try {
      await _google.initialize();
      _googleReady = true;
    } catch (e) {
      debugPrint('GoogleSignIn initialize: $e');
    }
  }

  Future<void> _onAuthChanged(User? user) async {
    if (user == null) {
      _profile = null;
      _booting = false;
      notifyListeners();
      return;
    }
    try {
      var profile = await _users.getProfile(user.uid);
      if (profile == null || profile.isWithdrawn) {
        // Orphan auth without profile — sign out.
        await _auth.signOut();
        _profile = null;
      } else {
        _profile = profile;
        await _users.touchLogin(user.uid);
      }
    } catch (e, st) {
      debugPrint('auth profile load failed: $e\n$st');
      _profile = null;
    }
    _booting = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _profile = await _users.getProfile(uid);
    notifyListeners();
  }

  Future<MemberProfile> signUpEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final user = cred.user!;
    final profile = await _users.createMember(
      authUid: user.uid,
      email: email.trim().toLowerCase(),
      authProviders: const ['email'],
    );
    _profile = profile;
    notifyListeners();
    return profile;
  }

  Future<MemberProfile> signUpPhone({
    required String countryCode,
    required String nationalNumber,
    required String password,
  }) async {
    final email = AuthValidators.phoneAuthEmail(
      countryCode: countryCode,
      nationalNumber: nationalNumber,
    );
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    final profile = await _users.createMember(
      authUid: user.uid,
      countryCode: countryCode,
      nationalNumber: nationalNumber,
      authProviders: const ['phone'],
    );
    _profile = profile;
    notifyListeners();
    return profile;
  }

  Future<MemberProfile> signInEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final profile = await _users.getProfile(cred.user!.uid);
    if (profile == null || profile.isWithdrawn) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: '없는 이메일 ID입니다',
      );
    }
    await _users.touchLogin(cred.user!.uid);
    _profile = profile;
    notifyListeners();
    return profile;
  }

  Future<MemberProfile> signInPhone({
    required String countryCode,
    required String nationalNumber,
    required String password,
  }) async {
    final email = AuthValidators.phoneAuthEmail(
      countryCode: countryCode,
      nationalNumber: nationalNumber,
    );
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final profile = await _users.getProfile(cred.user!.uid);
    if (profile == null || profile.isWithdrawn) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: '없는 휴대폰 전화번호 ID입니다',
      );
    }
    await _users.touchLogin(cred.user!.uid);
    _profile = profile;
    notifyListeners();
    return profile;
  }

  Future<MemberProfile> signInWithGoogle() async {
    await _ensureGoogle();
    final account = await _google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google idToken missing');
    }
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final cred = await _auth.signInWithCredential(credential);
    final user = cred.user!;
    var profile = await _users.getProfile(user.uid);
    if (profile == null) {
      profile = await _users.createMember(
        authUid: user.uid,
        googleEmail: user.email,
        email: user.email,
        authProviders: const ['google'],
        photoUrl: user.photoURL,
      );
    } else if (profile.isWithdrawn) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'user-disabled',
        message: '탈퇴한 계정입니다',
      );
    } else {
      await _users.touchLogin(user.uid);
      profile = (await _users.getProfile(user.uid))!;
    }
    _profile = profile;
    notifyListeners();
    return profile;
  }

  Future<void> saveNickname(String nickname) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _users.saveNickname(uid, nickname);
    await refreshProfile();
  }

  Future<void> updateNickname(String nickname) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _users.updateNickname(uid, nickname);
    await refreshProfile();
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw StateError('no-email-user');
    }
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  Future<void> updatePasswordDirect(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('not-signed-in');
    await user.updatePassword(newPassword);
  }

  Future<void> syncSessionOnly() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _users.syncSession(uid);
  }

  Future<void> syncAndSignOut() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _users.syncSession(uid);
      } catch (_) {}
    }
    try {
      await _google.signOut();
    } catch (_) {}
    await _auth.signOut();
    _profile = null;
    notifyListeners();
  }

  Future<bool> emailRegistered(String email) => _users.emailExists(email);

  Future<bool> phoneRegistered(String country, String national) =>
      _users.phoneExists(country, national);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// App-wide singleton set from [main].
AuthService? authService;
