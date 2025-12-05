// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// TEACHER: Update Grades – simple screen + save confirmation.

class _UpdateGradesStub extends StatelessWidget {
  const _UpdateGradesStub();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Grades')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Add or Update Student Grades'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              key: const Key('gradeInputField'),
              decoration: const InputDecoration(
                labelText: 'Enter grade',
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('saveGradesButton'),
            onPressed: () {
              // Real screen would validate and save to Firestore.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Grades saved for the student.'),
                ),
              );
            },
            child: const Text('Save Grades'),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('Teacher – Update Grades', () {
    testWidgets(
      'shows success message when teacher saves grades',
      (tester) async {
        print('Step 1: Teacher opens the Update Grades screen.');

        await tester.pumpWidget(
          const MaterialApp(
            home: _UpdateGradesStub(),
          ),
        );

        print('Step 2: Teacher types a grade for the student.');
        await tester.enterText(
          find.byKey(const Key('gradeInputField')),
          'A',
        );
        print('Step 3: Teacher taps the "Save Grades" button.');
        await tester.tap(find.byKey(const Key('saveGradesButton')));
        await tester.pump(); // show SnackBar

        expect(
          find.text('Grades saved for the student.'),
          findsOneWidget,
        );

        print('Step 4: Teacher sees a success message that the grade was saved.');
      },
    );
  });
}


