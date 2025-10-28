import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../data/grades_repository.dart';

class GradesModal extends StatefulWidget {
  const GradesModal({super.key});

  @override
  State<GradesModal> createState() => _GradesModalState();
}

class _GradesModalState extends State<GradesModal> {
  late Future<List<SubjectGrade>> _gradesFuture;

  @override
  void initState() {
    super.initState();
    _gradesFuture = GradesRepository.fetchGrades();
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
            FutureBuilder<List<SubjectGrade>>(
              future: _gradesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _buildEmptyState();
                }
                final subjects = snapshot.data!;
                if (subjects.isEmpty) return _buildEmptyState();
                return Column(
                  children:
                      subjects
                          .map(
                            (s) => _buildSubjectCard({
                              'subjectName': s.subjectName,
                              'teacherName': s.teacherName,
                              'averageGrade': s.averageGrade,
                            }),
                          )
                          .toList(),
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
    final double averageGrade = subject['averageGrade'] as double;

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
                ],
              ),
            ),
            SizedBox(width: 20.w),
            // Percentage Circle
            _buildPercentageCircle(averageGrade),
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
