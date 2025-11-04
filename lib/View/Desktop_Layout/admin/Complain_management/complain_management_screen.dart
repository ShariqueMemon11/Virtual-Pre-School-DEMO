
import "package:flutter/material.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ------------------ HEADER ------------------
class HeaderWidget extends StatelessWidget {
  final VoidCallback onBack;
  const HeaderWidget({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 156, 129, 219),
      width: double.infinity,
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
            onPressed: onBack,
          ),
          SizedBox(width: 8.w),
          Text(
            "Complaint Management",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------ DUMMY DATA ------------------
final List<Map<String, String>> dummyComplaints = [
  {
    "id": "C001",
    "title": "Lesson video not loading",
    "body": "Parent reported that 'ABC Song' video is not working.",
    "category": "Technical",
    "status": "Pending",
    "date": "2025-08-19",
    "submittedBy": "Parent - John Doe",
  },
  {
    "id": "C002",
    "title": "Teacher speaking too fast",
    "body": "Parent feels the teacher is rushing through topics.",
    "category": "Teacher",
    "status": "In Progress",
    "date": "2025-08-18",
    "submittedBy": "Parent - Sarah Smith",
  },
  {
    "id": "C003",
    "title": "Payment not processed",
    "body": "Parent charged but class access not given.",
    "category": "Billing",
    "status": "Resolved",
    "date": "2025-08-17",
    "submittedBy": "Parent - Ali Khan",
  },
];

/// ------------------ LIST OF COMPLAINTS ------------------
class ComplaintIssuedList extends StatefulWidget {
  const ComplaintIssuedList({super.key});

  @override
  State<ComplaintIssuedList> createState() => _ComplaintIssuedListState();
}

class _ComplaintIssuedListState extends State<ComplaintIssuedList> {
  String selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    // Filter complaints
    final filteredComplaints =
        selectedFilter == "All"
            ? dummyComplaints
            : dummyComplaints
                .where((c) => c["status"] == selectedFilter)
                .toList();

    return Column(
      children: [
        /// Filter dropdown
        Padding(
          padding: EdgeInsets.all(12.w),
          child: DropdownButton<String>(
            value: selectedFilter,
            items:
                ["All", "Pending", "In Progress", "Resolved"]
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                selectedFilter = value!;
              });
            },
          ),
        ),

        /// List of complaints
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: filteredComplaints.length,
            itemBuilder: (context, index) {
              final complaint = filteredComplaints[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                child: ListTile(
                  leading: Icon(Icons.report_problem, color: Colors.deepPurple),
                  title: Text(
                    complaint["title"]!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      Text(
                        complaint["body"]!,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text("Category: ${complaint["category"]}"),
                      Text("Status: ${complaint["status"]}"),
                      Text("Date: ${complaint["date"]}"),
                      Text("By: ${complaint["submittedBy"]}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Edit ${complaint["title"]}..."),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Deleted ${complaint["title"]}"),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ComplaintDetailsScreen(complaint: complaint),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// ------------------ DETAILS SCREEN ------------------
class ComplaintDetailsScreen extends StatelessWidget {
  final Map<String, String> complaint;
  const ComplaintDetailsScreen({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaint Details"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Title: ${complaint["title"]}",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Text("Description: ${complaint["body"]}"),
            SizedBox(height: 10.h),
            Text("Category: ${complaint["category"]}"),
            Text("Status: ${complaint["status"]}"),
            Text("Date: ${complaint["date"]}"),
            Text("Submitted By: ${complaint["submittedBy"]}"),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Marked as Resolved")),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Mark as Resolved"),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------ MAIN SCREEN ------------------
class ComplaintManagementScreen extends StatelessWidget {
  const ComplaintManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeaderWidget(onBack: () => Navigator.pop(context)),
          const Expanded(child: ComplaintIssuedList()),
        ],
      ),
    );
  }
}
