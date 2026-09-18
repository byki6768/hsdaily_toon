import 'package:flutter/material.dart';

import 'package:hsdaily_toon/features/auth/screen/login_choice_screen.dart';

/// Legacy `/auth` entry — redirects to the login choice screen.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) => const LoginChoiceScreen();
}
