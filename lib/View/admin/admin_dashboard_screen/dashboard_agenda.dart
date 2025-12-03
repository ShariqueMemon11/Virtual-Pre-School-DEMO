import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Agenda extends StatelessWidget {
  const Agenda({super.key});

  final List<Map<String, String>> agendaItems = const [
    {"time": "8:00 - 8:30", "task": "Check Emails & Messages"},
    {"time": "8:35 - 9:35", "task": "Check Teachers and Students Attendance"},
    {"time": "9:40 - 10:20", "task": "Answer Parents and Teacher Queries"},
    {"time": "10:25 - 10:55", "task": "Meeting with New Teachers"},
    {"time": "11:00 - 12:00", "task": "Department Meeting"},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Today's Agenda",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(onPressed: () {}, icon: Icon(Icons.add)),
              ],
            ),
            SizedBox(height: 12.h),
            ...List.generate(agendaItems.length, (index) {
              final item = agendaItems[index];
              final isEven = index % 2 == 0;
              final bgColor =
                  isEven
                      ? const Color.fromARGB(255, 238, 212, 248)
                      : const Color.fromARGB(255, 249, 236, 184);
              return _agendaItem(item['time']!, item['task']!, bgColor);
            }),
          ],
        ),
      ),
    );
  }

  Widget _agendaItem(String time, String task, Color bgColor) {
    return Container(
      width: double.infinity, // 👈 Full width
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(task, style: TextStyle(fontSize: 13.sp, color: Colors.black87)),
        ],
      ),
    );
  }
}
