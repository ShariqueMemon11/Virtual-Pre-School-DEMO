import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/View/DesktopLayout/adminClassManagement/ClassDetailsScreen.dart';

class ClassSelection extends StatefulWidget {
  const ClassSelection({super.key});

  @override
  State<ClassSelection> createState() => _ClassSelectionState();
}

class _ClassSelectionState extends State<ClassSelection> {
  List<Map<String, dynamic>> classes = [
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
    // ... other initial classes
  ];

  void _addClass(Map<String, dynamic> newClass) {
    setState(() {
      classes.add(newClass);
    });
  }

  void _openCreateClassModal() {
    showDialog(
      context: context,
      builder:
          (_) => CreateClassModal(
            onSave: (newClass) {
              _addClass(newClass);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderWidget(onCreateClass: _openCreateClassModal),
        BodyWidget(classes: classes),
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

class BodyWidget extends StatelessWidget {
  final List<Map<String, dynamic>> classes;
  const BodyWidget({super.key, required this.classes});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(classes.length, (index) {
              final classData = classes[index];

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: SizedBox(
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

class CreateClassModal extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSave;

  const CreateClassModal({super.key, required this.onSave});

  @override
  State<CreateClassModal> createState() => _CreateClassModalState();
}

class _CreateClassModalState extends State<CreateClassModal> {
  final _formKey = GlobalKey<FormState>();

  String className = '';
  String teacherName = '';
  int? capacity;
  int? students;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20.w),
      child: Container(
        width: 0.6.sw,
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Create New Class",
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Class Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onChanged: (val) => className = val,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? "Enter class name"
                                  : null,
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Teacher Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onChanged: (val) => teacherName = val,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? "Enter teacher name"
                                  : null,
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Capacity",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => capacity = int.tryParse(val),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Enter capacity";
                        }
                        if (int.tryParse(val) == null) {
                          return "Enter valid number";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Enrolled Students",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => students = int.tryParse(val),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Enter enrolled students";
                        }
                        if (int.tryParse(val) == null) {
                          return "Enter valid number";
                        }
                        if (capacity != null &&
                            int.tryParse(val)! > capacity!) {
                          return "Students cannot exceed capacity";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              widget.onSave({
                                'name': className,
                                'teacher': teacherName,
                                'capacity': capacity,
                                'students': students,
                              });
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(
                            "Save",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// still have some issues