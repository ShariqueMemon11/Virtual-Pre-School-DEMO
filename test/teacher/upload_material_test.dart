// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// TEACHER: Upload Material – simple upload + confirmation.

class _UploadMaterialStub extends StatelessWidget {
  const _UploadMaterialStub();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Class Material')),
      body: Center(
        child: ElevatedButton(
          key: const Key('uploadMaterialButton'),
          onPressed: () {
            // Real page would let teacher pick a file and upload it.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Class material uploaded for students.'),
              ),
            );
          },
          child: const Text('Upload Material'),
        ),
      ),
    );
  }
}

void main() {
  group('Teacher – Upload Material', () {
    testWidgets(
      'shows success message when teacher uploads material',
      (tester) async {
        print('Step 1: Teacher opens the Upload Class Material screen.');

        await tester.pumpWidget(
          const MaterialApp(
            home: _UploadMaterialStub(),
          ),
        );

        print('Step 2: Teacher taps the "Upload Material" button to send a file.');
        await tester.tap(find.byKey(const Key('uploadMaterialButton')));
        await tester.pump(); // show SnackBar

        expect(
          find.text('Class material uploaded for students.'),
          findsOneWidget,
        );

        print('Step 3: Teacher sees a success message that the material was uploaded.');
      },
    );
  });
}


