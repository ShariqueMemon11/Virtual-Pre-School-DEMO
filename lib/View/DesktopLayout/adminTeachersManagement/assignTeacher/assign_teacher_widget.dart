import 'package:demo_vps/View/DesktopLayout/customwidgets/dropdownselectorwidget.dart';
import 'package:demo_vps/View/DesktopLayout/customwidgets/primarybuttonwidget.dart';
import 'package:demo_vps/View/DesktopLayout/customwidgets/secondarybuttonwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/controller/DesktopControllers/assign_teacher_controller.dart';

class AssignTeacherWidget extends StatefulWidget {
  const AssignTeacherWidget({super.key});

  @override
  State<AssignTeacherWidget> createState() => _AssignTeacherWidgetState();
}

// select teacher to assing then select a class then submit
class _AssignTeacherWidgetState extends State<AssignTeacherWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  late AssignTeacherController _controller;

  final List<String> _teacherOptions = ['Samra', 'Sara', 'Sidra'];
  final List<String> _classOptions = ['Class 1A', 'Class 2A', 'Class 1B'];

  @override
  void initState() {
    super.initState();
    _controller = AssignTeacherController(context: context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Container(
        height: screenSize.height * 0.6,
        width: screenSize.width * 0.4,
        padding: EdgeInsets.all(screenSize.width * 0.01),
        decoration: BoxDecoration(
          color: const Color.fromARGB(141, 233, 233, 233),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 7,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Assign Teacher",
              style: TextStyle(
                fontSize: 50.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 50.h),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.02,
              ),
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // Teacher Dropdown
                  DropdownSelectorWidget(
                    options: _teacherOptions,
                    selectedOption: _controller.Teacher,
                    hintText: "Select Teacher",
                    onChanged: (value) {
                      setState(() {
                        _controller.Teacher = value;
                      });
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Class Dropdown
                  DropdownSelectorWidget(
                    options: _classOptions,
                    selectedOption: _controller.Class,
                    hintText: "Select Class",
                    onChanged: (value) {
                      setState(() {
                        _controller.Class = value;
                      });
                    },
                  ),

                  SizedBox(height: 40.h),

                  // Submit Button
                  Row(
                    children: [
                      Primarybuttonwidget(
                        input: "Assign",
                        run:
                            _controller.isSubmitting
                                ? null
                                : () {
                                  _controller.AssignTeacher(
                                    () => setState(() {}),
                                  );
                                },
                      ),
                      SizedBox(width: 20.w),
                      Secondarybuttonwidget(
                        run: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                        input: "Back",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
