import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GradesModal extends StatefulWidget {
  const GradesModal({super.key});

  @override
  State<GradesModal> createState() => _GradesModalState();
}

class _GradesModalState extends State<GradesModal> {
  late Future<List<Map<String, dynamic>>> _gradesFuture;

  @override
  void initState() {
    super.initState();
    _gradesFuture = _fetchStudentGrades();
  }

  Future<List<Map<String, dynamic>>> _fetchStudentGrades() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final gradesSnap =
        await FirebaseFirestore.instance
            .collection('grades')
            .where('studentUid', isEqualTo: user.uid)
            .get();
    return gradesSnap.docs.map((d) {
      final data = d.data();
      return {
        'subjectName': data['subject'] ?? '',
        'teacherName': data['teacherName'] ?? '',
        'gradeStr': data['grade'],
        'percentage': _convertGradeToPercent(data['grade']),
      };
    }).toList();
  }

  double _convertGradeToPercent(dynamic grade) {
    // If teachers enter a number (75), use that.
    if (grade is num) return grade.toDouble();
    if (grade is String && double.tryParse(grade) != null) {
      return double.parse(grade);
    }
    // If teachers enter letters (A, B+ etc), set mapping here:
    switch (grade.toString().trim().toUpperCase()) {
      case 'A+':
        return 97;
      case 'A':
        return 94;
      case 'A-':
        return 90;
      case 'B+':
        return 87;
      case 'B':
        return 83;
      case 'B-':
        return 80;
      case 'C+':
        return 77;
      case 'C':
        return 73;
      case 'C-':
        return 70;
      case 'D+':
        return 67;
      case 'D':
        return 63;
      case 'D-':
        return 60;
      default:
        return 0; // Or null/skip
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: 600.w,
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.grade, size: 28.sp, color: Colors.orange),
                SizedBox(width: 10.w),
                Text(
                  'My Grades',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Content
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _gradesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return _buildEmptyState();
                }
                final grades = snapshot.data ?? [];
                if (grades.isEmpty) return _buildEmptyState();
                return Column(
                  children: grades.map((g) => _buildSubjectCard(g)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'No grades available yet',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your grades will appear here once teachers start grading',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final double percentage = subject['percentage'] ?? 0.0;
    final String gradeStr = subject['gradeStr']?.toString() ?? '';
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject['subjectName'],
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Teacher: ${subject['teacherName']}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  if (gradeStr.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        'Grade: $gradeStr',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 20.w),
            _buildPercentageCircle(percentage),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageCircle(double percentage) {
    final String letterGrade = _getLetterGrade(percentage);

    return SizedBox(
      width: 80.w,
      height: 80.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 8,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  letterGrade,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLetterGrade(double percentage) {
    if (percentage >= 97) return 'A+';
    if (percentage >= 93) return 'A';
    if (percentage >= 90) return 'A-';
    if (percentage >= 87) return 'B+';
    if (percentage >= 83) return 'B';
    if (percentage >= 80) return 'B-';
    if (percentage >= 77) return 'C+';
    if (percentage >= 73) return 'C';
    if (percentage >= 70) return 'C-';
    if (percentage >= 67) return 'D+';
    if (percentage >= 63) return 'D';
    if (percentage >= 60) return 'D-';
    return 'F';
  }
}
