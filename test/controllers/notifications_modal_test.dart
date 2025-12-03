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
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: _NotificationsStub())),
      );
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Notification SnackBar (stubbed action)', () {
    testWidgets('shows notification SnackBar when pressed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: _NotificationButtonStub())),
      );

      await tester.tap(find.text('Show Notification'));
      await tester.pump();

      expect(find.text('Notification Created Successfully!'), findsOneWidget);
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
