// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:my_app/app/app.dart';
import 'package:my_app/shared/services/auth_service.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    // Build our app wrapped with Provider and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthService(),
        child: const MyApp(),
      ),
    );

    // Wait for the widget tree to settle.
    await tester.pumpAndSettle();

    // Verify that the app renders and shows the home page content.
    expect(find.text('Home'), findsOneWidget);
  });
}
