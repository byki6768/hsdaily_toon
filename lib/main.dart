import 'package:flutter/material.dart';

import 'package:hsdaily_toon/router/app_router.dart';
import 'package:hsdaily_toon/services/firebase_service.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Never block the UI if Firebase is slow or unavailable (common on local web).
  try {
    await FirebaseService.initialize().timeout(const Duration(seconds: 5));
  } catch (error, stack) {
    debugPrint('Firebase init skipped: $error\n$stack');
  }

  runApp(const HsDailyToonApp());
}

class HsDailyToonApp extends StatelessWidget {
  const HsDailyToonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4컷 일기',
      theme: AppTheme.light,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
