import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_vps/controllers/attendance_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ViewAttendanceScreen extends StatefulWidget {
  const ViewAttendanceScreen({super.key});

  @override
  State<ViewAttendanceScreen> createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  final AttendanceController _controller = AttendanceController();
  List<Map<String, dynamic>> attendanceList = [];
  Map<String, dynamic> stats = {};
  bool isLoading = true;
  String? studentId;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get student ID
      final studentsQuery = await FirebaseFirestore.instance
          .collection('Students')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (studentsQuery.docs.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      studentId = studentsQuery.docs.first.id;

      // Get attendance and stats
      attendanceList = await _controller.getStudentAttendance(studentId!);
      stats = await _controller.getAttendanceStats(studentId!);

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading attendance: $e')),
        );
      }
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: isMobile ? screenWidth * 0.9 : 700.w,
        height: isMobile ? MediaQuery.of(context).size.height * 0.8 : 600.h,
        padding: EdgeInsets.all(isMobile ? 20 : 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: isMobile ? 28 : 28.sp,
                  color: Colors.blue,
                ),
                SizedBox(width: isMobile ? 10 : 10.w),
                Text(
                  'My Attendance',
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, size: isMobile ? 28 : 24),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20.h),

            // Stats Card
            if (!isLoading && stats.isNotEmpty) _buildStatsCard(),

            SizedBox(height: 20.h),

            // Attendance List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : attendanceList.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: attendanceList.length,
                          itemBuilder: (context, index) {
                            final attendance = attendanceList[index];
                            return _buildAttendanceCard(attendance);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;
    final percentage = stats['percentage'] ?? 0.0;
    final presentDays = stats['presentDays'] ?? 0;
    final totalDays = stats['totalDays'] ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20.w),
        child: Row(
          children: [
            // Circular progress
            SizedBox(
              width: isMobile ? 100 : 80.w,
              height: isMobile ? 100 : 80.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: isMobile ? 10 : 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage >= 75
                          ? Colors.green
                          : percentage >= 50
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                  Center(
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isMobile ? 16 : 20.w),

            // Stats details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Summary',
                    style: TextStyle(
                      fontSize: isMobile ? 17 : 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 8.h),
                  Text(
                    'Present: $presentDays days',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 14.sp,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Absent: ${stats['absentDays']} days',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 14.sp,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    'Total: $totalDays days',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: isMobile ? 80 : 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: isMobile ? 16 : 16.h),
            Text(
              'No attendance records',
              style: TextStyle(
                fontSize: isMobile ? 18 : 18.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 8.h),
            Text(
              'Your attendance will appear here',
              style: TextStyle(
                fontSize: isMobile ? 14 : 14.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> attendance) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;
    final status = attendance['status'] ?? 'absent';
    final isPresent = status == 'present';

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 16.w),
        child: Row(
          children: [
            // Status icon
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 8.w),
              decoration: BoxDecoration(
                color: isPresent ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                isPresent ? Icons.check_circle : Icons.cancel,
                color: isPresent ? Colors.green : Colors.red,
                size: isMobile ? 26 : 24.sp,
              ),
            ),
            SizedBox(width: isMobile ? 14 : 16.w),

            // Date and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(attendance['date']),
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isMobile ? 4 : 4.h),
                  Text(
                    'Marked by: ${attendance['markedByName']}',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Status badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 12.w,
                vertical: isMobile ? 6 : 6.h,
              ),
              decoration: BoxDecoration(
                color: isPresent ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                isPresent ? 'PRESENT' : 'ABSENT',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
