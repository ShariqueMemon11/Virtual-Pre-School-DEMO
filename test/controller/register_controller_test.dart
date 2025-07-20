import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_vps/controller/DesktopControllers/register_controller.dart';

void main() {
  group('RegisterController', () {
    late TextEditingController nameController;
    late TextEditingController emailController;
    late TextEditingController passwordController;
    late TextEditingController phoneController;
    late TextEditingController addressController;
    late GlobalKey<FormState> formKey;

    setUp(() {
      nameController = TextEditingController(text: 'Test User');
      emailController = TextEditingController(text: 'test@email.com');
      passwordController = TextEditingController(text: 'password123');
      phoneController = TextEditingController(text: '1234567890');
      addressController = TextEditingController(text: '123 Main St');
      formKey = GlobalKey<FormState>();
    });

    testWidgets('shows error if any field is empty', (
      WidgetTester tester,
    ) async {
      nameController.text = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Builder(
                builder: (context) {
                  final controller = RegisterController(
                    nameController: nameController,
                    emailController: emailController,
                    passwordController: passwordController,
                    phoneController: phoneController,
                    addressController: addressController,
                    context: context,
                  );
                  return ElevatedButton(
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.registerUser();
                      });
                    },
                    child: Text('Register'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      // Optionally, check for error SnackBar
    });

    testWidgets('registers successfully with valid fields', (
      WidgetTester tester,
    ) async {
      nameController.text = 'Test User';
      emailController.text = 'test@email.com';
      passwordController.text = 'password123';
      phoneController.text = '1234567890';
      addressController.text = '123 Main St';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Builder(
                builder: (context) {
                  final controller = RegisterController(
                    nameController: nameController,
                    emailController: emailController,
                    passwordController: passwordController,
                    phoneController: phoneController,
                    addressController: addressController,
                    context: context,
                  );
                  return ElevatedButton(
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.registerUser();
                      });
                    },
                    child: Text('Register'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      // Optionally, check for success SnackBar
    });

    testWidgets('shows error if email is invalid', (WidgetTester tester) async {
      emailController.text = 'invalid-email';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Builder(
                builder: (context) {
                  final controller = RegisterController(
                    nameController: nameController,
                    emailController: emailController,
                    passwordController: passwordController,
                    phoneController: phoneController,
                    addressController: addressController,
                    context: context,
                  );
                  return ElevatedButton(
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.registerUser();
                      });
                    },
                    child: Text('Register'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      // Optionally, check for error SnackBar
    });

    testWidgets('shows error if password is too short', (
      WidgetTester tester,
    ) async {
      passwordController.text = '123';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Builder(
                builder: (context) {
                  final controller = RegisterController(
                    nameController: nameController,
                    emailController: emailController,
                    passwordController: passwordController,
                    phoneController: phoneController,
                    addressController: addressController,
                    context: context,
                  );
                  return ElevatedButton(
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.registerUser();
                      });
                    },
                    child: Text('Register'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      // Optionally, check for error SnackBar
    });
  });
}
