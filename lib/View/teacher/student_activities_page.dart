// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentActivitiesPage extends StatefulWidget {
  const StudentActivitiesPage({super.key});

  @override
  State<StudentActivitiesPage> createState() => _StudentActivitiesPageState();
}

class _StudentActivitiesPageState extends State<StudentActivitiesPage> {
  final _firestore = FirebaseFirestore.instance;
  List<String> _teacherClassIds = [];
  bool _isLoadingClasses = true;

  Future<void> _loadTeacherClasses() async {
    try {
      // Find this teacher's classes (same logic as upload_material)
      final userDoc =
          await _firestore
              .collection('Teachers')
              .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
              .limit(1)
              .get();
      String? teacherDocId;
      String? displayName;
      if (userDoc.docs.isNotEmpty) {
        final doc = userDoc.docs.first;
        final data = doc.data();
        teacherDocId = doc.id;
        displayName =
            (data['name'] ?? data['teacherName'] ?? data['fullName'])?.toString();
      }

      QuerySnapshot<Map<String, dynamic>> classSnapshot;
      if (teacherDocId != null) {
        classSnapshot =
            await _firestore
                .collection('classes')
                .where('teacherid', isEqualTo: teacherDocId)
                .get();
      } else if (displayName != null && displayName.isNotEmpty) {
        classSnapshot =
            await _firestore
                .collection('classes')
                .where('teacher', isEqualTo: displayName)
                .get();
      } else {
        classSnapshot = await _firestore.collection('classes').get();
      }

      final ids = classSnapshot.docs.map((d) => d.id).toList();
      setState(() {
        _teacherClassIds = ids;
        _isLoadingClasses = false;
      });
    } catch (_) {
      setState(() {
        _teacherClassIds = [];
        _isLoadingClasses = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTeacherClasses();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _submissionsStream() {
    return _firestore
        .collection('student_submissions')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    final d = ts.toDate();
    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _downloadSubmission(
    Map<String, dynamic> data,
  ) async {
    try {
      final String fileName = data['fileName'] ?? 'submission';
      final String fileBase64 = data['fileBase64'] ?? '';
      if (fileBase64.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file data available for download')),
        );
        return;
      }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading submission: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Submissions', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFD9C3F7),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submissions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingClasses)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _submissionsStream(),
                builder: (context, snapshot) {
                  // No need to gate by teacherEmail here since we're showing
                  // all submissions stored in the shared collection.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No submissions yet.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    if (_teacherClassIds.isEmpty) return true;
                    final data = doc.data();
                    final classId = data['classId'] as String?;
                    if (classId == null || classId.isEmpty) return false;
                    return _teacherClassIds.contains(classId);
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No submissions yet for your classes.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final assignmentTitle =
                          data['assignmentTitle'] ?? 'Assignment';
                      final studentName = data['studentName'] ?? 'Student';
                      final submittedAt = data['submittedAt'] as Timestamp?;
                      final fileName = data['fileName'] ?? '';
                      final status = data['status'] ?? 'submitted';

                      final isReviewed = (data['reviewStatus'] == 'reviewed');
                      final chipColor =
                          isReviewed ? Colors.green[100] : Colors.orange[100];
                      final chipTextColor =
                          isReviewed ? Colors.green[800] : Colors.orange[800];
                      final chipLabel =
                          isReviewed ? 'REVIEWED' : status.toString().toUpperCase();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      assignmentTitle,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: chipColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      chipLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: chipTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Student: $studentName',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Submitted: ${_formatDate(submittedAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (fileName.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.attach_file,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        fileName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.download,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                      tooltip: 'Download submission',
                                      onPressed: () => _downloadSubmission(data),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


