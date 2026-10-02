import 'package:flutter_test/flutter_test.dart';
import 'package:indovoca/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const IndovocaApp());
    expect(find.byType(IndovocaApp), findsOneWidget);
  });
}
