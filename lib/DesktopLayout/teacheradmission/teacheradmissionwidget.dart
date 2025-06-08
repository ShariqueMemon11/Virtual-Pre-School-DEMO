import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/inputfieldwidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/primarybuttonwidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/secondarybuttonwidget.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Class name should be PascalCase
class TeacherAdmissionwidget extends StatefulWidget {
  const TeacherAdmissionwidget({super.key});    

  @override
  State<TeacherAdmissionwidget> createState() => _TeacherAdmissionwidgetState();
}

class _TeacherAdmissionwidgetState extends State<TeacherAdmissionwidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _addressController = TextEditingController();   

  File? _cvFile;
  String? _cvFileName;

  Future<void> _pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _cvFile = File(result.files.single.path!);
        _cvFileName = result.files.single.name;
      });
    }
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_cvFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please upload your CV!')),
        );
        return;
      }
      // Handle form submission logic here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form submitted successfully!')),
      );
    }
  }
  void back(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.0.h, vertical: 10.0.h),
        height: screenHeight * 0.85,
        width: screenWidth * 0.25,
        decoration: BoxDecoration(
          color: const Color.fromARGB(141, 233, 233, 233),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 7,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                "Teacher Admission",
                style: TextStyle(
                  fontSize: 30.sp,
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            InputFieldWidget(input: "Name", controller: _nameController,  validator: (value) => value == null || value.isEmpty ? "Required" : null,),
            SizedBox(height: 20.h),
            InputFieldWidget(input: "Email", controller: _emailController, validator: (value) {
                  if (value == null || value.isEmpty) return "Required";
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Enter a valid email";
                  return null;
                },),
            SizedBox(height: 20.h),
            InputFieldWidget(input: "Phone", controller: _phoneController, validator: (value) => value == null || value.isEmpty ? "Required" : null,),
            SizedBox(height: 20.h),
            InputFieldWidget(input: "Qualification", controller: _qualificationController, validator: (value) => value == null || value.isEmpty ? "Required" : null,),
            SizedBox(height: 20.h),
            InputFieldWidget(input: "Experience", controller: _experienceController, validator: (value) => value == null || value.isEmpty ? "Required" : null,),
            SizedBox(height: 20.h),
            InputFieldWidget(input: "Subject Specialization", controller: _subjectsController, validator: (value) => value == null || value.isEmpty ? "Required" : null,),
            SizedBox(height: 20.h),
            InputFieldWidget(input: "Address", controller: _addressController, validator: (value) => value == null || value.isEmpty ? "Required" : null,    ),     
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
                  onPressed: _pickCV,
                  icon: Icon(Icons.upload_file),
                  label: Text('Upload File'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _cvFileName ?? 'No file selected',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              spacing: 10.w,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Primarybuttonwidget(run: () => _submit(), input: "Submit"),
                Secondarybuttonwidget(run: () => back(context), input: "Back"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
