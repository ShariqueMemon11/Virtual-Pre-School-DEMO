import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_vps/Model/attendance_model.dart';

class AttendanceController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mark attendance for a student
  Future<void> markAttendance({
    required String studentId,
    required String studentName,
    required String classId,
    required String className,
    required DateTime date,
    required String status,
    required String teacherId,
    required String teacherName,
  }) async {
    // Normalize date to start of day
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dateTimestamp = Timestamp.fromDate(normalizedDate);

    // Create unique ID: studentId_date
    final attendanceId = '${studentId}_${normalizedDate.year}${normalizedDate.month.toString().padLeft(2, '0')}${normalizedDate.day.toString().padLeft(2, '0')}';

    final attendance = Attendance(
      studentId: studentId,
      studentName: studentName,
      classId: classId,
      className: className,
      date: dateTimestamp,
      status: status,
      markedBy: teacherId,
      markedByName: teacherName,
      markedAt: Timestamp.now(),
    );

    // Use set with merge to allow updates
    await _firestore
        .collection('attendance')
        .doc(attendanceId)
        .set(attendance.toMap(), SetOptions(merge: true));
  }

  /// Get attendance for a specific date and class
  Future<List<Map<String, dynamic>>> getAttendanceByDateAndClass(
    DateTime date,
    String classId,
  ) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dateTimestamp = Timestamp.fromDate(normalizedDate);

    final snapshot = await _firestore
        .collection('attendance')
        .where('date', isEqualTo: dateTimestamp)
        .where('classId', isEqualTo: classId)
        .get();

    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  /// Get attendance for a student
  Future<List<Map<String, dynamic>>> getStudentAttendance(
    String studentId,
  ) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .get();

    final attendanceList = snapshot.docs.map((doc) => doc.data()).toList();
    
    // Sort by date descending
    attendanceList.sort((a, b) {
      final dateA = a['date'] as Timestamp;
      final dateB = b['date'] as Timestamp;
      return dateB.compareTo(dateA);
    });

    return attendanceList;
  }

  /// Calculate attendance percentage
  Future<Map<String, dynamic>> getAttendanceStats(String studentId) async {
    final attendanceList = await getStudentAttendance(studentId);
    
    final totalDays = attendanceList.length;
    final presentDays = attendanceList.where((a) => a['status'] == 'present').length;
    final absentDays = totalDays - presentDays;
    final percentage = totalDays > 0 ? (presentDays / totalDays * 100) : 0.0;

    return {
      'totalDays': totalDays,
      'presentDays': presentDays,
      'absentDays': absentDays,
      'percentage': percentage,
    };
  }

  /// Get students in a class
  Future<List<Map<String, dynamic>>> getStudentsInClass(String classId) async {
    print('🔍 Controller: Getting students for classId: "$classId"');
    
    // First, let's see ALL students
    final allStudents = await _firestore.collection('Students').get();
    print('📊 Controller: Total students in database: ${allStudents.docs.length}');
    
    if (allStudents.docs.isNotEmpty) {
      print('📋 Controller: First student sample: ${allStudents.docs.first.data()}');
      // Check what assignedClass values exist
      for (var doc in allStudents.docs.take(3)) {
        final data = doc.data();
        print('   Student: ${data['childName']}, assignedClass: "${data['assignedClass']}"');
      }
    }
    
    final snapshot = await _firestore
        .collection('Students')
        .where('assignedClass', isEqualTo: classId)
        .get();

    print('📊 Controller: Found ${snapshot.docs.length} students with assignedClass="$classId"');
    
    final students = snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
    
    if (students.isNotEmpty) {
      print('📋 Controller: First student data: ${students[0]}');
    }
    
    return students;
  }
}
