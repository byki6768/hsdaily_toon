import 'package:flutter/material.dart';

import 'package:hsdaily_toon/features/diary/model/comic_models.dart';
import 'package:hsdaily_toon/features/gallery/model/gallery_item.dart';

/// Dummy gallery entries — replace with Firestore later.
abstract final class DummyGalleryData {
  static List<GalleryItem> items() {
    final now = DateTime.now();

    return [
      GalleryItem(
        id: 'dummy-1',
        title: '비 오는 창가의 하루',
        createdAt: now.subtract(const Duration(hours: 5)),
        diarySnippet: '오늘은 비가 와서 창밖을 오래 바라봤어.',
        strip: _strip(
          title: '비 오는 창가의 하루',
          tints: const [
            Color(0xFFFFD4C4),
            Color(0xFFE8D4F0),
            Color(0xFFD4E4F0),
            Color(0xFFFFE8DE),
          ],
          labels: const ['창가', '빗소리', '커피', '밤'],
          captions: const [
            '창문에 빗방울이 맺힌다',
            '조용한 빗소리에 마음이 느려진다',
            '따뜻한 커피 향이 퍼진다',
            '오늘은 이만 덮어 둔다',
          ],
        ),
      ),
      GalleryItem(
        id: 'dummy-2',
        title: '작은 산책을 한 날',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        diarySnippet: '잠깐 밖에 나가 바람 맞으며 걸었어.',
        strip: _strip(
          title: '작은 산책을 한 날',
          tints: const [
            Color(0xFFFFE0D2),
            Color(0xFFD8EFD4),
            Color(0xFFFFF0C8),
            Color(0xFFF3C8C8),
          ],
          labels: const ['문밖', '골목', '하늘', '귀가'],
          captions: const [
            '신발을 신고 문을 나선다',
            '익숙한 골목이 새삼 반갑다',
            '하늘이 조금 맑아진다',
            '집에 돌아와 숨을 고른다',
          ],
        ),
      ),
      GalleryItem(
        id: 'dummy-3',
        title: '친구와 나눈 저녁',
        createdAt: now.subtract(const Duration(days: 3)),
        diarySnippet: '오랜만에 친구를 만나 이야기를 나눴다.',
        strip: _strip(
          title: '친구와 나눈 저녁',
          tints: const [
            Color(0xFFF5D0D8),
            Color(0xFFFFE6DC),
            Color(0xFFE4D8F0),
            Color(0xFFFFEFE8),
          ],
          labels: const ['약속', '식사', '이야기', '작별'],
          captions: const [
            '약속 장소에 조금 일찍 도착한다',
            '따뜻한 식사를 나눈다',
            '시간이 어떻게 갔는지 모른다',
            '다음에 또 만나자고 손을 흔든다',
          ],
        ),
      ),
      GalleryItem(
        id: 'dummy-4',
        title: '조용한 일요일 아침',
        createdAt: now.subtract(const Duration(days: 6)),
        diarySnippet: '아무 일정도 없는 아침이 참 좋았다.',
        strip: _strip(
          title: '조용한 일요일 아침',
          tints: const [
            Color(0xFFFFF2E0),
            Color(0xFFFFD9CE),
            Color(0xFFE8E0D4),
            Color(0xFFFFE8DE),
          ],
          labels: const ['기상', '햇살', '독서', '낮잠'],
          captions: const [
            '알람 없이 천천히 눈을 뜬다',
            '이불 위로 햇살이 내려앉는다',
            '책 한 페이지를 넘긴다',
            '잠깐의 낮잠이 달콤하다',
          ],
        ),
      ),
      GalleryItem(
        id: 'dummy-5',
        title: '조금 지친 금요일',
        createdAt: now.subtract(const Duration(days: 28)),
        diarySnippet: '바쁜 한 주를 마치고 소파에 가라앉았다.',
        strip: _strip(
          title: '조금 지친 금요일',
          tints: const [
            Color(0xFFE0D4E8),
            Color(0xFFD4DCE8),
            Color(0xFFFFD4C4),
            Color(0xFFF0E0D8),
          ],
          labels: const ['퇴근', '귀가', '저녁', '쉼'],
          captions: const [
            '하루의 끝을 향해 발걸음을 옮긴다',
            '집 문이 반겨 준다',
            '간단한 저녁을 차린다',
            '소파에 누워 아무 생각도 하지 않는다',
          ],
        ),
      ),
    ];
  }

  static ComicStrip _strip({
    required String title,
    required List<Color> tints,
    required List<String> labels,
    required List<String> captions,
  }) {
    return ComicStrip(
      title: title,
      panels: [
        for (var i = 0; i < 4; i++)
          ComicPanel(
            index: i + 1,
            caption: captions[i],
            image: PlaceholderComicImage(
              tint: tints[i],
              label: labels[i],
            ),
          ),
      ],
    );
  }
}
