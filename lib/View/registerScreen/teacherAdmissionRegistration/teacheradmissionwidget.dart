// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../controller/DesktopControllers/teacher_register_controller.dart';
import '../../customwidgets/primarybuttonwidget.dart';

class TeacherAdmissionPage extends StatefulWidget {
  final String initialEmail;
  final String initialPassword;

  const TeacherAdmissionPage({
    super.key,
    required this.initialEmail,
    required this.initialPassword,
  });

  @override
  State<TeacherAdmissionPage> createState() => _TeacherAdmissionPageState();
}

class _TeacherAdmissionPageState extends State<TeacherAdmissionPage> {
  late TeacherAdmissionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TeacherAdmissionController();
    _controller.init(widget.initialEmail, widget.initialPassword);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    filled: true,
    fillColor: Colors.white.withOpacity(0.15),
    labelStyle: const TextStyle(color: Colors.white70),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white, width: 1.5),
      borderRadius: BorderRadius.circular(12),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8C5FF5), Color(0xFFB79DFF), Color(0xFF9A84E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: duplicate_ignore
                        // ignore:
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: -4,
                        offset: const Offset(-5, -5),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 25,
                        spreadRadius: 4,
                        offset: const Offset(6, 6),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _controller.formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Teacher Admission Application",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Full Name
                        TextFormField(
                          controller: _controller.nameController,
                          validator: _controller.requiredValidator,
                          decoration: _inputDecoration("Full Name"),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _controller.emailController,
                          validator: _controller.emailValidator,
                          decoration: _inputDecoration("Email"),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        TextFormField(
                          controller: _controller.phoneController,
                          validator: _controller.requiredValidator,
                          decoration: _inputDecoration("Phone Number"),
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),

                        // Qualification
                        TextFormField(
                          controller: _controller.qualificationController,
                          validator: _controller.requiredValidator,
                          decoration: _inputDecoration("Qualification"),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),

                        // Experience
                        TextFormField(
                          controller: _controller.experienceController,
                          validator: _controller.requiredValidator,
                          decoration: _inputDecoration("Experience"),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),

                        // Subjects
                        TextFormField(
                          controller: _controller.subjectsController,
                          validator: _controller.requiredValidator,
                          decoration: _inputDecoration(
                            "Subject Specialization",
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),

                        // Address
                        TextFormField(
                          controller: _controller.addressController,
                          validator: _controller.requiredValidator,
                          decoration: _inputDecoration("Address"),
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 24),

                        // Upload CV
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Upload CV",
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                await _controller.pickCV(context);
                                setState(() {});
                              },
                              icon: const Icon(Icons.upload_file),
                              label: const Text("Select CV"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.25),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                shadowColor: Colors.white.withOpacity(0.3),
                                elevation: 4,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _controller.cvFileName ?? "No file selected",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Submit Button
                        Center(
                          child: Primarybuttonwidget(
                            input: "Submit Application",
                            run: () => _controller.submit(context),
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
}
