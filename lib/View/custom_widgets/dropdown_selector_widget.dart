import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DropdownSelectorWidget extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?> onChanged;
  final String hintText;

  const DropdownSelectorWidget({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
    this.hintText = "Select Option",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // takes full width of parent
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedOption,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          items:
              options
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ),
                  )
                  .toList(),
          hint: Text(
            hintText,
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color.fromARGB(255, 100, 100, 100),
            ),
          ),
          style: TextStyle(fontSize: 16.sp, color: const Color(0xFF8C5FF5)),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
