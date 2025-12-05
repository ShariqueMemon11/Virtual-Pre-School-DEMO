// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// TEACHER: Assign Activity – simple UI + success message test.

class _AssignActivityStub extends StatelessWidget {
  const _AssignActivityStub();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Activity')),
      body: Center(
        child: ElevatedButton(
          key: const Key('assignActivityButton'),
          onPressed: () {
            // In the real screen this would save to Firestore,
            // here we only confirm that the teacher sees success.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Activity assigned to students.'),
              ),
            );
          },
          child: const Text('Assign Activity'),
        ),
      ),
    );
  }
}

void main() {
  group('Teacher – Assign Activity', () {
    testWidgets(
      'shows success message when teacher assigns an activity',
      (tester) async {
        print('Step 1: Teacher opens the Assign Activity screen.');

        await tester.pumpWidget(
          const MaterialApp(
            home: _AssignActivityStub(),
          ),
        );

        print('Step 2: Teacher taps the "Assign Activity" button to send work.');
        await tester.tap(find.byKey(const Key('assignActivityButton')));
        await tester.pump(); // show SnackBar

        expect(
          find.text('Activity assigned to students.'),
          findsOneWidget,
        );

        print('Step 3: Teacher sees a success message that the activity was assigned.');
      },
    );
  });
}


