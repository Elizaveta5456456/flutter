import 'package:flutter_test/flutter_test.dart';

import 'package:lotus/main.dart';

void main() {
  testWidgets('App starts on search tab', (WidgetTester tester) async {
    await tester.pumpWidget(const LotusApp());
    await tester.pump();

    expect(find.text('категории'), findsOneWidget);
  });
}
