import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controller/DesktopControllers/registration_controller.dart';

class RegistrationModalWidget extends StatefulWidget {
  final void Function(String email, String password) onNext;

  const RegistrationModalWidget({super.key, required this.onNext});

  @override
  State<RegistrationModalWidget> createState() =>
      _RegistrationModalWidgetState();
}

class _RegistrationModalWidgetState extends State<RegistrationModalWidget>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// Background gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8C5FF5), Color(0xFF5A2EE8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        /// Centered modal card
        child: Center(
          child: Opacity(
            opacity: 0.6,
            child: Container(
              width: 440.w,
              padding: EdgeInsets.all(30.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Title
                        Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 38.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 30.h),

                        /// Form Section
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email Field
                              _buildInputField(
                                label: "Email",
                                icon: Icons.email_outlined,
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  final emailRegex = RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  );
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Invalid email address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.h),

                              // Password Field
                              _buildInputField(
                                label: "Password",
                                icon: Icons.lock_outline,
                                controller: _passwordController,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (value.length < 6) {
                                    return 'Min 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.h),

                              // Confirm Password Field
                              _buildInputField(
                                label: "Confirm Password",
                                icon: Icons.verified_user_outlined,
                                controller: _confirmPasswordController,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 40.h),

                              /// Register Button
                              _buildPrimaryButton(
                                label: "Register",
                                onPressed: _handleNext,
                              ),

                              SizedBox(height: 20.h),

                              /// Already have account
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "Already have an account? Log in",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// -------------------------------
  /// 🧩 Helper Widgets
  /// -------------------------------

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          shadowColor: Colors.black.withOpacity(0.3),
          elevation: 8,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
