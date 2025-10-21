// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_vps/controller/DesktopControllers/create_notification_controller.dart';
import 'package:demo_vps/Model/notification_modal.dart';

//Test for Notification Controls
void main() {
  group('NotificationController Tests (skip Firestore)', () {
    testWidgets(
      'Should show success SnackBar when deleteNotification succeeds',
      (tester) async {
        final controller = NotificationController(skipFirestore: true);
        final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

        await tester.pumpWidget(
          MaterialApp(
            scaffoldMessengerKey: scaffoldMessengerKey,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    key: const Key('deleteButton'),
                    onPressed: () async {
                      await controller.deleteNotification('fake_id', context);
                    },
                    child: const Text('Delete'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.tap(find.byKey(const Key('deleteButton')));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Notification deleted successfully'), findsOneWidget);
      },
    );

    testWidgets(
      'Should show success SnackBar when updateNotification succeeds',
      (tester) async {
        final controller = NotificationController(skipFirestore: true);
        final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

        final fakeNotification = NotificationModel(
          id: 'test_id',
          title: 'Updated Title',
          body: 'Updated Body',
          audience: 'All Users',
          uploadedDocument: null,
          documentName: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            scaffoldMessengerKey: scaffoldMessengerKey,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    key: const Key('updateButton'),
                    onPressed: () async {
                      await controller.updateNotification(
                        fakeNotification,
                        context,
                      );
                    },
                    child: const Text('Update'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.tap(find.byKey(const Key('updateButton')));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Notification updated successfully'), findsOneWidget);
      },
    );

    test(
      'Should get notifications stream without crashing (view test)',
      () async {
        final controller = NotificationController(skipFirestore: true);

        try {
          final stream = controller.getNotificationsStream();
          expect(stream, isA<Stream>()); // ✅ It should return a Stream
        } catch (e) {
          fail('getNotificationsStream threw an exception: $e');
        }
      },
    );
  });
}
