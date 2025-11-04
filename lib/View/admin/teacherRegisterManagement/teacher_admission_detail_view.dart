// lib/view/DesktopView/Admin/teacher_admission_detail_view.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../Model/teacher_admission_model.dart';
import '../../../../controller/DesktopControllers/teacher_register_controller.dart';

class TeacherAdmissionDetailView extends StatelessWidget {
  final TeacherAdmissionModel application;

  const TeacherAdmissionDetailView({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final controller = TeacherAdmissionDetailController(application);
    const Color deepPurple = Color(0xFF5B3DC7);

    Uint8List? cvBytes;
    try {
      cvBytes = base64Decode(application.cvBase64);
    } catch (_) {
      cvBytes = null;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Teacher Application",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7E57C2), Color(0xFF512DA8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shadowColor: Colors.deepPurple.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                  _infoTable(),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: deepPurple,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Submitted on: ${application.createdAt.toDate()}",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  if (cvBytes != null)
                    _primaryButton(
                      icon: Icons.download,
                      label: "Download CV",
                      color: deepPurple,
                      onPressed: () => controller.downloadFile(context),
                    ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _primaryButton(
                          icon: Icons.check_circle,
                          label: "Accept",
                          color: Colors.green,
                          onPressed:
                              () => controller.acceptApplication(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _primaryButton(
                          icon: Icons.cancel,
                          label: "Reject",
                          color: Colors.red,
                          onPressed:
                              () => controller.rejectApplication(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 📋 Info Table
  Widget _infoTable() {
    return Table(
      columnWidths: const {0: FlexColumnWidth(0.35), 1: FlexColumnWidth(0.65)},
      border: TableBorder.all(
        color: Colors.deepPurple.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        _tableRow(Icons.person, "Name", application.name),
        _tableRow(Icons.email, "Email", application.email),
        _tableRow(Icons.phone, "Phone", application.phone),
        _tableRow(Icons.school, "Qualification", application.qualification),
        _tableRow(Icons.work, "Experience", application.experience),
        _tableRow(Icons.book, "Subjects", application.subjects),
        _tableRow(Icons.home, "Address", application.address),
      ],
    );
  }

  TableRow _tableRow(IconData icon, String label, String value) {
    const Color deepPurple = Color(0xFF5B3DC7);
    return TableRow(
      children: [
        Container(
          color: Colors.grey[50],
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

  /// 🔘 Styled Button
  Widget _primaryButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
      ),
    );
  }
}
