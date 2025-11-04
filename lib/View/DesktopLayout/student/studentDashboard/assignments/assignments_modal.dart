// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html; // For Flutter Web download
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../customwidgets/uploadfilewidget.dart';

class AssignmentsModal extends StatefulWidget {
  const AssignmentsModal({super.key});

  @override
  State<AssignmentsModal> createState() => _AssignmentsModalState();
}

class _AssignmentsModalState extends State<AssignmentsModal> {
  List<Map<String, dynamic>> assignments = [];
  bool isLoading = true;
  String? selectedFileName;
  String? selectedFileBase64;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    try {
      setState(() {
        isLoading = true;
      });

      final querySnapshot =
          await FirebaseFirestore.instance.collection('assignments').get();

      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      final String? currentUserId = user?.uid;

      // Build assignment list and annotate with whether the current user already submitted
      final List<Map<String, dynamic>> loaded = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final data = doc.data();

          bool hasSubmitted = false;
          Timestamp? submittedAt;
          String? submittedFileName;

          if (currentUserId != null) {
            final submissionSnap =
                await FirebaseFirestore.instance
                    .collection('student_submissions')
                    .where('assignmentId', isEqualTo: doc.id)
                    .where('studentId', isEqualTo: currentUserId)
                    .limit(1)
                    .get();
            if (submissionSnap.docs.isNotEmpty) {
              hasSubmitted = true;
              final s = submissionSnap.docs.first.data();
              submittedAt = s['submittedAt'] as Timestamp?;
              submittedFileName = s['fileName'] as String?;
            }
          }

          return {
            'id': doc.id,
            'title': data['title'] ?? 'Assignment ${doc.id.substring(0, 8)}',
            'description': data['description'] ?? 'No description provided',
            'fileBase64': data['assignment'] ?? data['fileBase64'] ?? '',
            'fileName': data['fileName'] ?? 'assignment.pdf',
            'createdAt': data['createdAt'] ?? Timestamp.now(),
            'dueDate': data['dueDate'],
            'status': data['status'] ?? 'pending',
            'hasSubmitted': hasSubmitted,
            'submittedAt': submittedAt,
            'submittedFileName': submittedFileName,
          };
        }).toList(),
      );

      setState(() {
        assignments = loaded;

        // Sort assignments by creation date if available, otherwise by document ID
        assignments.sort((a, b) {
          if (a['createdAt'] != null && b['createdAt'] != null) {
            return (b['createdAt'] as Timestamp).compareTo(
              a['createdAt'] as Timestamp,
            );
          }
          return b['id'].compareTo(a['id']); // Sort by document ID as fallback
        });
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading assignments: $e')),
        );
      }
    }
  }

  Future<void> _uploadAssignment(String assignmentId) async {
    if (selectedFileBase64 == null || selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to submit assignments')),
        );
        return;
      }

      // Prevent duplicate submissions for this assignment by this student
      final existing =
          await FirebaseFirestore.instance
              .collection('student_submissions')
              .where('assignmentId', isEqualTo: assignmentId)
              .where('studentId', isEqualTo: user.uid)
              .limit(1)
              .get();
      if (existing.docs.isNotEmpty) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder:
              (context) => AlertDialog(
                title: const Text('Already submitted'),
                content: const Text(
                  'You have already submitted this assignment. Resubmission is not allowed.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
        return;
      }

      // Use simple base64 approach like notifications (no Firebase Storage needed)
      final fileBytes = base64Decode(selectedFileBase64!);
      final fileSizeInMB = fileBytes.length / (1024 * 1024);

      // Enforce 1 MB max upload size
      if (fileBytes.length > 1024 * 1024) {
        setState(() {
          selectedFileName = null;
          selectedFileBase64 = null;
        });

        // Show alert dialog instead of snackbar
        showDialog(
          context: context,
          barrierDismissible: true,
          builder:
              (context) => AlertDialog(
                title: const Text('File too large'),
                content: Text(
                  'The selected file is ${fileSizeInMB.toStringAsFixed(2)} MB. The maximum allowed size is 1 MB.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
        return;
      }

      // Resolve student name from Students collection, fallback to displayName
      String studentName = user.displayName ?? 'Student';
      try {
        final studentsQuery =
            await FirebaseFirestore.instance
                .collection('Students')
                .where('email', isEqualTo: user.email)
                .limit(1)
                .get();
        if (studentsQuery.docs.isNotEmpty) {
          final sdata = studentsQuery.docs.first.data();
          final resolvedName =
              (sdata['name'] ?? sdata['studentName'])?.toString();
          if (resolvedName != null && resolvedName.trim().isNotEmpty) {
            studentName = resolvedName.trim();
          }
        } else {
          // Fallback to student applications collection (as used elsewhere in app)
          final appsQuery =
              await FirebaseFirestore.instance
                  .collection('student applications')
                  .where('email', isEqualTo: user.email)
                  .limit(1)
                  .get();
          if (appsQuery.docs.isNotEmpty) {
            final adata = appsQuery.docs.first.data();
            final resolvedName =
                (adata['name'] ?? adata['studentName'] ?? adata['fullName'])
                    ?.toString();
            if (resolvedName != null && resolvedName.trim().isNotEmpty) {
              studentName = resolvedName.trim();
            }
          }
        }
      } catch (_) {
        // Ignore lookup errors and keep fallback
      }

      // Last-resort fallback: derive from email prefix if still generic
      if (studentName == 'Student' || studentName.trim().isEmpty) {
        final emailPrefix = (user.email ?? '').split('@').first;
        if (emailPrefix.isNotEmpty) {
          studentName = emailPrefix;
        }
      }

      if (!mounted) return;

      // Show persistent loading indicator (no duration = stays until cleared)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10),
              Text('Uploading assignment...'),
            ],
          ),
          duration: Duration(days: 1), // Will be cleared manually
        ),
      );

      final fileBase64 = selectedFileBase64;

      // Create a unique submission ID that includes assignment ID for easy querying
      final submissionId =
          '${assignmentId}_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance
          .collection('student_submissions')
          .doc(submissionId)
          .set({
            'submissionId': submissionId,
            'assignmentId': assignmentId, // Connect to assignment
            'assignmentTitle':
                assignments.firstWhere((a) => a['id'] == assignmentId)['title'],
            'studentId': user.uid,
            'studentEmail': user.email,
            'studentName': studentName,
            'fileName': selectedFileName,
            'fileBase64':
                fileBase64, // Store base64 for all files (like notifications)
            'fileSize': fileBytes.length,
            'submittedAt': Timestamp.now(),
            'status': 'submitted',
            'reviewStatus': 'pending', // For teacher review
            'grade': null, // Will be set by teacher
            'teacherFeedback': null, // Will be set by teacher
          });

      if (!mounted) return;

      // Store filename before clearing
      final uploadedFileName = selectedFileName;

      // Clear selected file first
      setState(() {
        selectedFileName = null;
        selectedFileBase64 = null;
        // Mark this assignment as completed in UI and store submission time
        final idx = assignments.indexWhere((a) => a['id'] == assignmentId);
        if (idx != -1) {
          final updated = Map<String, dynamic>.from(assignments[idx]);
          updated['hasSubmitted'] = true;
          updated['submittedAt'] = Timestamp.now();
          updated['submittedFileName'] = uploadedFileName;
          updated['status'] = 'completed';
          assignments[idx] = updated;
        }
      });

      // Clear any existing snackbars first
      ScaffoldMessenger.of(context).clearSnackBars();

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Assignment "$uploadedFileName" submitted successfully! (${fileSizeInMB.toStringAsFixed(2)} MB)',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Clear any existing snackbars first
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading assignment: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _downloadAssignment(String fileBase64, String fileName) async {
    try {
      if (fileBase64.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file data available for download')),
        );
        return;
      }

      // Use the same download method as notifications
      final bytes = base64Decode(fileBase64);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.AnchorElement(href: url)
        ..download = fileName
        ..click();

      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading $fileName (${bytes.length} bytes)...'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error downloading file: $e')));
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: 800.w,
        height: 600.h,
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.assignment, size: 28.sp, color: Colors.blue),
                SizedBox(width: 10.w),
                Text(
                  'My Assignments',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Content
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : assignments.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        itemCount: assignments.length,
                        itemBuilder: (context, index) {
                          final assignment = assignments[index];
                          return _buildAssignmentCard(assignment);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'No assignments available',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Check back later for new assignments',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assignment Title and Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    assignment['title'],
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Display completed if submitted
                Builder(
                  builder: (_) {
                    final bool isCompleted =
                        assignment['hasSubmitted'] == true ||
                        assignment['status'] == 'completed';
                    final Color? bg =
                        isCompleted ? Colors.green[100] : Colors.orange[100];
                    final Color? fg =
                        isCompleted ? Colors.green[800] : Colors.orange[800];
                    final String label = isCompleted ? 'COMPLETED' : 'PENDING';
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: fg,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Description
            if (assignment['description'].isNotEmpty)
              Text(
                assignment['description'],
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),

            SizedBox(height: 8.h),

            // Created Date
            Row(
              children: [
                Icon(Icons.access_time, size: 16.sp, color: Colors.grey[500]),
                SizedBox(width: 4.w),
                Text(
                  'Created: ${_formatDate(assignment['createdAt'])}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // File Info and Actions
            Row(
              children: [
                Icon(Icons.attach_file, size: 16.sp, color: Colors.blue),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    assignment['fileName'],
                    style: TextStyle(fontSize: 14.sp, color: Colors.blue[600]),
                  ),
                ),
                // Download Button
                IconButton(
                  onPressed:
                      () => _downloadAssignment(
                        assignment['fileBase64'],
                        assignment['fileName'],
                      ),
                  icon: Icon(Icons.download, size: 20.sp, color: Colors.blue),
                  tooltip: 'Download Assignment',
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Upload Section
            if (assignment['hasSubmitted'] == true)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        assignment['submittedAt'] != null
                            ? 'Submitted on ${_formatDate(assignment['submittedAt'])}'
                            : 'Already submitted. Resubmission is disabled.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.green[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submit Your Work:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    UploadFileWidget(
                      onFilePicked: (base64, fileName) {
                        setState(() {
                          selectedFileBase64 = base64;
                          selectedFileName = fileName;
                        });
                      },
                      fileName: selectedFileName,
                      allowedExtensions: const [
                        'pdf',
                        'doc',
                        'docx',
                        'jpg',
                        'jpeg',
                        'png',
                      ],
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            selectedFileBase64 != null
                                ? () => _uploadAssignment(assignment['id'])
                                : null,
                        icon: const Icon(Icons.upload),
                        label: const Text('Submit Assignment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
