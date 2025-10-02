import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Project Workflow Integration Tests', () {
    testWidgets('complete project creation workflow', (tester) async {
      // Setup test data
      final projectData = TestDataFactory.createTestProject(
        name: 'Integration Test Project',
        status: 'draft',
      );

      // Build app with test navigation
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        TestHelpers.createTestWidgetWithNavigation(
          navigatorKey: navigatorKey,
          child: _MockProjectsPage(),
        ),
      );

      // Step 1: Navigate to create project page
      await TestHelpers.tapWidget(
        tester,
        find.byKey(const Key('create_project_button')),
      );
      await tester.pumpAndSettle();

      // Step 2: Fill project form
      await TestHelpers.enterText(
        tester,
        TestHelpers.findByKey('project_name_field'),
        projectData['name'] as String,
      );

      await TestHelpers.enterText(
        tester,
        TestHelpers.findByKey('project_description_field'),
        projectData['description'] as String,
      );

      // Step 3: Submit form
      await TestHelpers.tapWidget(
        tester,
        find.byKey(const Key('submit_project_button')),
      );
      await TestHelpers.waitForAsync(tester);

      // Step 4: Verify success message
      expect(find.text('Project created successfully'), findsOneWidget);

      // Step 5: Verify navigation to project detail
      expect(find.byType(_MockProjectDetailPage), findsOneWidget);
    });

    testWidgets('project list to detail navigation', (tester) async {
      final projects = TestDataFactory.createTestList(
        factory: ({required index}) => TestDataFactory.createTestProject(
          id: 'project_$index',
          name: 'Project $index',
        ),
        count: 5,
      );

      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          child: _MockProjectsListPage(projects: projects),
        ),
      );

      // Verify projects are displayed
      for (final project in projects) {
        expect(find.text(project['name'] as String), findsOneWidget);
      }

      // Tap on first project
      await TestHelpers.tapWidget(
        tester,
        find.text(projects.first['name'] as String),
      );
      await tester.pumpAndSettle();

      // Verify detail page is shown
      expect(find.byType(_MockProjectDetailPage), findsOneWidget);
    });

    testWidgets('project update workflow', (tester) async {
      final project = TestDataFactory.createTestProject();

      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          child: _MockProjectDetailPage(project: project),
        ),
      );

      // Tap edit button
      await TestHelpers.tapWidget(
        tester,
        find.byKey(const Key('edit_project_button')),
      );
      await tester.pumpAndSettle();

      // Update project name
      await TestHelpers.enterText(
        tester,
        TestHelpers.findByKey('project_name_field'),
        'Updated Project Name',
      );

      // Save changes
      await TestHelpers.tapWidget(
        tester,
        find.byKey(const Key('save_project_button')),
      );
      await TestHelpers.waitForAsync(tester);

      // Verify success message
      expect(find.text('Project updated successfully'), findsOneWidget);
    });

    testWidgets('project deletion workflow', (tester) async {
      final project = TestDataFactory.createTestProject();

      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          child: _MockProjectDetailPage(project: project),
        ),
      );

      // Tap delete button
      await TestHelpers.tapWidget(
        tester,
        find.byKey(const Key('delete_project_button')),
      );
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      VerificationHelpers.verifyDialogShown(tester);
      expect(find.text('Confirm Delete'), findsOneWidget);

      // Confirm deletion
      await TestHelpers.tapWidget(tester, find.text('Delete'));
      await TestHelpers.waitForAsync(tester);

      // Verify success message
      expect(find.text('Project deleted successfully'), findsOneWidget);
    });
  });
}

// Mock pages for testing
class _MockProjectsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: ElevatedButton(
        key: const Key('create_project_button'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _MockCreateProjectPage()),
          );
        },
        child: const Text('Create Project'),
      ),
    );
  }
}

class _MockCreateProjectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Project')),
      body: Column(
        children: [
          const TextField(key: Key('project_name_field')),
          const TextField(key: Key('project_description_field')),
          ElevatedButton(
            key: const Key('submit_project_button'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Project created successfully')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => _MockProjectDetailPage(
                    project: TestDataFactory.createTestProject(),
                  ),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _MockProjectsListPage extends StatelessWidget {
  final List<Map<String, dynamic>> projects;

  const _MockProjectsListPage({required this.projects});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects List')),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return ListTile(
            title: Text(project['name'] as String),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _MockProjectDetailPage(project: project),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MockProjectDetailPage extends StatelessWidget {
  final Map<String, dynamic> project;

  const _MockProjectDetailPage({required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Detail')),
      body: Column(
        children: [
          Text(project['name'] as String),
          ElevatedButton(
            key: const Key('edit_project_button'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _MockEditProjectPage(project: project),
                ),
              );
            },
            child: const Text('Edit'),
          ),
          ElevatedButton(
            key: const Key('delete_project_button'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Project deleted successfully'),
                          ),
                        );
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _MockEditProjectPage extends StatelessWidget {
  final Map<String, dynamic> project;

  const _MockEditProjectPage({required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Project')),
      body: Column(
        children: [
          TextField(
            key: const Key('project_name_field'),
            controller: TextEditingController(text: project['name'] as String),
          ),
          ElevatedButton(
            key: const Key('save_project_button'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Project updated successfully')),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}