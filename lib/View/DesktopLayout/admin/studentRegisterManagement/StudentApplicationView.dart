import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentApplicationDetailScreen extends StatefulWidget {
  final Map<String, String> application;

  const StudentApplicationDetailScreen({super.key, required this.application});

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
    status = widget.application["status"] ?? "Pending";
  }

  void _updateStatus(String newStatus) {
    setState(() {
      status = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Application ${newStatus.toLowerCase()}!"),
        duration: const Duration(seconds: 2),
      ),
    );
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
            // Status Badge
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

            // Child Info Card
            _infoCard("Child's Details", [
              _detailRow(Icons.person, "Name", widget.application["name"]!),
              _detailRow(
                Icons.school,
                "Class Applied",
                widget.application["class"]!,
              ),
              _detailRow(Icons.cake, "Date of Birth", "15 Jan 2020"),
              _detailRow(Icons.male, "Gender", "Male"),
            ]),
            SizedBox(height: 16.h),

            // Parent Info Card
            _infoCard("Parent's Details", [
              _detailRow(
                Icons.person_outline,
                "Father's Name",
                "Muhammad Raza",
              ),
              _detailRow(Icons.person_outline, "Mother's Name", "Ayesha Raza"),
              _detailRow(Icons.phone, "Contact Number", "+92 300 1234567"),
              _detailRow(Icons.home, "Address", "123 Main Street, Lahore"),
            ]),
            SizedBox(height: 16.h),

            // Application Info Card
            _infoCard("Application Info", [
              _detailRow(Icons.info, "Application Status", status),
              _detailRow(
                Icons.calendar_today,
                "Date Applied",
                widget.application["date"]!,
              ),
            ]),
            SizedBox(height: 30.h),

            // Action Buttons
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
            SizedBox(height: 6.h),
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
