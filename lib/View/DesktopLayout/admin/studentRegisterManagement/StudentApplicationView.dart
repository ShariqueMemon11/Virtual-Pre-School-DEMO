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
    setState(() {
      status = newStatus;
    });

    try {
      await FirebaseFirestore.instance
          .collection('student applications')
          .doc(widget.documentId)
          .update({'approval': newStatus});
    } catch (e) {
      print("Error updating Firestore: $e");
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Application marked as $newStatus")));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.orange;
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
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: ListView(
          children: [
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
                backgroundColor: _getStatusColor(status).withOpacity(0.15),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              ),
            ),
            SizedBox(height: 20.h),

            // Child Info
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

            // Parent Info
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

            // Application Info
            _infoCard("Application Info", [
              _detailRow(Icons.email, "Email", app["email"] ?? "N/A"),
              _detailRow(
                Icons.family_restroom,
                "Other Family Members",
                (app["otherFamilyMembers"] ?? "None").toString(),
              ),
              _detailRow(
                Icons.verified,
                "Policy Accepted",
                app["policyAccepted"] ?? "false",
              ),
              _detailRow(Icons.timer, "Created At", app["createdAt"] ?? "N/A"),
            ]),
            SizedBox(height: 30.h),

            // Buttons
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
        elevation: 4,
      ),
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
