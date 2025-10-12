// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';
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

  Future<void> _updateStatus(String newStatus) async {
    setState(() => status = newStatus);
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore
        .collection('student applications')
        .doc(widget.documentId);

    try {
      await docRef.update({'approval': newStatus});

      if (newStatus == "Approved") {
        final docSnapshot = await docRef.get();
        final data = docSnapshot.data();

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
      ).showSnackBar(SnackBar(content: Text("Failed to update: $e")));
    }
  }

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

  // 🧩 Decode base64 string safely
  ImageProvider? _decodeBase64Image(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) return null;
    try {
      if (base64Str.contains(',')) {
        base64Str = base64Str.split(',').last;
      }
      Uint8List bytes = base64Decode(base64Str);
      return MemoryImage(bytes);
    } catch (e) {
      debugPrint("Image decode error: $e");
      return null;
    }
  }

  // 📄 Opens document viewer
  void _openDocumentViewer(String base64File, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => DocumentViewerScreen(base64File: base64File, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final childPhoto = _decodeBase64Image(app["childPhotoFile"]);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Application Details",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 156, 129, 219),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // 🧒 Child Photo
          if (childPhoto != null)
            Center(
              child: CircleAvatar(backgroundImage: childPhoto, radius: 60.w),
            )
          else
            Center(
              child: CircleAvatar(
                radius: 60.w,
                backgroundColor: const Color.fromARGB(
                  255,
                  156,
                  129,
                  219,
                  // ignore: deprecated_member_use
                ).withOpacity(0.3),
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
          SizedBox(height: 10.h),

          // Status chip
          Center(
            child: Chip(
              avatar: Icon(
                status == "Approved"
                    ? Icons.check_circle
                    : status == "Rejected"
                    ? Icons.cancel
                    : Icons.hourglass_empty,
                color: _getStatusColor(status),
              ),
              label: Text(
                status,
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
              // ignore: deprecated_member_use
              backgroundColor: _getStatusColor(status).withOpacity(0.15),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            ),
          ),
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

          _infoCard("Documents", [
            _docButton("Mother CNIC", app["motherCnicFile"]),
            _docButton("Father CNIC", app["fatherCnicFile"]),
            _docButton("Birth Certificate", app["birthCertificateFile"]),
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

          // Action buttons
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
        onPressed: hasFile ? () => _openDocumentViewer(file, label) : null,
        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
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
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Divider(thickness: 1, color: Colors.grey[300]),
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
            child: Text(
              "$label: $value",
              style: TextStyle(fontSize: 15.sp, color: Colors.black87),
            ),
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

class DocumentViewerScreen extends StatelessWidget {
  final String base64File;
  final String title;

  const DocumentViewerScreen({
    super.key,
    required this.base64File,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    Uint8List bytes;
    String base64Str = base64File;
    if (base64Str.contains(',')) base64Str = base64Str.split(',').last;
    bytes = base64Decode(base64Str);

    // Check if it's a PDF or image
    final isPDF = base64Str.trim().startsWith("JVBER");

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 156, 129, 219),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          isPDF
              ? Center(child: Text("📄 PDF viewer to be implemented here"))
              : Center(child: Image.memory(bytes, fit: BoxFit.contain)),
    );
  }
}
