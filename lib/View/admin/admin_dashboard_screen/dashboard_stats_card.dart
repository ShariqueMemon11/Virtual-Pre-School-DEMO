// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class statscard extends StatelessWidget {
  const statscard({
    super.key,
    required this.color,
    required this.dataname,
    required this.ic,
    required this.quantity,
  });
  final Color color;
  final IconData ic;
  final String dataname;
  final String quantity;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.h,
      width: 230.w,
      decoration: BoxDecoration(
        color: color, // example color
        borderRadius: BorderRadius.all(Radius.circular(10.r)),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 30,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dataname,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25.sp,
                      color: Colors.black,
                    ),
                  ),

                  Icon(ic, size: 30.sp, color: Colors.black),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 30.0,
              ),

              child: Text(
                quantity,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.sp,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
