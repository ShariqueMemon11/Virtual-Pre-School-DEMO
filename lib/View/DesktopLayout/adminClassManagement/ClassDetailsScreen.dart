// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeaderWidget extends StatelessWidget {
  final dynamic className;

  const HeaderWidget({super.key, required this.className});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 156, 129, 219),
      width: double.infinity,
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
            onPressed: () {
              Navigator.pop(context); // Pops the stack
            },
          ),
          SizedBox(width: 8.w),

          // Class Name
          Expanded(
            child: Text(
              "$className",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClassDetailsScreen extends StatelessWidget {
  final String className;
  final String classTeacherName;
  final int classCapacity;
  final int classTotalStudents;

  const ClassDetailsScreen({
    super.key,
    required this.className,
    required this.classTeacherName,
    required this.classCapacity,
    required this.classTotalStudents,
  });

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final double courseCompletion = 0.65; // 65% completed
    final String teacherContact = "teacher@example.com";
    final List<String> students = [
      "Ali Khan",
      "Sara Ahmed",
      "Hina Malik",
      "Zain Ali",
      "Ayesha Noor",
      "Omar Farooq",
      "Fatima Tariq",
    ];
    final List<String> courseMaterials = [
      "Alphabet Practice",
      "Basic Counting",
      "Shapes & Colors",
      "Phonics Level 1",
      "Storybook Reading",
      "Art & Craft Basics",
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderWidget(className: className),
              SizedBox(height: 20.h),

              // SECTION 1: CLASS OVERVIEW
              _buildSectionHeader(Icons.info, "Class Overview"),
              _buildInfoCard([
                _buildInfoRow("Teacher", classTeacherName),
                _buildDivider(),
                _buildInfoRow("Capacity", "$classCapacity"),
                _buildDivider(),
                _buildInfoRow("Enrolled", "$classTotalStudents"),
                _buildDivider(),
                _buildInfoRow("Contact", teacherContact),
                _buildDivider(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Course Progress",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      LinearProgressIndicator(
                        value: courseCompletion,
                        minHeight: 8.h,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        "${(courseCompletion * 100).toStringAsFixed(0)}% completed",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),

              SizedBox(height: 20.h),

              // SECTION 2: STUDENT LIST
              _buildSectionHeader(Icons.group, "Students"),
              _buildInfoCard(
                students
                    .map(
                      (student) => Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple[200],
                              child: Text(
                                student[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              student,
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ),
                          if (student != students.last) _buildDivider(),
                        ],
                      ),
                    )
                    .toList(),
              ),

              SizedBox(height: 20.h),

              // SECTION 3: COURSE MATERIAL
              _buildSectionHeader(Icons.menu_book, "Course Material"),
              _buildInfoCard(
                courseMaterials
                    .map(
                      (material) => Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.book, color: Colors.deepPurple),
                            title: Text(
                              material,
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ),
                          if (material != courseMaterials.last) _buildDivider(),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Section Header
  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 22.sp),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Card Container
  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(children: children),
      ),
    );
  }

  // Info Row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // Divider Style
  Widget _buildDivider() {
    return Divider(color: Colors.grey[300], thickness: 1, height: 12.h);
  }
}
