import 'package:demo_vps/controllers/create_notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

//Test for Creating Notification Controller (Admin side)
void main() {
  group('CreateNotificationController Tests', () {
    late TextEditingController titleController;
    late TextEditingController bodyController;

    setUp(() {
      titleController = TextEditingController();
      bodyController = TextEditingController();
    });

    testWidgets('Should show error if required fields are empty', (
      tester,
    ) async {
      late CreateNotificationController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                controller = CreateNotificationController(
                  titleController: titleController,
                  bodyController: bodyController,
                  context: context,
                  skipFirestore: true, // 👈 skip Firestore for safety
                );
                return Container();
              },
            ),
          ),
        ),
      );

      await tester.pump();

      await controller.submitNotification(() {});
      await tester.pump();

      expect(find.text('Please fill all required fields'), findsOneWidget);
    });

    testWidgets('Should show success when all fields are filled', (
      tester,
    ) async {
      late CreateNotificationController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                controller = CreateNotificationController(
                  titleController: titleController,
                  bodyController: bodyController,
                  context: context,
                  skipFirestore: true, // 👈 skip Firestore here too
                );
                return Container();
              },
            ),
          ),
        ),
      );

      await tester.pump();

      titleController.text = 'Test Title';
      bodyController.text = 'Test Body';
      controller.audience = 'students';

      await controller.submitNotification(() {});
      await tester.pump();

      // ✅ Should show success SnackBar
      expect(find.text('Notification Created Successfully!'), findsOneWidget);

      // ✅ Should clear fields
      expect(titleController.text, '');
      expect(bodyController.text, '');
      expect(controller.audience, 'Select Audience');
    });
  });
}
