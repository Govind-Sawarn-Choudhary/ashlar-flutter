import 'package:ashlar_lawyer_hub/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Splash screen renders logo', (WidgetTester tester) async {
    await tester.pumpWidget(const AshlarLawyerHubApp());

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Role select shows both choices', (WidgetTester tester) async {
    await tester.pumpWidget(const AshlarLawyerHubApp());

    // Let splash timer elapse.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    expect(find.text('Login as a User/Client'), findsOneWidget);
    expect(find.text('Login as a lawyer'), findsOneWidget);
  });
}
