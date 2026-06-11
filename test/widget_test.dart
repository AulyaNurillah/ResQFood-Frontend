import 'package:flutter_test/flutter_test.dart';
import 'package:resqfood_app/main.dart';

void main() {
  testWidgets(
    'App loads successfully',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ResQFoodApp(),
      );

      expect(
        find.text('ResQFood'),
        findsOneWidget,
      );
    },
  );
}