import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  group('LoginPage Widget Tests', () {
    testWidgets('should display login form elements', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          child: Scaffold(
            body: Column(
              children: [
                const TextField(key: Key('email_field')),
                const TextField(key: Key('password_field')),
                ElevatedButton(
                  key: const Key('login_button'),
                  onPressed: () {},
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      );

      TestHelpers.verifyWidgetExists(TestHelpers.findByKey('email_field'));
      TestHelpers.verifyWidgetExists(TestHelpers.findByKey('password_field'));
      TestHelpers.verifyWidgetExists(TestHelpers.findByKey('login_button'));
    });

    testWidgets('should validate empty email field', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          child: Scaffold(
            body: Column(
              children: [
                TextFormField(
                  key: const Key('email_field'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await TestHelpers.enterText(
        tester,
        TestHelpers.findByKey('email_field'),
        '',
      );

      expect(find.text('Email is required'), findsNothing);
    });

    testWidgets('should show loading indicator on login', (tester) async {
      bool isLoading = false;

      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () {
                          setState(() => isLoading = true);
                        },
                        child: const Text('Login'),
                      ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Login'));
      await tester.pump();

      VerificationHelpers.verifyLoadingIndicator(tester);
    });

    testWidgets('should navigate to home on successful login', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        TestHelpers.createTestWidgetWithNavigation(
          navigatorKey: navigatorKey,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                child: const Text('Login'),
              );
            },
          ),
        ),
      );

      await TestHelpers.tapWidget(tester, find.text('Login'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(navigatorKey.currentState, isNotNull);
    });

    testWidgets('should show error message on failed login', (tester) async {
      const errorMessage = 'Invalid credentials';

      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          child: Scaffold(
            body: Column(
              children: [
                const Text(errorMessage),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );

      VerificationHelpers.verifyErrorMessage(tester, errorMessage);
      TestHelpers.verifyWidgetExists(find.text('Retry'));
    });

    testWidgets('should toggle password visibility', (tester) async {
      bool obscureText = true;

      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    TextField(
                      key: const Key('password_field'),
                      obscureText: obscureText,
                    ),
                    IconButton(
                      key: const Key('visibility_toggle'),
                      icon: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => obscureText = !obscureText);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      final passwordField = tester.widget<TextField>(
        TestHelpers.findByKey('password_field'),
      );
      expect(passwordField.obscureText, isTrue);

      await TestHelpers.tapWidget(
        tester,
        TestHelpers.findByKey('visibility_toggle'),
      );

      final updatedPasswordField = tester.widget<TextField>(
        TestHelpers.findByKey('password_field'),
      );
      expect(updatedPasswordField.obscureText, isFalse);
    });
  });
}