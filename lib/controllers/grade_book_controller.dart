import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/student_data.dart';
import '../Model/class_model.dart';
import '../Model/grade_model.dart';

class GradeBookController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Get classes by category
  Future<List<ClassModel>> getClassesByCategory(String category) async {
    final snapshot =
        await _firestore
            .collection('classes')
            .where('category', isEqualTo: category)
            .get();
    return snapshot.docs.map((doc) => ClassModel.fromFirestore(doc)).toList();
  }

  // 🔹 Get grades of a specific student
  Stream<List<GradeModel>> getStudentGrades(String studentUid) {
    return _firestore
        .collection('grades')
        .where('studentUid', isEqualTo: studentUid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => GradeModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // 🔹 Promote or demote student
  Future<void> promoteStudent({
    required StudentData student,
    required String? newClassId,
    required String category,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // 1️⃣ Move current grades to past_grades
    final gradesSnapshot =
        await firestore
            .collection('grades')
            .where('studentUid', isEqualTo: student.id)
            .get();

    for (var doc in gradesSnapshot.docs) {
      final data = doc.data();
      final pastRef = firestore.collection('past_grades').doc();

      batch.set(pastRef, {
        'studentUid': student.id,
        'studentName': student.childName,
        'subject': data['subject'],
        'grade': data['grade'],
        'teacherName': data['teacherName'],
        'previousClass': student.assignedClass,
        'movedAt': FieldValue.serverTimestamp(),
      });

      batch.delete(doc.reference);
    }

    // 🔹 Handle graduating / passing out
    if (category == "KG Final") {
      // Move student to 'graduated' collection
      final graduatedRef = firestore.collection('graduated').doc(student.id);
      batch.set(graduatedRef, {
        'childName': student.childName,
        'fatherName': student.fatherName,
        'motherName': student.motherName,
        'fatherCell': student.fatherCell,
        'motherCell': student.motherCell,
        'email': student.email,
        'age': student.age,
        'dateOfBirth': student.dateOfBirth,
        'assignedClass': student.assignedClass,
        'category': 'graduated',
        'graduatedAt': FieldValue.serverTimestamp(),
      });

      // Remove student from old class's studentEnrolled
      if (student.assignedClass != null && student.assignedClass!.isNotEmpty) {
        final oldClassRef = firestore
            .collection('classes')
            .doc(student.assignedClass);
        batch.update(oldClassRef, {
          'studentEnrolled': FieldValue.arrayRemove([student.id]),
          'studentCount': FieldValue.increment(-1),
        });
      }

      // Delete student from Students collection
      final studentRef = firestore.collection('Students').doc(student.id);
      batch.delete(studentRef);

      await batch.commit();
      return;
    }

    // 🔹 Regular promotion (not graduating)
    final studentRef = firestore.collection('Students').doc(student.id);
    batch.update(studentRef, {
      'assignedClass': newClassId,
      'category': category,
    });

    // Remove from old class
    if (student.assignedClass != null && student.assignedClass!.isNotEmpty) {
      final oldClassRef = firestore
          .collection('classes')
          .doc(student.assignedClass);
      batch.update(oldClassRef, {
        'studentEnrolled': FieldValue.arrayRemove([student.id]),
        'studentCount': FieldValue.increment(-1),
      });
    }

    // Add to new class
    final newClassRef = firestore.collection('classes').doc(newClassId);
    batch.update(newClassRef, {
      'studentEnrolled': FieldValue.arrayUnion([student.id]),
      'studentCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // 🔹 Graduate student (archive completely)
  Future<void> graduateStudent({required StudentData student}) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // 1️⃣ Move current grades to past_grades
    final gradesSnapshot =
        await firestore
            .collection('grades')
            .where('studentUid', isEqualTo: student.id)
            .get();

    for (var doc in gradesSnapshot.docs) {
      final data = doc.data();
      final pastRef = firestore.collection('past_grades').doc();

      batch.set(pastRef, {
        'studentUid': student.id,
        'studentName': student.childName,
        'subject': data['subject'],
        'grade': data['grade'],
        'teacherName': data['teacherName'],
        'previousClass': student.assignedClass,
        'movedAt': FieldValue.serverTimestamp(),
        'graduated': true,
      });

      batch.delete(doc.reference);
    }

    // 2️⃣ Remove student from old class
    if (student.assignedClass != null && student.assignedClass!.isNotEmpty) {
      final oldClassRef = firestore
          .collection('classes')
          .doc(student.assignedClass);
      batch.update(oldClassRef, {
        'studentEnrolled': FieldValue.arrayRemove([student.id]),
        'studentCount': FieldValue.increment(-1),
      });
    }

    // 3️⃣ Move student document to graduates collection
    final studentRef = firestore.collection('Students').doc(student.id);
    final graduateRef = firestore.collection('Graduates').doc(student.id);

    batch.set(graduateRef, {
      ...student.toMap(), // convert student model to Map
      'graduationDate': FieldValue.serverTimestamp(),
      'status': 'graduated',
    });

    // 4️⃣ Delete from original Students collection
    batch.delete(studentRef);

    // 5️⃣ Commit batch
    await batch.commit();
  }
}
