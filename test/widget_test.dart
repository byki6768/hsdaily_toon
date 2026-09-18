import 'package:flutter_test/flutter_test.dart';

import 'package:hsdaily_toon/main.dart';

void main() {
  testWidgets('app boots with skeleton home', (WidgetTester tester) async {
    await tester.pumpWidget(const HsDailyToonApp());
    expect(find.byType(HsDailyToonApp), findsOneWidget);
  });
}
