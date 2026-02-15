import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentDashboardAgenda extends StatefulWidget {
  const StudentDashboardAgenda({super.key});

  @override
  State<StudentDashboardAgenda> createState() => _StudentDashboardAgendaState();
}

class _StudentDashboardAgendaState extends State<StudentDashboardAgenda> {
  List<Map<String, String>> agendaItems = [
    {"time": "8:00 - 8:30", "task": "Morning Assembly"},
    {"time": "8:35 - 9:35", "task": "Mathematics Class"},
    {"time": "9:40 - 10:20", "task": "English Language"},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 0 : 12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Today's Schedule",
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (agendaItems.isNotEmpty)
                  IconButton(
                    onPressed: _clearAllScheduleItems,
                    icon: Icon(
                      Icons.clear_all,
                      color: Colors.orange[600],
                      size: isMobile ? 26 : 24,
                    ),
                    tooltip: 'Clear All',
                  ),
                IconButton(
                  onPressed: _showAddScheduleDialog,
                  icon: Icon(Icons.add, size: isMobile ? 26 : 24),
                  tooltip: 'Add Schedule Item',
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 12.h),
            Expanded(
              child:
                  agendaItems.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        itemCount: agendaItems.length,
                        itemBuilder: (context, index) {
                          final item = agendaItems[index];
                          final isEven = index % 2 == 0;
                          final bgColor =
                              isEven
                                  ? const Color.fromARGB(255, 238, 212, 248)
                                  : const Color.fromARGB(255, 249, 236, 184);
                          return _agendaItem(
                            item['time']!,
                            item['task']!,
                            bgColor,
                            index,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _agendaItem(String time, String task, Color bgColor, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 10.h),
      padding: EdgeInsets.all(isMobile ? 14 : 12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: isMobile ? 6 : 4.h),
                    Text(
                      task,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 13.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editScheduleItem(index),
                    icon: Icon(
                      Icons.edit_outlined,
                      size: isMobile ? 22 : 18.sp,
                      color: Colors.blue[600],
                    ),
                    padding: EdgeInsets.all(isMobile ? 4 : 0),
                    constraints: BoxConstraints(
                      minWidth: isMobile ? 36 : 32,
                      minHeight: isMobile ? 36 : 32,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeScheduleItem(index),
                    icon: Icon(
                      Icons.delete_outline,
                      size: isMobile ? 22 : 18.sp,
                      color: Colors.red[600],
                    ),
                    padding: EdgeInsets.all(isMobile ? 4 : 0),
                    constraints: BoxConstraints(
                      minWidth: isMobile ? 36 : 32,
                      minHeight: isMobile ? 36 : 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'No schedule items yet',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the + button to add your first schedule item',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _clearAllScheduleItems() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear All Schedule Items'),
          content: Text(
            'Are you sure you want to remove all schedule items? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  agendaItems.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All schedule items cleared!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _showAddScheduleDialog() {
    final timeController = TextEditingController();
    final taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Schedule Item',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Time (e.g., 8:00 - 8:30)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: 'Task/Activity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  prefixIcon: Icon(Icons.assignment),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (timeController.text.isNotEmpty &&
                    taskController.text.isNotEmpty) {
                  _addScheduleItem(timeController.text, taskController.text);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in both fields')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addScheduleItem(String time, String task) {
    setState(() {
      agendaItems.add({"time": time, "task": task});
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Schedule item added successfully!')),
    );
  }

  void _editScheduleItem(int index) {
    final timeController = TextEditingController(
      text: agendaItems[index]['time'],
    );
    final taskController = TextEditingController(
      text: agendaItems[index]['task'],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Schedule Item',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Time (e.g., 8:00 - 8:30)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: 'Task/Activity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  prefixIcon: Icon(Icons.assignment),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (timeController.text.isNotEmpty &&
                    taskController.text.isNotEmpty) {
                  setState(() {
                    agendaItems[index] = {
                      "time": timeController.text,
                      "task": taskController.text,
                    };
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Schedule item updated successfully!'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in both fields')),
                  );
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _removeScheduleItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Schedule Item'),
          content: Text('Are you sure you want to remove this schedule item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  agendaItems.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Schedule item removed!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
