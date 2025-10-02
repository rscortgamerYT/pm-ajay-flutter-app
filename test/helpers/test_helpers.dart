import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Helper class for setting up tests
class TestHelpers {
  /// Initialize Hive for testing
  static Future<void> initializeHive() async {
    await Hive.initFlutter();
  }

  /// Close Hive after tests
  static Future<void> closeHive() async {
    await Hive.close();
  }

  /// Create a test widget with providers
  static Widget createTestWidget({
    required Widget child,
    List<Override>? overrides,
  }) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  /// Create a test widget with navigation
  static Widget createTestWidgetWithNavigation({
    required Widget child,
    List<Override>? overrides,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: child,
      ),
    );
  }

  /// Pump and settle with custom duration
  static Future<void> pumpAndSettle(
    WidgetTester tester, {
    Duration duration = const Duration(milliseconds: 100),
  }) async {
    await tester.pumpAndSettle(duration);
  }

  /// Find widget by key
  static Finder findByKey(String key) {
    return find.byKey(Key(key));
  }

  /// Find widget by text
  static Finder findByText(String text) {
    return find.text(text);
  }

  /// Find widget by type
  static Finder findByType<T>() {
    return find.byType(T);
  }

  /// Verify widget exists
  static void verifyWidgetExists(Finder finder) {
    expect(finder, findsOneWidget);
  }

  /// Verify widget does not exist
  static void verifyWidgetNotExists(Finder finder) {
    expect(finder, findsNothing);
  }

  /// Verify widget count
  static void verifyWidgetCount(Finder finder, int count) {
    expect(finder, findsNWidgets(count));
  }

  /// Tap on widget
  static Future<void> tapWidget(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Enter text in field
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Scroll until visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollable, {
    double delta = 100.0,
  }) async {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: scrollable,
    );
  }

  /// Create mock future
  static Future<T> mockFuture<T>(T value) async {
    return Future.value(value);
  }

  /// Create mock error future
  static Future<T> mockErrorFuture<T>(dynamic error) async {
    return Future.error(error);
  }

  /// Create mock stream
  static Stream<T> mockStream<T>(List<T> values) {
    return Stream.fromIterable(values);
  }

  /// Create mock error stream
  static Stream<T> mockErrorStream<T>(dynamic error) {
    return Stream.error(error);
  }

  /// Wait for async operations
  static Future<void> waitForAsync(WidgetTester tester) async {
    await tester.runAsync(() => Future.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  /// Verify text field value
  static void verifyTextFieldValue(
    WidgetTester tester,
    String key,
    String expectedValue,
  ) {
    final textField = tester.widget<TextField>(findByKey(key));
    expect(textField.controller?.text, expectedValue);
  }

  /// Verify button enabled
  static void verifyButtonEnabled(
    WidgetTester tester,
    String key,
  ) {
    final button = tester.widget<ElevatedButton>(findByKey(key));
    expect(button.enabled, isTrue);
  }

  /// Verify button disabled
  static void verifyButtonDisabled(
    WidgetTester tester,
    String key,
  ) {
    final button = tester.widget<ElevatedButton>(findByKey(key));
    expect(button.enabled, isFalse);
  }
}

/// Base class for mock repositories
class MockRepository {
  // Base mock repository class for testing
}

/// Helper for creating test data
class TestDataFactory {
  /// Create test user
  static Map<String, dynamic> createTestUser({
    String id = 'test_user_1',
    String name = 'Test User',
    String email = 'test@example.com',
    String role = 'admin',
  }) {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create test project
  static Map<String, dynamic> createTestProject({
    String id = 'test_project_1',
    String name = 'Test Project',
    String status = 'active',
    double progress = 0.5,
  }) {
    return {
      'id': id,
      'name': name,
      'description': 'Test project description',
      'status': status,
      'progress': progress,
      'startDate': DateTime.now().toIso8601String(),
      'endDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'budget': 1000000.0,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create test agency
  static Map<String, dynamic> createTestAgency({
    String id = 'test_agency_1',
    String name = 'Test Agency',
    String type = 'government',
  }) {
    return {
      'id': id,
      'name': name,
      'type': type,
      'contactEmail': 'agency@example.com',
      'contactPhone': '+911234567890',
      'address': 'Test Address',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create test tender
  static Map<String, dynamic> createTestTender({
    String id = 'test_tender_1',
    String title = 'Test Tender',
    String status = 'open',
  }) {
    return {
      'id': id,
      'title': title,
      'description': 'Test tender description',
      'status': status,
      'publishDate': DateTime.now().toIso8601String(),
      'closingDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'estimatedValue': 500000.0,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create test document
  static Map<String, dynamic> createTestDocument({
    String id = 'test_document_1',
    String name = 'Test Document',
    String type = 'pdf',
  }) {
    return {
      'id': id,
      'name': name,
      'type': type,
      'size': 1024000,
      'url': 'https://example.com/document.pdf',
      'uploadedBy': 'test_user_1',
      'uploadedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create multiple test items
  static List<Map<String, dynamic>> createTestList<T>({
    required Map<String, dynamic> Function({required int index}) factory,
    int count = 10,
  }) {
    return List.generate(count, (index) => factory(index: index));
  }
}

/// Helper for verification
class VerificationHelpers {
  /// Verify navigation to route
  static void verifyNavigatedTo(
    WidgetTester tester,
    String routeName,
  ) {
    final navigator = tester.widget<Navigator>(find.byType(Navigator));
    expect(navigator, isNotNull);
  }

  /// Verify dialog shown
  static void verifyDialogShown(WidgetTester tester) {
    expect(find.byType(Dialog), findsOneWidget);
  }

  /// Verify snackbar shown
  static void verifySnackbarShown(
    WidgetTester tester,
    String message,
  ) {
    expect(find.text(message), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  }

  /// Verify loading indicator
  static void verifyLoadingIndicator(WidgetTester tester) {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Verify error message
  static void verifyErrorMessage(
    WidgetTester tester,
    String message,
  ) {
    expect(find.text(message), findsOneWidget);
  }

  /// Verify empty state
  static void verifyEmptyState(
    WidgetTester tester,
    String message,
  ) {
    expect(find.text(message), findsOneWidget);
  }
}

/// Helper for async testing
class AsyncTestHelpers {
  /// Run test with timeout
  static Future<T> runWithTimeout<T>(
    Future<T> Function() test, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return await test().timeout(timeout);
  }

  /// Mock delayed response
  static Future<T> mockDelayedResponse<T>(
    T value, {
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    await Future.delayed(delay);
    return value;
  }

  /// Mock delayed error
  static Future<T> mockDelayedError<T>(
    dynamic error, {
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    await Future.delayed(delay);
    throw error;
  }
}

/// Custom matchers
class CustomMatchers {
  /// Match date is today
  static Matcher isToday() {
    return predicate<DateTime>((date) {
      final now = DateTime.now();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }, 'is today');
  }

  /// Match list is not empty
  static Matcher isNotEmptyList() {
    return predicate<List>((list) => list.isNotEmpty, 'is not empty list');
  }

  /// Match string contains
  static Matcher containsString(String substring) {
    return predicate<String>(
      (str) => str.contains(substring),
      'contains "$substring"',
    );
  }

  /// Match value in range
  static Matcher inRange(num min, num max) {
    return predicate<num>(
      (value) => value >= min && value <= max,
      'is between $min and $max',
    );
  }
}