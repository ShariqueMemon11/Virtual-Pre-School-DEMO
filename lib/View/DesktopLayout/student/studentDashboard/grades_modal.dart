import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GradesModal extends StatefulWidget {
  const GradesModal({super.key});

  @override
  State<GradesModal> createState() => _GradesModalState();
}

class _GradesModalState extends State<GradesModal> {
  // Dummy data for grades
  final List<Map<String, dynamic>> subjects = [
    {
      'subjectName': 'Mathematics',
      'teacherName': 'Ms. Sarah Johnson',
      'totalAssignments': 8,
      'completedAssignments': 7,
      'averageGrade': 85.5,
      'assignments': [
        {
          'title': 'Algebra Basics',
          'grade': 88,
          'maxGrade': 100,
          'submittedDate': '2024-01-15',
          'feedback': 'Excellent work! Keep practicing quadratic equations.',
        },
        {
          'title': 'Geometry Problems',
          'grade': 92,
          'maxGrade': 100,
          'submittedDate': '2024-01-22',
          'feedback': 'Great understanding of angles and shapes.',
        },
        {
          'title': 'Statistics Project',
          'grade': 78,
          'maxGrade': 100,
          'submittedDate': '2024-01-29',
          'feedback': 'Good effort. Focus more on data interpretation.',
        },
        {
          'title': 'Calculus Introduction',
          'grade': 90,
          'maxGrade': 100,
          'submittedDate': '2024-02-05',
          'feedback': 'Outstanding! You have a natural talent for calculus.',
        },
        {
          'title': 'Trigonometry',
          'grade': 85,
          'maxGrade': 100,
          'submittedDate': '2024-02-12',
          'feedback': 'Well done. Practice more with unit circle.',
        },
        {
          'title': 'Probability',
          'grade': 82,
          'maxGrade': 100,
          'submittedDate': '2024-02-19',
          'feedback': 'Good work. Review conditional probability.',
        },
        {
          'title': 'Linear Algebra',
          'grade': 87,
          'maxGrade': 100,
          'submittedDate': '2024-02-26',
          'feedback': 'Excellent matrix operations.',
        },
      ],
    },
    {
      'subjectName': 'English Language',
      'teacherName': 'Mr. David Wilson',
      'totalAssignments': 6,
      'completedAssignments': 6,
      'averageGrade': 91.2,
      'assignments': [
        {
          'title': 'Essay Writing',
          'grade': 95,
          'maxGrade': 100,
          'submittedDate': '2024-01-18',
          'feedback':
              'Exceptional writing skills! Your arguments are well-structured.',
        },
        {
          'title': 'Poetry Analysis',
          'grade': 88,
          'maxGrade': 100,
          'submittedDate': '2024-01-25',
          'feedback': 'Great interpretation of metaphors and themes.',
        },
        {
          'title': 'Creative Writing',
          'grade': 92,
          'maxGrade': 100,
          'submittedDate': '2024-02-01',
          'feedback': 'Wonderful imagination and storytelling ability.',
        },
        {
          'title': 'Grammar Test',
          'grade': 89,
          'maxGrade': 100,
          'submittedDate': '2024-02-08',
          'feedback': 'Good understanding of grammar rules.',
        },
        {
          'title': 'Literature Review',
          'grade': 94,
          'maxGrade': 100,
          'submittedDate': '2024-02-15',
          'feedback': 'Excellent critical analysis of the text.',
        },
        {
          'title': 'Presentation',
          'grade': 90,
          'maxGrade': 100,
          'submittedDate': '2024-02-22',
          'feedback': 'Great presentation skills and confidence.',
        },
      ],
    },
    {
      'subjectName': 'Science',
      'teacherName': 'Dr. Emily Chen',
      'totalAssignments': 5,
      'completedAssignments': 4,
      'averageGrade': 79.8,
      'assignments': [
        {
          'title': 'Physics Lab Report',
          'grade': 85,
          'maxGrade': 100,
          'submittedDate': '2024-01-20',
          'feedback': 'Good experimental design. Improve data analysis.',
        },
        {
          'title': 'Chemistry Project',
          'grade': 78,
          'maxGrade': 100,
          'submittedDate': '2024-02-03',
          'feedback': 'Interesting project. Focus on safety procedures.',
        },
        {
          'title': 'Biology Research',
          'grade': 82,
          'maxGrade': 100,
          'submittedDate': '2024-02-10',
          'feedback': 'Well-researched topic. Good use of scientific method.',
        },
        {
          'title': 'Environmental Study',
          'grade': 74,
          'maxGrade': 100,
          'submittedDate': '2024-02-17',
          'feedback': 'Good effort. Include more statistical analysis.',
        },
      ],
    },
  ];

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
            subjects.isEmpty
                ? _buildEmptyState()
                : Column(
                  children:
                      subjects
                          .map((subject) => _buildSubjectCard(subject))
                          .toList(),
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

    return Container(
      width: 80.w,
      height: 80.h,
      child: Stack(
        children: [
          // Background circle
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
          ),
          // Progress circle
          Container(
            width: 80.w,
            height: 80.h,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
          // Grade text
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
