import 'package:demo_vps/View/admin/gradebook/student_grade_book.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../controllers/student_assign_controller.dart';
import '../../../Model/student_data.dart';
import '../../../Model/class_model.dart';

class GradeOverviewExpandable extends StatefulWidget {
  const GradeOverviewExpandable({super.key});

  @override
  State<GradeOverviewExpandable> createState() =>
      _GradeOverviewExpandableState();
}

class _GradeOverviewExpandableState extends State<GradeOverviewExpandable> {
  final StudentController controller = StudentController();
  Map<String, List<ClassModel>> groupedClasses = {};

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  Future<void> loadClasses() async {
    final classes = await controller.getClasses();

    final Map<String, List<ClassModel>> temp = {};
    for (var c in classes) {
      temp.putIfAbsent(c.category, () => []);
      temp[c.category]!.add(c);
    }

    setState(() {
      groupedClasses = temp;
    });
  }

  /// Check if student has at least 1 grade
  Future<bool> hasGrades(String studentId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('grades')
            .where('studentUid', isEqualTo: studentId)
            .limit(1)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Grade Overview",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 142, 88, 235),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<StudentData>>(
        stream: controller.getStudents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children:
                groupedClasses.entries.map((entry) {
                  final category = entry.key;
                  final classes = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CATEGORY TITLE
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // CLASSES UNDER CATEGORY
                      ...classes.map((classModel) {
                        final classStudents =
                            students
                                .where((s) => s.assignedClass == classModel.id)
                                .toList();

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ExpansionTile(
                            title: Text(
                              "${classModel.gradeName} (${classModel.studentCount}/${classModel.capacity})",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            children:
                                classStudents.map((student) {
                                  if (student.id == null) {
                                    return const SizedBox();
                                  }

                                  return FutureBuilder<bool>(
                                    future: hasGrades(student.id!),
                                    builder: (context, snap) {
                                      if (!snap.hasData || snap.data == false) {
                                        return const SizedBox();
                                      }

                                      return ListTile(
                                        leading: const Icon(
                                          Icons.person,
                                          color: Colors.deepPurple,
                                        ),
                                        title: Text(
                                          student.childName ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: Colors.deepPurple,
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          _,
                                                        ) => StudentGradeBookScreen(
                                                          studentId:
                                                              student.id!,
                                                          studentName:
                                                              student
                                                                  .childName ??
                                                              '',
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                          ),
                        );
                      }),

                      const SizedBox(height: 20),
                    ],
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
