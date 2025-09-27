import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../customwidgets/inputfieldwidget.dart';
import '../customwidgets/primarybuttonwidget.dart';
import '../../../controller/DesktopControllers/registration_controller.dart';

class RegistrationModalWidget extends StatefulWidget {
  final void Function(String email, String password) onNext;
  const RegistrationModalWidget({super.key, required this.onNext});

  @override
  State<RegistrationModalWidget> createState() =>
      _RegistrationModalWidgetState();
}

class _RegistrationModalWidgetState extends State<RegistrationModalWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final RegistrationController _registerController;

  @override
  void initState() {
    super.initState();
    _registerController = RegistrationController(
      emailController: _emailController,
      passwordController: _passwordController,
      context: context,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleNext() async {
    if (_formKey.currentState!.validate()) {
      await _registerController.registerUser();

      widget.onNext(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF8C5FF5),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          width: 420.w,
          padding: EdgeInsets.all(24.0.h),
          decoration: BoxDecoration(
            color: const Color.fromARGB(141, 233, 233, 233),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 8,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 50.h,
                  width: 200.w,
                  child: Center(
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 40.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                InputFieldWidget(
                  input: "Email",
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
                    if (!emailRegex.hasMatch(value)) return 'Invalid email';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                InputFieldWidget(
                  input: "Password",
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value.length < 6) return 'Min 6 chars';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                InputFieldWidget(
                  input: "Confirm Password",
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value.length < 6) return 'Min 6 chars';
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30.h),
                Primarybuttonwidget(run: _handleNext, input: "Register"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterHeadingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Register',
        style: TextStyle(
          fontSize: 40,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, 0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
