import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/controller/DesktopControllers/teacher_admission_controller.dart';
import 'package:demo_vps/View/DesktopLayout/customwidgets/inputfieldwidget.dart';
import 'package:demo_vps/View/DesktopLayout/customwidgets/primarybuttonwidget.dart';
import 'package:demo_vps/View/DesktopLayout/customwidgets/secondarybuttonwidget.dart';

class TeacherAdmissionWidget extends StatefulWidget {
  const TeacherAdmissionWidget({super.key});

  @override
  State<TeacherAdmissionWidget> createState() => _TeacherAdmissionWidgetState();
}

class _TeacherAdmissionWidgetState extends State<TeacherAdmissionWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _addressController = TextEditingController();

  late TeacherAdmissionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TeacherAdmissionController(
      nameController: _nameController,
      emailController: _emailController,
      phoneController: _phoneController,
      qualificationController: _qualificationController,
      experienceController: _experienceController,
      subjectsController: _subjectsController,
      addressController: _addressController,
      context: context,
      formKey: _formKey,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _subjectsController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.0.h, vertical: 10.0.h),
          height: screenSize.height * 0.85,
          width: screenSize.width * 0.25,
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
                "Teacher Admission",
                style: TextStyle(
                  fontSize: 30.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              InputFieldWidget(
                input: "Name",
                controller: _nameController,
                validator: _controller.requiredValidator,
              ),
              SizedBox(height: 20.h),
              InputFieldWidget(
                input: "Email",
                controller: _emailController,
                validator: _controller.emailValidator,
              ),
              SizedBox(height: 20.h),
              InputFieldWidget(
                input: "Phone",
                controller: _phoneController,
                validator: _controller.requiredValidator,
              ),
              SizedBox(height: 20.h),
              InputFieldWidget(
                input: "Qualification",
                controller: _qualificationController,
                validator: _controller.requiredValidator,
              ),
              SizedBox(height: 20.h),
              InputFieldWidget(
                input: "Experience",
                controller: _experienceController,
                validator: _controller.requiredValidator,
              ),
              SizedBox(height: 20.h),
              InputFieldWidget(
                input: "Subject Specialization",
                controller: _subjectsController,
                validator: _controller.requiredValidator,
              ),
              SizedBox(height: 20.h),
              InputFieldWidget(
                input: "Address",
                controller: _addressController,
                validator: _controller.requiredValidator,
              ),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 5.w),
                  child: Text(
                    "Upload CV",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF784BE1),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _controller.pickCV,
                    icon: Icon(Icons.upload_file),
                    label: Text('Upload File'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _controller.cvFileName ?? 'No file selected',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Primarybuttonwidget(run: _controller.submit, input: "Submit"),
                  Secondarybuttonwidget(
                    run: () => _controller.navigateBack(),
                    input: "Back",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
