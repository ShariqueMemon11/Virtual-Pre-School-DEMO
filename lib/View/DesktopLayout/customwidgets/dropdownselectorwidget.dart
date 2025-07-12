import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DropdownSelectorWidget extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?> onChanged;

  const DropdownSelectorWidget({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade400),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedOption == "Select Audience" ? null : selectedOption,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            items:
                options
                    .map(
                      (aud) => DropdownMenuItem<String>(
                        value: aud,
                        child: Text(aud),
                      ),
                    )
                    .toList(),
            hint: Text(
              selectedOption ?? "Select Audience",
              style: TextStyle(fontSize: 16.sp, color: const Color(0xFF8C5FF5)),
            ),
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF8C5FF5)),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
