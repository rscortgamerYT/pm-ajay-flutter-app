# Phase 15: Testing Infrastructure

## Overview

Phase 15 establishes a comprehensive testing infrastructure for the PM-AJAY Flutter application, including unit tests, widget tests, integration tests, and testing utilities.

## Implemented Components

### 1. Test Helpers ([`test/helpers/test_helpers.dart`](../test/helpers/test_helpers.dart))

**Purpose**: Provide reusable utilities for testing Flutter widgets and functionality

**Classes and Methods**:

#### TestHelpers
- `initializeHive()`: Setup Hive for testing
- `closeHive()`: Cleanup Hive after tests
- `createTestWidget()`: Wrap widgets with ProviderScope and MaterialApp
- `createTestWidgetWithNavigation()`: Create testable widget with navigation
- `pumpAndSettle()`: Custom pump and settle with duration
- `findByKey()`, `findByText()`, `findByType()`: Widget finders
- `verifyWidgetExists()`, `verifyWidgetNotExists()`, `verifyWidgetCount()`: Verification helpers
- `tapWidget()`, `enterText()`, `scrollUntilVisible()`: Interaction helpers
- `mockFuture()`, `mockErrorFuture()`, `mockStream()`: Mock data helpers

#### TestDataFactory
Creates realistic test data for all entities:
- `createTestUser()`: Generate user test data
- `createTestProject()`: Generate project test data
- `createTestAgency()`: Generate agency test data
- `createTestTender()`: Generate tender test data
- `createTestDocument()`: Generate document test data
- `createTestList()`: Generate lists of test items

#### VerificationHelpers
- `verifyNavigatedTo()`: Verify route navigation
- `verifyDialogShown()`: Verify dialog display
- `verifySnackbarShown()`: Verify snackbar with message
- `verifyLoadingIndicator()`: Verify loading state
- `verifyErrorMessage()`: Verify error display
- `verifyEmptyState()`: Verify empty state display

#### AsyncTestHelpers
- `runWithTimeout()`: Execute tests with timeout
- `mockDelayedResponse()`: Mock async responses with delay
- `mockDelayedError()`: Mock async errors with delay

#### CustomMatchers
- `isToday()`: Match dates to today
- `isNotEmptyList()`: Match non-empty lists
- `containsString()`: Match string contains substring
- `inRange()`: Match numeric range

**Usage Example**:
```dart
testWidgets('should display login form', (tester) async {
  await tester.pumpWidget(
    TestHelpers.createTestWidget(
      child: LoginPage(),
    ),
  );

  TestHelpers.verifyWidgetExists(TestHelpers.findByKey('email_field'));
  TestHelpers.verifyWidgetExists(TestHelpers.findByKey('password_field'));
});
```

### 2. Unit Tests

#### Performance Service Tests ([`test/core/services/performance_service_test.dart`](../test/core/services/performance_service_test.dart))

Tests for the performance caching service:
- Cache data storage and retrieval
- Cache expiration after duration
- Clear specific cache entries
- Clear all cache entries
- Get cache statistics
- Batch get operations
- Batch set operations
- CacheMixin functionality
- Cache invalidation

**Test Structure**:
```dart
group('PerformanceService Cache Tests', () {
  test('should cache and retrieve data', () async {
    await performanceService.setCached('key', 'value');
    final cached = await performanceService.getCached<String>('key');
    expect(cached, 'value');
  });
  
  test('should expire cache after duration', () async {
    await performanceService.setCached('key', 'value');
    await Future.delayed(Duration(milliseconds: 100));
    final cached = await performanceService.getCached<String>(
      'key',
      maxAge: Duration(milliseconds: 50),
    );
    expect(cached, isNull);
  });
});
```

### 3. Widget Tests

#### Login Page Tests ([`test/features/auth/presentation/pages/login_page_test.dart`](../test/features/auth/presentation/pages/login_page_test.dart))

Tests for login page UI and interactions:
- Display login form elements
- Validate empty email field
- Show loading indicator on login
- Navigate to home on successful login
- Show error message on failed login
- Toggle password visibility

**Test Structure**:
```dart
testWidgets('should display login form elements', (tester) async {
  await tester.pumpWidget(TestHelpers.createTestWidget(child: LoginPage()));
  
  TestHelpers.verifyWidgetExists(find.byKey(Key('email_field')));
  TestHelpers.verifyWidgetExists(find.byKey(Key('password_field')));
  TestHelpers.verifyWidgetExists(find.byKey(Key('login_button')));
});
```

### 4. Integration Tests

#### Project Workflow Tests ([`test/integration/project_workflow_test.dart`](../test/integration/project_workflow_test.dart))

End-to-end tests for project management workflows:
- Complete project creation workflow
- Project list to detail navigation
- Project update workflow
- Project deletion workflow

**Test Structure**:
```dart
testWidgets('complete project creation workflow', (tester) async {
  // Step 1: Navigate to create project page
  await TestHelpers.tapWidget(tester, find.byKey(Key('create_project_button')));
  
  // Step 2: Fill project form
  await TestHelpers.enterText(tester, find.byKey(Key('project_name_field')), 'Test Project');
  
  // Step 3: Submit form
  await TestHelpers.tapWidget(tester, find.byKey(Key('submit_project_button')));
  
  // Step 4: Verify success
  expect(find.text('Project created successfully'), findsOneWidget);
});
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/core/services/performance_service_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Integration Tests
```bash
flutter test test/integration/
```

### Run Widget Tests
```bash
flutter test test/features/
```

## Test Coverage Goals

- **Unit Tests**: 80%+ coverage for services and utilities
- **Widget Tests**: 70%+ coverage for UI components
- **Integration Tests**: Key user workflows covered
- **Overall Coverage**: 75%+ application-wide

## Writing New Tests

### Unit Test Template
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  late YourService service;

  setUp(() {
    service = YourService();
  });

  tearDown(() {
    // Cleanup
  });

  group('YourService Tests', () {
    test('should do something', () {
      // Arrange
      final input = 'test';
      
      // Act
      final result = service.doSomething(input);
      
      // Assert
      expect(result, 'expected');
    });
  });
}
```

### Widget Test Template
```dart
import 'package:flutter_test/flutter_test.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  group('YourWidget Tests', () {
    testWidgets('should display correctly', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          child: YourWidget(),
        ),
      );

      TestHelpers.verifyWidgetExists(find.text('Expected Text'));
    });
  });
}
```

### Integration Test Template
```dart
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Feature Integration Tests', () {
    testWidgets('complete user workflow', (tester) async {
      // Setup
      await tester.pumpWidget(TestHelpers.createTestWidget(child: App()));
      
      // Step 1: User action
      await TestHelpers.tapWidget(tester, find.text('Button'));
      
      // Step 2: Verify result
      expect(find.text('Success'), findsOneWidget);
    });
  });
}
```

## Testing Best Practices

### 1. Test Organization
- Group related tests using `group()`
- Use descriptive test names that explain what is being tested
- Follow AAA pattern: Arrange, Act, Assert

### 2. Test Data
- Use `TestDataFactory` for consistent test data
- Keep test data minimal but realistic
- Don't hardcode test data in tests

### 3. Async Testing
- Always use `await` with async operations
- Use `pumpAndSettle()` after interactions
- Use `waitForAsync()` for complex async flows

### 4. Widget Testing
- Test user-visible behavior, not implementation
- Use key-based widget finding for reliability
- Test error states and edge cases

### 5. Mocking
- Mock external dependencies
- Use realistic mock data
- Don't mock the thing you're testing

### 6. Test Isolation
- Each test should be independent
- Use `setUp()` and `tearDown()` for initialization/cleanup
- Don't share state between tests

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2
```

## Common Testing Patterns

### Testing Providers
```dart
testWidgets('provider test', (tester) async {
  final container = ProviderContainer();
  
  final value = container.read(yourProvider);
  expect(value, expectedValue);
  
  container.dispose();
});
```

### Testing Navigation
```dart
testWidgets('navigation test', (tester) async {
  final navigatorKey = GlobalKey<NavigatorState>();
  
  await tester.pumpWidget(
    TestHelpers.createTestWidgetWithNavigation(
      navigatorKey: navigatorKey,
      child: YourPage(),
    ),
  );
  
  await TestHelpers.tapWidget(tester, find.text('Navigate'));
  expect(navigatorKey.currentState, isNotNull);
});
```

### Testing Forms
```dart
testWidgets('form test', (tester) async {
  await tester.pumpWidget(TestHelpers.createTestWidget(child: FormPage()));
  
  await TestHelpers.enterText(tester, find.byKey(Key('field')), 'value');
  await TestHelpers.tapWidget(tester, find.text('Submit'));
  
  expect(find.text('Success'), findsOneWidget);
});
```

### Testing Lists
```dart
testWidgets('list test', (tester) async {
  final items = TestDataFactory.createTestList(
    factory: ({required index}) => TestDataFactory.createTestProject(id: '$index'),
    count: 10,
  );
  
  await tester.pumpWidget(TestHelpers.createTestWidget(child: ListPage(items)));
  
  TestHelpers.verifyWidgetCount(find.byType(ListTile), 10);
});
```

## Troubleshooting

### Test Times Out
- Increase timeout in `runWithTimeout()`
- Check for missing `await` statements
- Verify async operations complete

### Widget Not Found
- Use `printWidget()` to debug widget tree
- Verify widget is actually rendered
- Check for correct key or text

### Flaky Tests
- Add `pumpAndSettle()` after interactions
- Use `waitForAsync()` for async operations
- Ensure proper test isolation

### Mock Data Issues
- Verify mock data structure matches real data
- Use `TestDataFactory` for consistency
- Check data types and nullability

## Next Steps

Phase 15 is complete. Final phase:
- **Phase 16**: Deployment & Monitoring

## Files Created

1. [`test/helpers/test_helpers.dart`](../test/helpers/test_helpers.dart) - 403 lines
2. [`test/core/services/performance_service_test.dart`](../test/core/services/performance_service_test.dart) - 143 lines
3. [`test/features/auth/presentation/pages/login_page_test.dart`](../test/features/auth/presentation/pages/login_page_test.dart) - 161 lines
4. [`test/integration/project_workflow_test.dart`](../test/integration/project_workflow_test.dart) - 269 lines

**Total**: 976 lines of comprehensive testing infrastructure

## Summary

Phase 15 provides a complete testing infrastructure with:
- Reusable test helpers and utilities
- Unit test examples for services
- Widget test examples for UI components
- Integration test examples for workflows
- Best practices and patterns
- CI/CD integration guidance

The testing infrastructure enables confident development and refactoring with comprehensive test coverage across all application layers.