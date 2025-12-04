import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rv_salon_manager/features/auth/screens/login_screen.dart';
import 'package:rv_salon_manager/features/auth/providers/auth_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// We can mock the AuthNotifier if needed, or just test the UI with the real provider (mocking the service)
// For widget tests, it's often easier to override the provider with a mock or a fake.

void main() {
  testWidgets('LoginScreen UI renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify title
    expect(find.text('RV Salon Manager'), findsOneWidget);
    expect(find.text('Welcome back! Please login to continue.'), findsOneWidget);

    // Verify fields
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify button
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('LoginScreen shows validation errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Tap login without entering data
    await tester.tap(find.text('LOGIN'));
    await tester.pump();

    // Verify validation errors
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });
}
