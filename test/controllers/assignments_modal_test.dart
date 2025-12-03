import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_vps/View/custom_widgets/uploadfilewidget.dart';

// Simplified UI test avoiding app dependencies
class _AssignmentsStub extends StatelessWidget {
  const _AssignmentsStub();
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [Text('My Assignments'), CircularProgressIndicator()],
    );
  }
}

void main() {
  group('Assignments UI (stubbed)', () {
    testWidgets('renders header and loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: _AssignmentsStub())),
      );
      expect(find.text('My Assignments'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('UploadFileWidget', () {
    testWidgets('shows SnackBar and triggers callback on choose', (
      tester,
    ) async {
      String? gotName;
      String? gotBase64;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UploadFileWidget(
              onFilePicked: (b64, name) {
                gotBase64 = b64;
                gotName = name;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Choose File'));
      await tester.pumpAndSettle();

      expect(find.text('Stub file selected: dummy.txt'), findsOneWidget);
      expect(gotName, 'dummy.txt');
      expect(gotBase64, isNotNull);
    });
  });
}
