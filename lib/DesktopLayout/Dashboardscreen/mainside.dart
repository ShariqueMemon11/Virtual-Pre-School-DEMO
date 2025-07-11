import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainSide extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainSide();
}

class _MainSide extends State<MainSide> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Header

        // Menu Items
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0, left: 40.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,

                                children: [
                                  statscard(
                                    color: Color.fromARGB(197, 211, 163, 228),
                                    dataname: "Student",
                                    ic: Icons.child_care_rounded,
                                    quantity: "400",
                                  ),
                                  SizedBox(width: 50.w),
                                  statscard(
                                    color: Color.fromARGB(197, 249, 236, 184),
                                    dataname: "Teacher",
                                    ic: Icons.school,
                                    quantity: "24",
                                  ),
                                  SizedBox(width: 50.w),
                                  statscard(
                                    color: Color.fromARGB(197, 211, 163, 228),
                                    dataname: "Staff",
                                    ic: Icons.person_3_outlined,
                                    quantity: "10",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
      width: 300.w,
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
                      color: Colors.white,
                    ),
                  ),

                  Icon(ic, size: 30.sp, color: Colors.white),
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
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
