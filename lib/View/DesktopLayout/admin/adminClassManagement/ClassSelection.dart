// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../Model/classmodal.dart';
import '../../../../controller/DesktopControllers/class_controller.dart';
import 'create_class_modal.dart';
import 'ClassDetailsScreen.dart';

//update
class ClassSelectionView extends StatefulWidget {
  const ClassSelectionView({super.key});

  @override
  State<ClassSelectionView> createState() => _ClassSelectionViewState();
}

class _ClassSelectionViewState extends State<ClassSelectionView> {
  final ClassController _controller = ClassController();

  void _openCreateClassModal() {
    showDialog(
      context: context,
      builder:
          (_) => CreateClassModal(
            onSave: (ClassModel newClass) {
              setState(() {
                _controller.addClass(newClass);
              });
              Navigator.of(context).pop();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderWidget(onCreateClass: _openCreateClassModal),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children:
                  _controller.classes.map((classData) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.h),
                      child: SizedBox(
                        width: 0.95.sw,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ClassDetailsScreen(
                                      className: classData.name,
                                      classTeacherName: classData.teacher,
                                      classCapacity: classData.capacity,
                                      classTotalStudents: classData.students,
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
                                    classData.name,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    "Teacher: ${classData.teacher}",
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  Text(
                                    "Capacity: ${classData.capacity}",
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  Text(
                                    "Enrolled Students: ${classData.students}",
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class HeaderWidget extends StatelessWidget {
  final VoidCallback onCreateClass;
  const HeaderWidget({super.key, required this.onCreateClass});

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
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
            onPressed: () {
              Navigator.pop(context); // Pops the stack
            },
          ),
          Text(
            "Class Management",
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 20.w),
          Spacer(),
          SizedBox(
            width: 400.w,
            height: 50.h,
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
          SizedBox(width: 20.w),
          ElevatedButton.icon(
            onPressed: onCreateClass,
            icon: Icon(Icons.add, size: 20.sp),
            label: Text("Create Class", style: TextStyle(fontSize: 16.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.3),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
