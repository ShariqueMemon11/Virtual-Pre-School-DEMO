// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../Model/teacher_admission_model.dart';

class TeacherAdmissionDetailView extends StatelessWidget {
  final TeacherAdmissionModel application;

  const TeacherAdmissionDetailView({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    const Color lightPurple = Color(0xFFEDE7F6);
    const Color deepPurple = Color(0xFF512DA8);

    Uint8List? cvBytes;
    try {
      cvBytes = base64Decode(application.cvBase64);
    } catch (_) {
      cvBytes = null;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: lightPurple,
        title: Text(
          application.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          color: lightPurple.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Teacher Application Details",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: deepPurple,
                  ),
                ),
                const SizedBox(height: 20),

                // 🧾 Table layout
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(0.35),
                    1: FlexColumnWidth(0.65),
                  },
                  border: TableBorder.all(
                    color: deepPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  children: [
                    tableRow(Icons.person, "Name", application.name),
                    tableRow(Icons.email, "Email", application.email),
                    tableRow(Icons.phone, "Phone", application.phone),
                    tableRow(
                      Icons.school,
                      "Qualification",
                      application.qualification,
                    ),
                    tableRow(Icons.work, "Experience", application.experience),
                    tableRow(Icons.book, "Subjects", application.subjects),
                    tableRow(Icons.home, "Address", application.address),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  "Submitted on: ${application.createdAt.toDate()}",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),

                const SizedBox(height: 30),

                // 📄 Download Button
                if (cvBytes != null)
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _downloadCV(cvBytes!, application.name);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✅ CV downloaded successfully!"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text(
                      "Download CV (PDF)",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deepPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                else
                  const Text(
                    "No CV file found.",
                    style: TextStyle(color: Colors.redAccent),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🧱 Table Row Widget
  TableRow tableRow(IconData icon, String label, String value) {
    const Color deepPurple = Color(0xFF512DA8);
    return TableRow(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(icon, color: deepPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: deepPurple,
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10),
          child: Text(
            value.isEmpty ? "N/A" : value,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  /// 💾 Decode Base64 → Save as PDF
  Future<void> _downloadCV(Uint8List bytes, String name) async {
    // Create a safe file name (remove spaces/special chars)
    final safeName = name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_');
    final file = File("$safeName-CV.pdf");

    await file.writeAsBytes(bytes);
  }
}
