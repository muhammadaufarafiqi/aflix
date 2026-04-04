import 'package:flutter_test/flutter_test.dart';
import 'package:aflix/main.dart';

void main() {
  testWidgets('Aflix app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AflixApp());
    expect(find.byType(AflixApp), findsOneWidget);
  });
}