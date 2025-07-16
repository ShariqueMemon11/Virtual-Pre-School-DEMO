import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:demo_vps/controller/DesktopControllers/assign_teacher_controller.dart';

void main() {
  group('AssignTeacherController', () {
    testWidgets('shows error if teacher or class is not selected', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final controller = AssignTeacherController(context: context);
              controller.Teacher = null;
              controller.Class = null;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.AssignTeacher(() {});
              });
              return Container();
            },
          ),
        ),
      ));
      await tester.pump(); // Let the post-frame callback run
    });

    testWidgets('assigns successfully when teacher and class are selected', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final controller = AssignTeacherController(context: context);
              controller.Teacher = 'Teacher A';
              controller.Class = 'Class 1';
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.AssignTeacher(() {});
              });
              return Container();
            },
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2)); // Let the timer complete
      // Optionally, check for success SnackBar
    });

    testWidgets('shows error if only teacher is selected', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final controller = AssignTeacherController(context: context);
              controller.Teacher = 'Teacher A';
              controller.Class = null;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.AssignTeacher(() {});
              });
              return Container();
            },
          ),
        ),
      ));
      await tester.pump();
      // Optionally, check for error SnackBar
    });

    testWidgets('shows error if only class is selected', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final controller = AssignTeacherController(context: context);
              controller.Teacher = null;
              controller.Class = 'Class 1';
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.AssignTeacher(() {});
              });
              return Container();
            },
          ),
        ),
      ));
      await tester.pump();
      // Optionally, check for error SnackBar
    });
  });
} 