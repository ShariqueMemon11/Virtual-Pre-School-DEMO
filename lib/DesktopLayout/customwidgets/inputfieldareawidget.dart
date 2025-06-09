import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputFieldAreaWidget extends StatelessWidget {
  const InputFieldAreaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8.0,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(20.r),
      child: TextField(
        maxLines: 5,
        minLines: 5,
        keyboardType: TextInputType.multiline,
        style: TextStyle(color: const Color(0xFF8C5FF5), fontSize: 16.sp),
        decoration: InputDecoration(
          hintText: 'Notification Body',
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
