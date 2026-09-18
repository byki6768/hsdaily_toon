import 'package:flutter/material.dart';

import 'package:hsdaily_toon/theme/app_theme.dart';

/// Shared warm page background used across diary flow screens.
class DiaryFlowBackground extends StatelessWidget {
  const DiaryFlowBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.blush,
            Color(0xFFFFE8DF),
            AppColors.blushDeep,
          ],
        ),
      ),
      child: child,
    );
  }
}
