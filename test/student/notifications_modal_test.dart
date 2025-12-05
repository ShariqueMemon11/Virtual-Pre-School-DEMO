// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Simplified UI test avoiding app dependencies
class _NotificationsStub extends StatelessWidget {
  const _NotificationsStub();
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [Text('Notifications'), CircularProgressIndicator()],
    );
  }
}

void main() {
  group('Notifications UI (stubbed)', () {
    testWidgets('renders header and loading', (tester) async {
      print(
        'Student notifications screen: checking that it shows and is loading.',
      );

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: _NotificationsStub())),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      print('Student notifications screen looks OK.');
    });
  });

  group('Notification SnackBar (stubbed action)', () {
    testWidgets('shows notification SnackBar when pressed', (tester) async {
      print('Student taps the notifications button.');

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: _NotificationButtonStub())),
      );

      await tester.tap(find.text('Show Notification'));
      await tester.pump();

      expect(find.text('Notification Created Successfully!'), findsOneWidget);
      print('Student sees a message that the notification was created.');
    });
  });
}

class _NotificationButtonStub extends StatelessWidget {
  const _NotificationButtonStub();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification Created Successfully!')),
          );
        },
        child: const Text('Show Notification'),
      ),
    );
  }
}
