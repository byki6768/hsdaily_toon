import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hsdaily_toon/features/gallery/model/gallery_item.dart';
import 'package:hsdaily_toon/features/gallery/ui/comic_strip_thumbnail.dart';
import 'package:hsdaily_toon/theme/app_theme.dart';

/// Gallery page header.
class GalleryHeader extends StatelessWidget {
  const GalleryHeader({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 769;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '내 만화 갤러리',
          style: GoogleFonts.gaegu(
            fontSize: wide ? 40 : 34,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count == 0
              ? '아직 모인 일기가 없어요. 오늘의 마음을 남겨 보세요.'
              : '지금까지 남긴 4컷 일기 $count편',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.inkSoft,
                fontSize: 14,
              ),
        ),
      ],
    );
  }
}

String formatGalleryDate(DateTime date) {
  final y = date.year.toString();
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y.$m.$d';
}

/// One gallery list row — thumbnail + title + date.
class GalleryListTile extends StatelessWidget {
  const GalleryListTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final GalleryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.panel.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            child: Row(
              children: [
                ComicStripThumbnail(strip: item.strip, size: 76),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (item.diarySnippet.isNotEmpty)
                        Text(
                          item.diarySnippet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: AppColors.inkSoft,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            formatGalleryDate(item.createdAt),
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.inkSoft,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.petal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty gallery placeholder.
class GalleryEmptyState extends StatelessWidget {
  const GalleryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 48,
              color: AppColors.rose.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 비어 있어요',
              style: GoogleFonts.gaegu(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '일기를 쓰고 만화를 만들면\n이곳에 차곡차곡 쌓입니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
