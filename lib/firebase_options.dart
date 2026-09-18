// File generated for FlutterFire — web options from Firebase console.
// Android / iOS / desktop apps are not registered yet; add via
// `flutterfire configure` when those platforms are ready.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android — '
          'run `flutterfire configure` after registering an Android app.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios — '
          'run `flutterfire configure` after registering an iOS app.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos — '
          'run `flutterfire configure` after registering a macOS app.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows — '
          'run `flutterfire configure` after registering a Windows app.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux — '
          'not supported yet.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAFSlyt1IHdUj6lQpA5dspE2AyBbYHb9-U',
    appId: '1:588522246671:web:7df79748daa51f9d5d497a',
    messagingSenderId: '588522246671',
    projectId: 'hsdaily-toon',
    authDomain: 'hsdaily-toon.firebaseapp.com',
    storageBucket: 'hsdaily-toon.firebasestorage.app',
    measurementId: 'G-TBTHV4RC0C',
  );
}
