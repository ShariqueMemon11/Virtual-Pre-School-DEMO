import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_vps/Model/class_model.dart';

class AdminViewAttendanceScreen extends StatefulWidget {
  const AdminViewAttendanceScreen({super.key});

  @override
  State<AdminViewAttendanceScreen> createState() => _AdminViewAttendanceScreenState();
}

class _AdminViewAttendanceScreenState extends State<AdminViewAttendanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ClassModel> _availableClasses = [];
  ClassModel? _selectedClass;
  List<Map<String, dynamic>> _studentAttendanceData = [];
  bool _isLoadingClasses = true;
  bool _isLoadingStudents = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoadingClasses = true);
    
    try {
      final classSnapshot = await _firestore.collection('classes').get();
      final classes = classSnapshot.docs
          .map((doc) => ClassModel.fromFirestore(doc))
          .toList();
      
      setState(() {
        _availableClasses = classes;
        _selectedClass = classes.isNotEmpty ? classes.first : null;
        _isLoadingClasses = false;
      });
      
      if (_selectedClass != null) {
        await _loadStudentAttendance();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingClasses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading classes: $e')),
      );
    }
  }

  Future<void> _loadStudentAttendance() async {
    if (_selectedClass == null) return;
    
    setState(() => _isLoadingStudents = true);
    
    try {
      // Get all students in the selected class
      final studentsSnapshot = await _firestore
          .collection('Students')
          .where('assignedClass', isEqualTo: _selectedClass!.id)
          .get();
      
      List<Map<String, dynamic>> attendanceData = [];
      
      for (var studentDoc in studentsSnapshot.docs) {
        final studentData = studentDoc.data();
        final studentId = studentDoc.id;
        final studentName = studentData['childName'] ?? 'Student';
        
        // Get all attendance records for this student
        final attendanceSnapshot = await _firestore
            .collection('attendance')
            .where('studentId', isEqualTo: studentId)
            .where('classId', isEqualTo: _selectedClass!.id)
            .get();
        
        int totalDays = attendanceSnapshot.docs.length;
        int presentDays = attendanceSnapshot.docs
            .where((doc) => doc.data()['status'] == 'present')
            .length;
        int absentDays = totalDays - presentDays;
        double percentage = totalDays > 0 ? (presentDays / totalDays * 100) : 0.0;
        
        attendanceData.add({
          'studentId': studentId,
          'studentName': studentName,
          'email': studentData['email'] ?? '',
          'totalDays': totalDays,
          'presentDays': presentDays,
          'absentDays': absentDays,
          'percentage': percentage,
        });
      }
      
      // Sort by student name
      attendanceData.sort((a, b) => 
        (a['studentName'] as String).compareTo(b['studentName'] as String)
      );
      
      if (!mounted) return;
      setState(() {
        _studentAttendanceData = attendanceData;
        _isLoadingStudents = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingStudents = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading attendance: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8F7CFF),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Student Attendance',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoadingClasses
          ? const Center(child: CircularProgressIndicator())
          : _availableClasses.isEmpty
              ? const Center(
                  child: Text('No classes available'),
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Class selector
                      const Text(
                        'Select Class',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedClass?.id,
                            isExpanded: true,
                            items: _availableClasses.map((classModel) {
                              return DropdownMenuItem(
                                value: classModel.id,
                                child: Text(
                                  classModel.gradeName,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedClass = _availableClasses.firstWhere(
                                  (c) => c.id == value,
                                );
                              });
                              _loadStudentAttendance();
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Class summary card
                      if (_selectedClass != null && !_isLoadingStudents)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8F7CFF), Color(0xFFB39DFF)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem(
                                'Teacher',
                                _selectedClass!.teacher ?? 'Not Assigned',
                                Icons.person,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              _buildSummaryItem(
                                'Students',
                                _studentAttendanceData.length.toString(),
                                Icons.people,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              _buildSummaryItem(
                                'Avg Attendance',
                                _studentAttendanceData.isEmpty
                                    ? '0%'
                                    : '${(_studentAttendanceData.map((s) => s['percentage'] as double).reduce((a, b) => a + b) / _studentAttendanceData.length).toStringAsFixed(1)}%',
                                Icons.analytics,
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Student attendance list
                      Expanded(
                        child: _isLoadingStudents
                            ? const Center(child: CircularProgressIndicator())
                            : _studentAttendanceData.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No students in this class',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _studentAttendanceData.length,
                                    itemBuilder: (context, index) {
                                      final student = _studentAttendanceData[index];
                                      return _buildStudentCard(student);
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final percentage = student['percentage'] as double;
    final presentDays = student['presentDays'] as int;
    final absentDays = student['absentDays'] as int;
    final totalDays = student['totalDays'] as int;
    
    Color percentageColor;
    if (percentage >= 75) {
      percentageColor = Colors.green;
    } else if (percentage >= 50) {
      percentageColor = Colors.orange;
    } else {
      percentageColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Student avatar and info
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF8F7CFF),
              child: Text(
                student['studentName'][0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['studentName'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    student['email'],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Stats in compact row
            Row(
              children: [
                _buildCompactStat(totalDays.toString(), 'Days', Colors.blue),
                const SizedBox(width: 12),
                _buildCompactStat(presentDays.toString(), 'Present', Colors.green),
                const SizedBox(width: 12),
                _buildCompactStat(absentDays.toString(), 'Absent', Colors.red),
                const SizedBox(width: 16),
                // Percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: percentageColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: percentageColor, width: 1.5),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: percentageColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
