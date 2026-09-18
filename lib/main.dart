import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/services/auth_service.dart';
import 'package:hsdaily_toon/services/firebase_service.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await FirebaseService.initialize().timeout(const Duration(seconds: 5));
  } catch (error, stack) {
    debugPrint('Firebase init skipped: $error\n$stack');
  }

  authService = AuthService();
  runApp(const HsDailyToonApp());
}

class HsDailyToonApp extends StatefulWidget {
  const HsDailyToonApp({super.key});

  @override
  State<HsDailyToonApp> createState() => _HsDailyToonAppState();
}

class _HsDailyToonAppState extends State<HsDailyToonApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final auth = authService;
    if (auth == null || !auth.isSignedIn) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // ignore: discarded_futures
      auth.syncSessionOnly();
    }

    if (state == AppLifecycleState.detached) {
      // ignore: discarded_futures
      auth.syncAndSignOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4컷 일기',
      theme: AppTheme.light,
      initialRoute: AppRouter.landing,
      onGenerateRoute: AppRouter.onGenerateRoute,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (kIsWeb) {
          return _WebLeaveGuard(
            onLeave: () async {
              await authService?.syncAndSignOut();
            },
            child: child ?? const SizedBox.shrink(),
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// On web, flush session + logout when the tab is hidden/closed.
class _WebLeaveGuard extends StatefulWidget {
  const _WebLeaveGuard({required this.child, required this.onLeave});

  final Widget child;
  final Future<void> Function() onLeave;

  @override
  State<_WebLeaveGuard> createState() => _WebLeaveGuardState();
}

class _WebLeaveGuardState extends State<_WebLeaveGuard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // ignore: discarded_futures
    widget.onLeave();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Tab hide should not force logout; only full leave/detach.
    if (state == AppLifecycleState.detached) {
      // ignore: discarded_futures
      widget.onLeave();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
