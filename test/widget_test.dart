import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petpoint_app/main.dart';

void main() {
  testWidgets('WelcomePage displays app info', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const PetPoint());

    // Wait for animations to settle
    await tester.pumpAndSettle();

    // Verify that WelcomePage shows the main title
    expect(find.text('Welcome to PetPoint'), findsOneWidget);

    // Verify that the "Get Started" button exists
    expect(find.text('Get Started'), findsOneWidget);

    // Tap the "Get Started" button and navigate to LoginPage
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify that LoginPage is displayed
    expect(find.text('Login'), findsOneWidget);
    expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
  });
}
