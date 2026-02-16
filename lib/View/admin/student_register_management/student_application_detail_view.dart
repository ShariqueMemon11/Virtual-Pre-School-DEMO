// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentApplicationDetailScreen extends StatefulWidget {
  final Map<String, String> application;
  final String documentId;

  const StudentApplicationDetailScreen({
    super.key,
    required this.application,
    required this.documentId,
  });

  @override
  State<StudentApplicationDetailScreen> createState() =>
      _StudentApplicationDetailScreenState();
}

class _StudentApplicationDetailScreenState
    extends State<StudentApplicationDetailScreen> {
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.application["approval"] ?? "Pending";
  }

  // ✅ Update status
  Future<void> _updateStatus(String newStatus) async {
    setState(() => status = newStatus);

    final firestore = FirebaseFirestore.instance;
    final docRef = firestore
        .collection('student applications')
        .doc(widget.documentId);

    try {
      await docRef.update({'approval': newStatus});

      if (newStatus == "Approved") {
        final snap = await docRef.get();
        final data = snap.data();

        if (data != null) {
          await firestore.collection('Students').doc(widget.documentId).set({
            ...data,
            'role': 'student',
            'approvedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Application marked as $newStatus")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    }
  }

  // ✅ Status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // ✅ WEB DOWNLOAD
  void _downloadDocument(String base64File, String title) {
    try {
      String base64Str = base64File;

      if (base64Str.contains(',')) {
        base64Str = base64Str.split(',').last;
      }

      final bytes = base64Decode(base64Str);

      final isPDF = base64Str.trim().startsWith("JVBER");
      final extension = isPDF ? "pdf" : "png";

      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final studentName = widget.application["childName"] ?? "student";

      final anchor =
          html.AnchorElement(href: url)
            ..download = "${studentName}_$title.$extension"
            ..style.display = 'none';

      html.document.body!.children.add(anchor);
      anchor.click();
      anchor.remove();

      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$title downloaded")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Application Details",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 156, 129, 219),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // ✅ header icon (no photo)

          // ✅ status chip
          SizedBox(height: 20.h),

          _infoCard("Child Details", [
            _detailRow(Icons.person, "Name", app["childName"] ?? "N/A"),
            _detailRow(
              Icons.cake,
              "Date of Birth",
              app["dateOfBirth"]?.split("T").first ?? "N/A",
            ),
            _detailRow(Icons.person_pin, "Age", app["age"] ?? "N/A"),
            _detailRow(Icons.healing, "Allergies", app["allergies"] ?? "N/A"),
            _detailRow(
              Icons.accessibility,
              "Special Equipment",
              app["specialEquipment"] ?? "N/A",
            ),
          ]),
          SizedBox(height: 16.h),

          _infoCard("Father's Details", [
            _detailRow(Icons.person, "Name", app["fatherName"] ?? "N/A"),
            _detailRow(
              Icons.work,
              "Occupation",
              app["fatherOccupation"] ?? "N/A",
            ),
            _detailRow(Icons.phone, "Phone", app["fatherCell"] ?? "N/A"),
          ]),
          SizedBox(height: 16.h),

          _infoCard("Mother's Details", [
            _detailRow(Icons.person, "Name", app["motherName"] ?? "N/A"),
            _detailRow(
              Icons.work,
              "Occupation",
              app["motherOccupation"] ?? "N/A",
            ),
            _detailRow(Icons.phone, "Phone", app["motherCell"] ?? "N/A"),
          ]),
          SizedBox(height: 16.h),

          // ✅ DOWNLOAD BUTTONS
          _infoCard("Documents", [
            _docButton("Mother_CNIC", app["motherCnicFile"]),
            _docButton("Father_CNIC", app["fatherCnicFile"]),
            _docButton("Birth_Certificate", app["birthCertificateFile"]),
          ]),
          SizedBox(height: 16.h),

          _infoCard("Application Info", [
            _detailRow(Icons.email, "Email", app["email"] ?? "N/A"),
            _detailRow(
              Icons.family_restroom,
              "Other Family Members",
              app["otherFamilyMembers"] ?? "None",
            ),
            _detailRow(
              Icons.verified,
              "Policy Accepted",
              app["policyAccepted"] ?? "false",
            ),
          ]),
          SizedBox(height: 30.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(
                label: "Approve",
                color: Colors.green,
                icon: Icons.check,
                onTap: () => _updateStatus("Approved"),
              ),
              _actionButton(
                label: "Reject",
                color: Colors.red,
                icon: Icons.close,
                onTap: () => _updateStatus("Rejected"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- UI ----------

  Widget _docButton(String label, String? file) {
    final hasFile = file != null && file.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              hasFile ? const Color.fromARGB(255, 156, 129, 219) : Colors.grey,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: hasFile ? () => _downloadDocument(file, label) : null,
        icon: const Icon(Icons.download, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.grey[300]),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color.fromARGB(255, 156, 129, 219),
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text("$label: $value", style: TextStyle(fontSize: 15.sp)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
