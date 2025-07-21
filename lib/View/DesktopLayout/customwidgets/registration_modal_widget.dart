import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'inputfieldwidget.dart';
import 'primarybuttonwidget.dart';

class RegistrationModalWidget extends StatefulWidget {
  final void Function(String username, String email, String password) onNext;
  const RegistrationModalWidget({Key? key, required this.onNext}) : super(key: key);

  @override
  State<RegistrationModalWidget> createState() => _RegistrationModalWidgetState();
}

class _RegistrationModalWidgetState extends State<RegistrationModalWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      widget.onNext(
        _usernameController.text.trim(),
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
                  height: 50,
                  width: 200,
                  child: CustomPaint(
                    painter: RegisterHeadingPainter(),
                  ),
                ),
                SizedBox(height: 30.h),
                InputFieldWidget(
                  input: "Username",
                  controller: _usernameController,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
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
                  validator: (value) => value == null || value.length < 6 ? 'Min 6 chars' : null,
                ),
                SizedBox(height: 30.h),
                Primarybuttonwidget(
                  run: _handleNext,
                  input: "Next",
                ),
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