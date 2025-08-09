import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Model/classmodal.dart';

//merging to git
class CreateClassModal extends StatefulWidget {
  final void Function(ClassModel) onSave;

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
                        if (val == null || val.isEmpty) return "Enter capacity";
                        if (int.tryParse(val) == null)
                          return "Enter valid number";
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
                        if (val == null || val.isEmpty)
                          return "Enter enrolled students";
                        if (int.tryParse(val) == null)
                          return "Enter valid number";
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
                              widget.onSave(
                                ClassModel(
                                  name: className,
                                  teacher: teacherName,
                                  capacity: capacity!,
                                  students: students!,
                                ),
                              );
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
