import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/theme/app_theme.dart';

/// Mic + image/PDF upload actions under the diary editor.
class DiaryInputTools extends StatelessWidget {
  const DiaryInputTools({
    super.key,
    required this.isListening,
    required this.isOcrBusy,
    required this.onMicPressed,
    required this.onUploadPressed,
  });

  final bool isListening;
  final bool isOcrBusy;
  final VoidCallback onMicPressed;
  final VoidCallback onUploadPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ToolButton(
            onPressed: isOcrBusy ? null : onMicPressed,
            icon: isListening ? Icons.stop_circle_outlined : Icons.mic_none_rounded,
            label: isListening ? '인식 중… 탭하여 중지' : '음성으로 쓰기',
            filled: isListening,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ToolButton(
            onPressed: (isListening || isOcrBusy) ? null : onUploadPressed,
            icon: isOcrBusy
                ? Icons.hourglass_top_rounded
                : Icons.image_outlined,
            label: isOcrBusy ? '글자 읽는 중…' : '사진·PDF 올리기',
            filled: false,
          ),
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.filled,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    if (filled) {
      return SizedBox(
        height: 48,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansKr(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.rose,
            foregroundColor: Colors.white,
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.notoSansKr(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.roseDeep,
          side: const BorderSide(color: AppColors.rose, width: 1.3),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
