import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputFieldAreaWidget extends StatelessWidget {
  final String input;
  final TextEditingController controller;

  const InputFieldAreaWidget({
    required this.input,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8.0,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(20.r),
      child: TextField(
        controller: controller,
        maxLines: 5,
        minLines: 5,
        keyboardType: TextInputType.multiline,
        style: TextStyle(color: const Color(0xFF8C5FF5), fontSize: 16.sp),
        decoration: InputDecoration(
          hintText: input,
          hintStyle: const TextStyle(color: Color(0xFF8C5FF5)),
          fillColor: const Color.fromARGB(202, 245, 245, 245),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
