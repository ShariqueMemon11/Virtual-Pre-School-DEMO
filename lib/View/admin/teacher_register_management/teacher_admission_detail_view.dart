// lib/view/DesktopView/Admin/teacher_admission_detail_view.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../Model/teacher_admission_model.dart';
import '../../../controllers/teacher_register_controller.dart';
import '../../../utils/responsive_helper.dart';

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
        title: Text(
          ResponsiveHelper.isMobile(context) ? "Application" : "Teacher Application",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: ResponsiveHelper.fontSize(context, 20),
          ),
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
          padding: EdgeInsets.all(ResponsiveHelper.padding(context, 24)),
          child: Card(
            elevation: 6,
            shadowColor: Colors.deepPurple.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.padding(context, 24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Teacher Application Details",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(context, 22),
                      fontWeight: FontWeight.bold,
                      color: deepPurple,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(context, 20)),
                  _infoTable(context),

                  SizedBox(height: ResponsiveHelper.spacing(context, 20)),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: deepPurple,
                        size: ResponsiveHelper.fontSize(context, 18),
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(context, 6)),
                      Expanded(
                        child: Text(
                          "Submitted on: ${application.createdAt.toDate()}",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: ResponsiveHelper.fontSize(context, 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(context, 30)),

                  if (cvBytes != null)
                    _primaryButton(
                      context,
                      icon: Icons.download,
                      label: "Download CV",
                      color: deepPurple,
                      onPressed: () => controller.downloadFile(context),
                    ),

                  SizedBox(height: ResponsiveHelper.spacing(context, 20)),
                  ResponsiveHelper.isMobile(context)
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: _primaryButton(
                                context,
                                icon: Icons.check_circle,
                                label: "Accept",
                                color: Colors.green,
                                onPressed:
                                    () => controller.acceptApplication(context),
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.spacing(context, 16)),
                            SizedBox(
                              width: double.infinity,
                              child: _primaryButton(
                                context,
                                icon: Icons.cancel,
                                label: "Reject",
                                color: Colors.red,
                                onPressed:
                                    () => controller.rejectApplication(context),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _primaryButton(
                                context,
                                icon: Icons.check_circle,
                                label: "Accept",
                                color: Colors.green,
                                onPressed:
                                    () => controller.acceptApplication(context),
                              ),
                            ),
                            SizedBox(width: ResponsiveHelper.spacing(context, 16)),
                            Expanded(
                              child: _primaryButton(
                                context,
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
  Widget _infoTable(BuildContext context) {
    return Table(
      columnWidths: const {0: FlexColumnWidth(0.35), 1: FlexColumnWidth(0.65)},
      border: TableBorder.all(
        color: Colors.deepPurple.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        _tableRow(context, Icons.person, "Name", application.name),
        _tableRow(context, Icons.email, "Email", application.email),
        _tableRow(context, Icons.phone, "Phone", application.phone),
        _tableRow(context, Icons.school, "Qualification", application.qualification),
        _tableRow(context, Icons.work, "Experience", application.experience),
        _tableRow(context, Icons.book, "Expertise", application.expertise),
        _tableRow(context, Icons.home, "Address", application.address),
      ],
    );
  }

  TableRow _tableRow(BuildContext context, IconData icon, String label, String value) {
    const Color deepPurple = Color(0xFF5B3DC7);
    return TableRow(
      children: [
        Container(
          color: Colors.grey[50],
          padding: EdgeInsets.all(ResponsiveHelper.padding(context, 10)),
          child: Row(
            children: [
              Icon(
                icon,
                color: deepPurple,
                size: ResponsiveHelper.fontSize(context, 20),
              ),
              SizedBox(width: ResponsiveHelper.spacing(context, 8)),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: deepPurple,
                    fontSize: ResponsiveHelper.fontSize(context, 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(ResponsiveHelper.padding(context, 10)),
          child: Text(
            value.isEmpty ? "N/A" : value,
            style: TextStyle(
              color: Colors.black87,
              fontSize: ResponsiveHelper.fontSize(context, 14),
            ),
          ),
        ),
      ],
    );
  }

  /// 🔘 Styled Button
  Widget _primaryButton(
    BuildContext context, {
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
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: ResponsiveHelper.fontSize(context, 16),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.padding(context, 14),
          horizontal: ResponsiveHelper.padding(context, 8),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
      ),
    );
  }
}
