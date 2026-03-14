import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift_diary/app.dart';

void main() {
  testWidgets('App should build', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DriftDiaryApp()));
    expect(find.byType(DriftDiaryApp), findsOneWidget);
  });
}
