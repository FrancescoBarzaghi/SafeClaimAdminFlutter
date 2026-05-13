import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/app/theme.dart';
import 'package:flutter_application_1/pages/login.dart';

void main() {
  testWidgets('Login uses the SafeClaim themed shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: lightTheme(), home: const LoginPage()),
    );

    expect(find.text('SafeClaim Admin'), findsOneWidget);
    expect(find.text('ACCEDI ORA'), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, SafeClaimColors.background);
  });
}
