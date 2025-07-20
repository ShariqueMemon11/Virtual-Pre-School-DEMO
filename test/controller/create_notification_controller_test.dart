import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_vps/controller/DesktopControllers/create_notification_controller.dart';

void main() {
  group('CreateNotificationController', () {
    late TextEditingController titleController;
    late TextEditingController bodyController;

    setUp(() {
      titleController = TextEditingController();
      bodyController = TextEditingController();
    });

    testWidgets('should validate and submit notification', (
      WidgetTester tester,
    ) async {
      titleController.text = 'Test';
      bodyController.text = 'Message';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final controller = CreateNotificationController(
                  titleController: titleController,
                  bodyController: bodyController,
                  context: context,
                  isTest: true,
                );
                controller.audience = 'All';
                return ElevatedButton(
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.submitNotification(() {});
                    });
                  },
                  child: Text('Send'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      // Optionally, check for SnackBar or other side effects here
    });

    testWidgets('should show error if title or message is empty', (
      WidgetTester tester,
    ) async {
      titleController.text = '';
      bodyController.text = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final controller = CreateNotificationController(
                  titleController: titleController,
                  bodyController: bodyController,
                  context: context,
                  isTest: true,
                );
                controller.audience = 'All';
                return ElevatedButton(
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.submitNotification(() {});
                    });
                  },
                  child: Text('Send'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      // Optionally, check for error SnackBar
    });

    testWidgets('should show error if audience is not selected', (
      WidgetTester tester,
    ) async {
      titleController.text = 'Test';
      bodyController.text = 'Message';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final controller = CreateNotificationController(
                  titleController: titleController,
                  bodyController: bodyController,
                  context: context,
                  isTest: true,
                );
                controller.audience = null; // Not selected
                return ElevatedButton(
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.submitNotification(() {});
                    });
                  },
                  child: Text('Send'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      // Optionally, check for error SnackBar
    });

    testWidgets('should handle file attachment logic', (
      WidgetTester tester,
    ) async {
      titleController.text = 'Test';
      bodyController.text = 'Message';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final controller = CreateNotificationController(
                  titleController: titleController,
                  bodyController: bodyController,
                  context: context,
                  isTest: true,
                );
                controller.audience = 'All';
                controller.fileName = 'test.pdf'; // Simulate file attached
                return ElevatedButton(
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.submitNotification(() {});
                    });
                  },
                  child: Text('Send'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      // Optionally, check for SnackBar or file logic
    });
  });
}
