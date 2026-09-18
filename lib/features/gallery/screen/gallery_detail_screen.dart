import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/diary/ui/comic_strip_frame.dart';
import 'package:hsdaily_toon/features/diary/ui/diary_flow_background.dart';
import 'package:hsdaily_toon/features/gallery/model/gallery_item.dart';
import 'package:hsdaily_toon/features/gallery/ui/gallery_widgets.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// Detail view — large 4-cut comic for a gallery item.
class GalleryDetailScreen extends StatelessWidget {
  const GalleryDetailScreen({super.key, required this.item});

  final GalleryItem item;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 769;
    final horizontal = wide ? 48.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.blush,
      body: DiaryFlowBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8, 4, horizontal, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: AppColors.ink,
                      tooltip: '뒤로',
                    ),
                    Expanded(
                      child: Text(
                        '만화 상세',
                        style: GoogleFonts.gaegu(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    8,
                    horizontal,
                    wide ? 32 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.gaegu(
                          fontSize: wide ? 36 : 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: AppColors.inkSoft,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formatGalleryDate(item.createdAt),
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.inkSoft,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (item.diarySnippet.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          item.diarySnippet,
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.5,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FourCutComicFrame(
                        strip: item.strip,
                        maxWidth: wide ? 560 : 440,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
