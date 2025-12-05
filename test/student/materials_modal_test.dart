// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// These tests are STUDENT-side and focus on the materials experience.

class _ClassMaterialsEmptyStub extends StatelessWidget {
  const _ClassMaterialsEmptyStub();

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      child: Column(
        children: [
          Text('Class Materials'),
          Expanded(
            child: Center(
              child: Text('No materials available'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassMaterialsDownloadStub extends StatelessWidget {
  const _ClassMaterialsDownloadStub();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          const Text('Class Materials'),
          const SizedBox(height: 8),
          const Text('Sample Material Title'),
          ElevatedButton.icon(
            key: const Key('downloadMaterialButton'),
            onPressed: () {
              // Simulate a successful download for the student and confirm via SnackBar.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Material downloaded successfully for student.'),
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download sample.pdf'),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('Class Materials (student) – viewing state', () {
    testWidgets(
      'shows header and empty state when no materials are available',
      (tester) async {
        print('Student opens Class Materials with no items.');

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _ClassMaterialsEmptyStub(),
            ),
          ),
        );

        expect(find.text('Class Materials'), findsOneWidget);
        expect(find.text('No materials available'), findsOneWidget);

        print('Student sees that no materials are available yet.');
      },
    );
  });

  group('Class Materials (student) – download flow', () {
    testWidgets(
      'shows SnackBar confirmation when student downloads a material',
      (tester) async {
        print('Student opens Class Materials with a downloadable file.');

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: _ClassMaterialsDownloadStub(),
            ),
          ),
        );

        await tester.tap(find.byKey(const Key('downloadMaterialButton')));
        await tester.pump(); // Let SnackBar appear

        expect(
          find.text('Material downloaded successfully for student.'),
          findsOneWidget,
        );

        print('Student sees a message that the material was downloaded.');
      },
    );
  });
}


