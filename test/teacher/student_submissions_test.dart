// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// TEACHER: Student submissions – simple list + download confirmation.

class _TeacherSubmissionsStub extends StatelessWidget {
  const _TeacherSubmissionsStub();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Submissions')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Submissions'),
          ),
          ListTile(
            title: const Text('Math Homework'),
            subtitle: const Text('Student: Alex'),
            trailing: IconButton(
              key: const Key('downloadSubmissionButton'),
              icon: const Icon(Icons.download),
              onPressed: () {
                // In the real screen this will download the file.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Teacher is downloading the student work.'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('Teacher – Student submissions', () {
    testWidgets(
      'shows confirmation when teacher downloads a student submission',
      (tester) async {
        print('Step 1: Teacher opens the Student Submissions screen.');

        await tester.pumpWidget(
          const MaterialApp(
            home: _TeacherSubmissionsStub(),
          ),
        );

        print('Step 2: Teacher clicks the download button for a student\'s work.');
        await tester.tap(find.byKey(const Key('downloadSubmissionButton')));
        await tester.pump(); // show SnackBar

        expect(
          find.text('Teacher is downloading the student work.'),
          findsOneWidget,
        );

        print('Step 3: Teacher sees a message that the student work is downloading.');
      },
    );
  });
}


