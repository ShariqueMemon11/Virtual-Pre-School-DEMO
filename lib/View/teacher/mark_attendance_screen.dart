// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_vps/Model/class_model.dart';
import 'package:intl/intl.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  List<Map<String, dynamic>> _studentsInClass = [];
  Map<String, String> attendanceStatus = {}; // studentId -> status

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  ClassModel? _selectedClass;
  String? _teacherDisplayName;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAssignedClasses();
  }

  Future<void> _loadAssignedClasses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _selectedClass = null;
          _teacherDisplayName = null;
          _isLoading = false;
        });
        return;
      }

      final email = user.email ?? '';
      String displayName =
          (user.displayName?.trim().isNotEmpty == true)
              ? user.displayName!.trim()
              : (email.isNotEmpty ? email.split('@').first : 'Teacher');
      String? docId;

      final teacherSnapshot =
          await _firestore
              .collection('Teachers')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (teacherSnapshot.docs.isNotEmpty) {
        final doc = teacherSnapshot.docs.first;
        final data = doc.data();
        docId = doc.id;
        displayName =
            (data['name'] as String?)?.trim().isNotEmpty == true
                ? data['name']
                : displayName;
      }

      QuerySnapshot<Map<String, dynamic>> classSnapshot;
      if (docId != null) {
        classSnapshot =
            await _firestore
                .collection('classes')
                .where('teacherid', isEqualTo: docId)
                .get();
      } else if (displayName.isNotEmpty) {
        classSnapshot =
            await _firestore
                .collection('classes')
                .where('teacher', isEqualTo: displayName)
                .get();
      } else {
        classSnapshot =
            await _firestore
                .collection('classes')
                .where('teacherEmail', isEqualTo: email)
                .get();
      }

      final classes =
          classSnapshot.docs
              .map((doc) => ClassModel.fromFirestore(doc))
              .toList();

      if (!mounted) return;
      setState(() {
        _selectedClass = classes.isNotEmpty ? classes.first : null;
        _teacherDisplayName = displayName;
        _isLoading = false;
      });
      if (_selectedClass != null) {
        await _loadStudentsForSelectedClass();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _selectedClass = null;
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load classes: $e')));
    }
  }

  Future<void> _loadStudentsForSelectedClass() async {
    _studentsInClass.clear();
    if (_selectedClass == null) return;
    
    final studentsSnap =
        await _firestore
            .collection('Students')
            .where('assignedClass', isEqualTo: _selectedClass!.id)
            .get();
    _studentsInClass =
        studentsSnap.docs.map((s) {
          final data = s.data();
          return {
            'uid': s.id,
            'childName': data['childName'] ?? 'Student',
            'email': data['email'] ?? '',
          };
        }).toList();
    
    // Load existing attendance for today
    final normalizedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final dateTimestamp = Timestamp.fromDate(normalizedDate);
    
    final existingAttendance = await _firestore
        .collection('attendance')
        .where('date', isEqualTo: dateTimestamp)
        .where('classId', isEqualTo: _selectedClass!.id)
        .get();
    
    // Initialize attendance status with existing data or default to absent
    attendanceStatus.clear();
    for (var student in _studentsInClass) {
      // Check if attendance already exists for this student
      try {
        final existingRecord = existingAttendance.docs.firstWhere(
          (doc) => doc.data()['studentId'] == student['uid'],
        );
        attendanceStatus[student['uid']] = existingRecord.data()['status'] ?? 'absent';
      } catch (e) {
        // No existing record, default to absent
        attendanceStatus[student['uid']] = 'absent';
      }
    }
    
    setState(() {});
  }

  Future<void> _saveAttendance() async {
    if (_selectedClass == null) return;
    
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Normalize date to start of day
      final normalizedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final dateTimestamp = Timestamp.fromDate(normalizedDate);

      // Save attendance for each student
      for (var student in _studentsInClass) {
        final studentId = student['uid'];
        final status = attendanceStatus[studentId] ?? 'absent';
        
        // Create unique ID: studentId_date
        final attendanceId = '${studentId}_${normalizedDate.year}${normalizedDate.month.toString().padLeft(2, '0')}${normalizedDate.day.toString().padLeft(2, '0')}';

        await _firestore.collection('attendance').doc(attendanceId).set({
          'studentId': studentId,
          'studentName': student['childName'],
          'classId': _selectedClass!.id,
          'className': _selectedClass!.gradeName,
          'date': dateTimestamp,
          'status': status,
          'markedBy': user.uid,
          'markedByName': _teacherDisplayName ?? 'Teacher',
          'markedAt': Timestamp.now(),
        }, SetOptions(merge: true));
      }

      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _markAllPresent() {
    setState(() {
      for (var student in _studentsInClass) {
        attendanceStatus[student['uid']] = 'present';
      }
    });
  }

  void _markAllAbsent() {
    setState(() {
      for (var student in _studentsInClass) {
        attendanceStatus[student['uid']] = 'absent';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mark Attendance',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAttendance,
            tooltip: 'Save Attendance',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedClass == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.info_outline, color: Colors.deepPurple, size: 64),
                      SizedBox(height: 16),
                      Text('No class assigned yet.', textAlign: TextAlign.center),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Date selector and bulk actions
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[100],
                      child: Column(
                        children: [
                          // Date selector
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('EEEE, MMM dd, yyyy').format(selectedDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.today, size: 16, color: Colors.green[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'TODAY ONLY',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Bulk actions
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _markAllPresent,
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  label: const Text('Mark All Present'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _markAllAbsent,
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  label: const Text('Mark All Absent'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Student list
                    Expanded(
                      child: _studentsInClass.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  const Text('No students in this class'),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _studentsInClass.length,
                              itemBuilder: (context, index) {
                                final student = _studentsInClass[index];
                                final studentId = student['uid'];
                                final status = attendanceStatus[studentId] ?? 'absent';
                                final isPresent = status == 'present';

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Student info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                student['childName'] ?? 'Student',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                student['email'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Toggle buttons
                                        Row(
                                          children: [
                                            // Present button
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  attendanceStatus[studentId] = 'present';
                                                });
                                              },
                                              icon: Icon(
                                                isPresent ? Icons.check_circle : Icons.check_circle_outline,
                                                size: 18,
                                              ),
                                              label: const Text('Present'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isPresent ? Colors.green : Colors.grey[300],
                                                foregroundColor: isPresent ? Colors.white : Colors.black87,
                                                elevation: isPresent ? 4 : 0,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Absent button
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  attendanceStatus[studentId] = 'absent';
                                                });
                                              },
                                              icon: Icon(
                                                !isPresent ? Icons.cancel : Icons.cancel_outlined,
                                                size: 18,
                                              ),
                                              label: const Text('Absent'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: !isPresent ? Colors.red : Colors.grey[300],
                                                foregroundColor: !isPresent ? Colors.white : Colors.black87,
                                                elevation: !isPresent ? 4 : 0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
