import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_vps/controller/DesktopControllers/teacher_admission_controller.dart';
import 'dart:io';

void main() {
  group('TeacherAdmissionController', () {
    late TextEditingController nameController;
    late TextEditingController emailController;
    late TextEditingController phoneController;
    late TextEditingController qualificationController;
    late TextEditingController experienceController;
    late TextEditingController subjectsController;
    late TextEditingController addressController;
    late GlobalKey<FormState> formKey;

    setUp(() {
      nameController = TextEditingController(text: 'Test Name');
      emailController = TextEditingController(text: 'test@email.com');
      phoneController = TextEditingController(text: '1234567890');
      qualificationController = TextEditingController(text: 'MSc');
      experienceController = TextEditingController(text: '5');
      subjectsController = TextEditingController(text: 'Math');
      addressController = TextEditingController(text: '123 Street');
      formKey = GlobalKey<FormState>();
    });

    testWidgets('shows error if CV is not uploaded', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Builder(
                builder: (context) {
                  final controller = TeacherAdmissionController(
                    nameController: nameController,
                    emailController: emailController,
                    phoneController: phoneController,
                    qualificationController: qualificationController,
                    experienceController: experienceController,
                    subjectsController: subjectsController,
                    addressController: addressController,
                    context: context,
                    formKey: formKey,
                  );
                  return ElevatedButton(
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.submit();
                      });
                    },
                    child: Text('Submit'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      // Optionally, check for error SnackBar
    });

    testWidgets('should submit successfully when all fields are valid and CV is uploaded', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Builder(
                builder: (context) {
                  final controller = TeacherAdmissionController(
                    nameController: nameController,
                    emailController: emailController,
                    phoneController: phoneController,
                    qualificationController: qualificationController,
                    experienceController: experienceController,
                    subjectsController: subjectsController,
                    addressController: addressController,
                    context: context,
                    formKey: formKey,
                  );
                  // Simulate CV upload
                  controller.cvFileName = 'cv.pdf';
                  controller.testCvFile = File('dummy');
                  return ElevatedButton(
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.submit();
                      });
                    },
                    child: Text('Submit'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      // Optionally, check for success SnackBar
    });

    testWidgets('should show error if email is invalid', (WidgetTester tester) async {
      emailController.text = 'invalid-email';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Builder(
                builder: (context) {
                  final controller = TeacherAdmissionController(
                    nameController: nameController,
                    emailController: emailController,
                    phoneController: phoneController,
                    qualificationController: qualificationController,
                    experienceController: experienceController,
                    subjectsController: subjectsController,
                    addressController: addressController,
                    context: context,
                    formKey: formKey,
                  );
                  // Simulate CV upload
                  controller.cvFileName = 'cv.pdf';
                  controller.testCvFile = File('dummy');
                  return ElevatedButton(
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.submit();
                      });
                    },
                    child: Text('Submit'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      // Optionally, check for error SnackBar
    });

    testWidgets('should show error if required field is missing', (WidgetTester tester) async {
      nameController.text = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Builder(
                builder: (context) {
                  final controller = TeacherAdmissionController(
                    nameController: nameController,
                    emailController: emailController,
                    phoneController: phoneController,
                    qualificationController: qualificationController,
                    experienceController: experienceController,
                    subjectsController: subjectsController,
                    addressController: addressController,
                    context: context,
                    formKey: formKey,
                  );
                  // Simulate CV upload
                  controller.cvFileName = 'cv.pdf';
                  controller.testCvFile = File('dummy');
                  return ElevatedButton(
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.submit();
                      });
                    },
                    child: Text('Submit'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      // Optionally, check for error SnackBar
    });
  });
} 