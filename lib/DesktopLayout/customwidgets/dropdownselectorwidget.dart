import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DropdownSelectorWidget extends StatefulWidget {
  const DropdownSelectorWidget({required this.options, super.key});
  final List<String> options;

  @override
  State<DropdownSelectorWidget> createState() => _DropdownSelectorWidgetState();
}

class _DropdownSelectorWidgetState extends State<DropdownSelectorWidget> {
  String selectedOption = "Select Option";

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
            value: selectedOption == "Select Option" ? null : selectedOption,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            items:
                widget.options
                    .map(
                      (aud) => DropdownMenuItem<String>(
                        value: aud,
                        child: Text(aud),
                      ),
                    )
                    .toList(),
            hint: Text(selectedOption),
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF8C5FF5)),
            onChanged: (value) {
              setState(() {
                selectedOption = value ?? "Select Option";
              });
            },
          ),
        ),
      ),
    );
  }
}
