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

    // Try to determine the student's current class so we only show grades
    // for the class the student is in right now.
    final classInfo = await _fetchStudentClassInfo(user.email);
    final classId = classInfo['classId'];
    final className = classInfo['className'];

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('grades')
        .where('studentUid', isEqualTo: user.uid);

    if (classId != null && classId.isNotEmpty) {
      query = query.where('classId', isEqualTo: classId);
    } else if (className != null && className.isNotEmpty) {
      // Fallback: filter by class name if classId not available.
      query = query.where('class', isEqualTo: className);
    }

    final gradesSnap = await query.get();
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

  /// Fetch the student's current class info (classId / className) so we can
  /// filter grades to the active class only.
  Future<Map<String, String?>> _fetchStudentClassInfo(String? email) async {
    if (email == null || email.isEmpty) {
      return {'classId': null, 'className': null};
    }

    // First, look in Students collection.
    final studentsQuery =
        await FirebaseFirestore.instance
            .collection('Students')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (studentsQuery.docs.isNotEmpty) {
      final data = studentsQuery.docs.first.data();
      return {
        'classId':
            (data['assignedClassId'] ?? data['assignedClass'])?.toString(),
        'className':
            (data['assignedClass'] ?? data['className'] ?? data['class'])
                ?.toString(),
      };
    }

    // Fallback: check student applications collection.
    final applicationsQuery =
        await FirebaseFirestore.instance
            .collection('student applications')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (applicationsQuery.docs.isNotEmpty) {
      final data = applicationsQuery.docs.first.data();
      return {
        'classId':
            (data['assignedClassId'] ?? data['assignedClass'])?.toString(),
        'className':
            (data['assignedClass'] ?? data['className'] ?? data['class'])
                ?.toString(),
      };
    }

    return {'classId': null, 'className': null};
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: isMobile ? screenWidth * 0.9 : 600.w,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: EdgeInsets.all(isMobile ? 20 : 20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.grade, size: isMobile ? 28 : 28.sp, color: Colors.orange),
                SizedBox(width: isMobile ? 10 : 10.w),
                Text(
                  'My Grades',
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

            // Content
            Flexible(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _gradesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return _buildEmptyState();
                  }
                  final grades = snapshot.data ?? [];
                  if (grades.isEmpty) return _buildEmptyState();
                  return ListView(
                    shrinkWrap: true,
                    children: grades.map((g) => _buildSubjectCard(g)).toList(),
                  );
                },
              ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;
    final double percentage = subject['percentage'] ?? 0.0;
    final String gradeStr = subject['gradeStr']?.toString() ?? '';
    
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16.h),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject['subjectName'],
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: isMobile ? 6 : 8.h),
                  Text(
                    'Teacher: ${subject['teacherName']}',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (gradeStr.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: isMobile ? 4 : 6.h),
                      child: Text(
                        'Grade: $gradeStr',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 13.sp,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: isMobile ? 12 : 20.w),
            _buildPercentageCircle(percentage),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageCircle(double percentage) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;
    final String letterGrade = _getLetterGrade(percentage);

    return SizedBox(
      width: isMobile ? 70 : 80.w,
      height: isMobile ? 70 : 80.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: isMobile ? 7 : 8,
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
                    fontSize: isMobile ? 16 : 18.sp,
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
