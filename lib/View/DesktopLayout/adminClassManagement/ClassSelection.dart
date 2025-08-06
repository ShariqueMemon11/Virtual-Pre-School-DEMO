import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/View/DesktopLayout/adminClassManagement/ClassDetailsScreen.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 156, 129, 219),
      width: double.infinity,
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(
            "Class Management",
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 20.w), // spacing between text and search bar
          Spacer(),
          SizedBox(
            width: 400.w,
            height: 50.h, // scaled height instead of fixed 80
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8.h,
                  horizontal: 12.w,
                ),
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.white70, fontSize: 16.sp),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white70,
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BodyWidget extends StatelessWidget {
  BodyWidget({super.key});

  final List<Map<String, dynamic>> Classes = [
    {
      'name': 'Playgroup A',
      'teacher': 'Miss Sana',
      'capacity': 20,
      'students': 18,
    },
    {
      'name': 'Playgroup B',
      'teacher': 'Miss Hira',
      'capacity': 20,
      'students': 19,
    },
    {
      'name': 'Nursery A',
      'teacher': 'Miss Sara',
      'capacity': 25,
      'students': 22,
    },
    {
      'name': 'Nursery B',
      'teacher': 'Mr. Zain',
      'capacity': 25,
      'students': 23,
    },
    {
      'name': 'KG 1 A',
      'teacher': 'Miss Fatima',
      'capacity': 30,
      'students': 27,
    },
    {'name': 'KG 1 B', 'teacher': 'Mr. Ali', 'capacity': 30, 'students': 28},
    {'name': 'KG 2 A', 'teacher': 'Miss Huma', 'capacity': 30, 'students': 29},
    {'name': 'KG 2 B', 'teacher': 'Mr. Saad', 'capacity': 30, 'students': 30},
    {
      'name': 'Prep A',
      'teacher': 'Miss Ayesha',
      'capacity': 28,
      'students': 26,
    },
    {'name': 'Prep B', 'teacher': 'Mr. Imran', 'capacity': 28, 'students': 27},
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(Classes.length, (index) {
              final classData = Classes[index];

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Container(
                  width: 0.95.sw,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      12.r,
                    ), // matches Card shape
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ClassDetailsScreen(
                                className: classData['name'],
                                classTeacherName: classData['teacher'],
                                classCapacity: classData['capacity'],
                                classTotalStudents: classData['students'],
                              ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classData['name'],
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Teacher: ${classData['teacher']}",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            Text(
                              "Capacity: ${classData['capacity']}",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            Text(
                              "Enrolled Students: ${classData['students']}",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class ClassSelection extends StatelessWidget {
  const ClassSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderWidget(),
        BodyWidget(),
        // Other widgets will go here
      ],
    );
  }
}
