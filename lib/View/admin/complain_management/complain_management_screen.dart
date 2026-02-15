// ignore: file_names
import "package:flutter/material.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/responsive_helper.dart';

/// ------------------ HEADER ------------------
class HeaderWidget extends StatelessWidget {
  final VoidCallback onBack;
  const HeaderWidget({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 156, 129, 219),
      width: double.infinity,
      height: ResponsiveHelper.isMobile(context) ? 56 : 60.h,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(context, 16),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: ResponsiveHelper.fontSize(context, 20),
            ),
            onPressed: onBack,
          ),
          SizedBox(width: ResponsiveHelper.spacing(context, 8)),
          Text(
            ResponsiveHelper.isMobile(context) ? "Complaints" : "Complaint Management",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.fontSize(context, 18),
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
          padding: EdgeInsets.all(ResponsiveHelper.padding(context, 12)),
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
            padding: EdgeInsets.all(ResponsiveHelper.padding(context, 16)),
            itemCount: filteredComplaints.length,
            itemBuilder: (context, index) {
              final complaint = filteredComplaints[index];
              return Card(
                margin: EdgeInsets.only(
                  bottom: ResponsiveHelper.padding(context, 12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.report_problem,
                    color: Colors.deepPurple,
                    size: ResponsiveHelper.fontSize(context, 24),
                  ),
                  title: Text(
                    complaint["title"]!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.fontSize(context, 16),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ResponsiveHelper.spacing(context, 4)),
                      Text(
                        complaint["body"]!,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.fontSize(context, 14),
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(context, 4)),
                      Text(
                        "Category: ${complaint["category"]}",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.fontSize(context, 13),
                        ),
                      ),
                      Text(
                        "Status: ${complaint["status"]}",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.fontSize(context, 13),
                        ),
                      ),
                      Text(
                        "Date: ${complaint["date"]}",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.fontSize(context, 13),
                        ),
                      ),
                      Text(
                        "By: ${complaint["submittedBy"]}",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.fontSize(context, 13),
                        ),
                      ),
                    ],
                  ),
                  trailing: ResponsiveHelper.isMobile(context)
                      ? null
                      : Row(
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
        title: Text(
          "Complaint Details",
          style: TextStyle(
            fontSize: ResponsiveHelper.fontSize(context, 20),
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.padding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Title: ${complaint["title"]}",
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(context, 10)),
            Text(
              "Description: ${complaint["body"]}",
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(context, 15),
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(context, 10)),
            Text(
              "Category: ${complaint["category"]}",
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(context, 15),
              ),
            ),
            Text(
              "Status: ${complaint["status"]}",
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(context, 15),
              ),
            ),
            Text(
              "Date: ${complaint["date"]}",
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(context, 15),
              ),
            ),
            Text(
              "Submitted By: ${complaint["submittedBy"]}",
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(context, 15),
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(context, 20)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Marked as Resolved")),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                  "Mark as Resolved",
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(context, 16),
                  ),
                ),
              ),
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
