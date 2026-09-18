import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:hsdaily_toon/firebase_options.dart';

/// Firebase bootstrap and shared access for the app.
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static FirebaseAnalytics? _analytics;

  /// Analytics instance (web). Null until [initialize] succeeds.
  static FirebaseAnalytics? get analytics => _analytics;

  /// Call once from [main] after [WidgetsFlutterBinding.ensureInitialized].
  ///
  /// Pass [options] in tests to avoid platform-specific [DefaultFirebaseOptions].
  static Future<void> initialize({FirebaseOptions? options}) async {
    if (_initialized) return;

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: options ?? DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Matches the web console snippet: getAnalytics(app).
    if (kIsWeb) {
      _analytics = FirebaseAnalytics.instance;
    }

    _initialized = true;
  }
}
