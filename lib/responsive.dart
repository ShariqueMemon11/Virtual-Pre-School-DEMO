import 'package:demo_vps/View/DesktopLayout/desktopmain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Responsive extends StatelessWidget {
  const Responsive({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ScreenUtilInit(
          designSize: Size(1366, 768), //My Laptop Dimension
          builder:
              (context, child) => MaterialApp(
                debugShowCheckedModeBanner: false,
                home: const DesktopMain(),
              ),
        );
      },
    );
  }
}
