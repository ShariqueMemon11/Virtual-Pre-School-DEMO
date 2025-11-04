// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../controllers/student_application_controller.dart';
import '../../custom_widgets/uploadfilewidget.dart';

class StudentRegistrationForm extends StatefulWidget {
  final String initialEmail;
  final String initialPassword;

  const StudentRegistrationForm({
    super.key,
    required this.initialEmail,
    required this.initialPassword,
  });

  @override
  State<StudentRegistrationForm> createState() =>
      _StudentRegistrationFormState();
}

class _StudentRegistrationFormState extends State<StudentRegistrationForm> {
  late final StudentRegistrationController controller;

  @override
  void initState() {
    super.initState();
    controller = StudentRegistrationController();
    controller.init(widget.initialEmail, widget.initialPassword);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2015),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => controller.setDate(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8C5FF5), Color.fromARGB(255, 156, 129, 219)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.65,
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Student Registration",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Student Info
                    TextFormField(
                      controller: controller.nameController,
                      decoration: const InputDecoration(
                        labelText: "Name of Student",
                      ),
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.ageController,
                      decoration: const InputDecoration(labelText: "Age"),
                      keyboardType: TextInputType.number,
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Date of Birth",
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text:
                                controller.selectedDate == null
                                    ? ""
                                    : "${controller.selectedDate!.month}/${controller.selectedDate!.day}/${controller.selectedDate!.year}",
                          ),
                          validator:
                              (_) =>
                                  controller.selectedDate == null
                                      ? "Required"
                                      : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.homePhoneController,
                      decoration: const InputDecoration(
                        labelText: "Home Phone Number",
                      ),
                      keyboardType: TextInputType.phone,
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.emailController,
                      decoration: const InputDecoration(
                        labelText: "Parents Email Address",
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Mother's Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.motherNameController,
                      decoration: const InputDecoration(
                        labelText: "Mother's Name",
                      ),
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.motherIdController,
                      decoration: const InputDecoration(
                        labelText: "Mother CNIC",
                      ),
                      keyboardType: TextInputType.phone,
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.motherOccupationController,
                      decoration: const InputDecoration(
                        labelText: "Mother Occupation",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.motherCellController,
                      decoration: const InputDecoration(
                        labelText: "Mother Cell Phone",
                      ),
                      keyboardType: TextInputType.phone,
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Father's Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.fatherNameController,
                      decoration: const InputDecoration(
                        labelText: "Father's Name",
                      ),
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.fatherIdController,
                      decoration: const InputDecoration(
                        labelText: "Father CNIC",
                      ),
                      keyboardType: TextInputType.phone,
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.fatherOccupationController,
                      decoration: const InputDecoration(
                        labelText: "Father Occupation",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.fatherCellController,
                      decoration: const InputDecoration(
                        labelText: "Father Cell Phone",
                      ),
                      keyboardType: TextInputType.phone,
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Other Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    for (int i = 0; i < 2; i++)
                      TextFormField(
                        controller: controller.familyControllers[i],
                        decoration: InputDecoration(
                          labelText: "Other family member ${i + 1} (optional)",
                        ),
                      ),
                    TextFormField(
                      controller: controller.specialEquipmentController,
                      decoration: const InputDecoration(
                        labelText: "Special Equipment (optional)",
                      ),
                    ),
                    TextFormField(
                      controller: controller.allergiesController,
                      decoration: const InputDecoration(labelText: "Allergies"),
                    ),
                    TextFormField(
                      controller: controller.behavioralController,
                      decoration: const InputDecoration(
                        labelText: "Behavioral/Mental Health Issues",
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Documents",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 📌 Mother CNIC
                    const Text(
                      "Upload Mother CNIC",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    UploadFileWidget(
                      fileName: controller.motherCnicFileName,
                      onFilePicked: (base64, name) {
                        setState(() {
                          controller.motherCnicFile = base64;
                          controller.motherCnicFileName = name;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // 📌 Father CNIC
                    const Text(
                      "Upload Father CNIC",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    UploadFileWidget(
                      fileName: controller.fatherCnicFileName,
                      onFilePicked: (base64, name) {
                        setState(() {
                          controller.fatherCnicFile = base64;
                          controller.fatherCnicFileName = name;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Upload Child's Photo",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    UploadFileWidget(
                      fileName: controller.childPhotoFileName,
                      onFilePicked: (base64, name) {
                        setState(() {
                          controller.childPhotoFile = base64;
                          controller.childPhotoFileName = name;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // 📌 Child Birth Certificate
                    const Text(
                      "Upload Child Birth Certificate",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    UploadFileWidget(
                      fileName: controller.birthCertificateFileName,
                      onFilePicked: (base64, name) {
                        setState(() {
                          controller.birthCertificateFile = base64;
                          controller.birthCertificateFileName = name;
                        });
                      },
                    ),

                    const SizedBox(height: 24),
                    CheckboxListTile(
                      value: controller.policyAccepted,
                      onChanged:
                          (v) => setState(
                            () => controller.policyAccepted = v ?? false,
                          ),
                      title: const Text(
                        "I accept all the policies and grant permission...",
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),

                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => controller.submit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            179,
                            208,
                            208,
                            208,
                          ),
                        ),
                        child: const Text("Submit Registration"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
