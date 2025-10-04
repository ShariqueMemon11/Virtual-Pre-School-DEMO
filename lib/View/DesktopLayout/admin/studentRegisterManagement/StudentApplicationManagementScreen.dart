import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/View/DesktopLayout/admin/studentRegisterManagement/StudentApplicationView.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 156, 129, 219),
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          SizedBox(width: 10.w),
          Text(
            "Student Application Management",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class StudentapplicationList extends StatefulWidget {
  const StudentapplicationList({super.key});

  @override
  State<StudentapplicationList> createState() => _StudentapplicationListState();
}

class _StudentapplicationListState extends State<StudentapplicationList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('student applications')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No student applications found.'));
        }

        final applications = snapshot.data!.docs;

        return ListView.builder(
          itemCount: applications.length,
          padding: EdgeInsets.all(16.w),
          itemBuilder: (context, index) {
            final doc = applications[index];
            final data = doc.data() as Map<String, dynamic>;
            final approvalStatus = (data["approval"] ?? "Pending").toString();

            // 👶 Decode child photo if available
            ImageProvider? childPhoto;
            if (data["childPhotoFile"] != null &&
                (data["childPhotoFile"] as String).isNotEmpty) {
              try {
                String base64Str = data["childPhotoFile"];
                // Remove "data:image/...;base64," if present
                if (base64Str.contains(',')) {
                  base64Str = base64Str.split(',').last;
                }
                final bytes = base64Decode(base64Str);
                childPhoto = MemoryImage(bytes);
              } catch (e) {
                debugPrint("Error decoding image: $e");
                childPhoto = null;
              }
            }

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => StudentApplicationDetailScreen(
                          documentId: doc.id,
                          application: data.map(
                            (key, value) =>
                                MapEntry(key, value?.toString() ?? ""),
                          ),
                        ),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 6,
                margin: EdgeInsets.symmetric(vertical: 10.h),
                shadowColor: Colors.black26,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      // 🧒 Circle Avatar or Gradient Placeholder
                      Container(
                        width: 55.w,
                        height: 55.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient:
                              childPhoto == null
                                  ? const LinearGradient(
                                    colors: [
                                      Color(0xFF8E2DE2),
                                      Color(0xFF4A00E0),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                  : null,
                          image:
                              childPhoto != null
                                  ? DecorationImage(
                                    image: childPhoto,
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            childPhoto == null
                                ? Center(
                                  child: Text(
                                    data["childName"] != null &&
                                            data["childName"].isNotEmpty
                                        ? data["childName"][0].toUpperCase()
                                        : "?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                                : null,
                      ),
                      SizedBox(width: 14.w),

                      // Info Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["childName"] ?? "Unknown",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                const Icon(
                                  Icons.email,
                                  size: 16,
                                  color: Colors.blueGrey,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  data["email"] ?? "N/A",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(width: 15.w),
                                const Icon(
                                  Icons.cake,
                                  size: 16,
                                  color: Colors.blueGrey,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  data["dateOfBirth"]
                                          ?.toString()
                                          .split("T")
                                          .first ??
                                      "N/A",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),

                            // Status badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  approvalStatus,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: _getStatusColor(approvalStatus),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                approvalStatus,
                                style: TextStyle(
                                  color: _getStatusColor(approvalStatus),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _firestore
                              .collection('student applications')
                              .doc(doc.id)
                              .delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Deleted ${data["childName"] ?? "application"}",
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class Studentapplicationmanagementscreen extends StatelessWidget {
  const Studentapplicationmanagementscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [const Header(), Expanded(child: StudentapplicationList())],
      ),
    );
  }
}
