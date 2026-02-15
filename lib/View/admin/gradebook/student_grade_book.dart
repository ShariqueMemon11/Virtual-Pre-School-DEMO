// ignore_for_file: use_build_context_synchronously

import 'package:demo_vps/controllers/grade_book_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Model/student_data.dart';
import '../../../Model/class_model.dart';
import '../../../Model/grade_model.dart';

// ========================
// MAIN SCREEN
// ========================
class StudentGradeBookScreen extends StatelessWidget {
  final String studentId;
  final String studentName;

  const StudentGradeBookScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  Color getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade.startsWith('B')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final controller = GradeBookController();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "$studentName - Grade Book",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 142, 88, 235),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Students')
                .doc(studentId)
                .snapshots(),
        builder: (context, studentSnapshot) {
          if (!studentSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!studentSnapshot.data!.exists) {
            return const Center(child: Text("Student not found"));
          }

          final student = StudentData.fromFirestore(studentSnapshot.data!);

          return Column(
            children: [
              // ================= PROFILE =================
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.childName ?? '',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: [
                        _infoItem("Father", student.fatherName),
                        _infoItem("Age", student.age),
                        _infoItem(
                          "DOB",
                          student.dateOfBirth?.toString().split(' ')[0],
                        ),
                        _infoItem("Email", student.email),
                        _infoItem("Father Phone", student.fatherCell),
                        _infoItem("Mother Phone", student.motherCell),
                        _infoItem("Class", student.assignedClass),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ================= MANAGE STUDENT BUTTON =================
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          142,
                          88,
                          235,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => ManageStudentDialog(
                                student: student,
                                controller: controller,
                              ),
                        );
                      },
                      child: const Text(
                        "Promote / Demote / Graduate",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ================= GRADES =================
              Expanded(
                child: StreamBuilder<List<GradeModel>>(
                  stream: controller.getStudentGrades(student.id!),
                  builder: (context, gradeSnapshot) {
                    if (!gradeSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final grades = gradeSnapshot.data!;

                    if (grades.isEmpty) {
                      return const Center(child: Text("No grades found"));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: grades.length,
                      itemBuilder: (context, index) {
                        final grade = grades[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    grade.subject,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Teacher: ${grade.teacherName}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: getGradeColor(
                                    grade.grade,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  grade.grade,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: getGradeColor(grade.grade),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoItem(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(height: 3),
        Text(
          value ?? "-",
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
      ],
    );
  }
}

// ========================
// MANAGE STUDENT MODAL
// ========================
class ManageStudentDialog extends StatefulWidget {
  final StudentData student;
  final GradeBookController controller;

  const ManageStudentDialog({
    super.key,
    required this.student,
    required this.controller,
  });

  @override
  State<ManageStudentDialog> createState() => _ManageStudentDialogState();
}

class _ManageStudentDialogState extends State<ManageStudentDialog> {
  String? selectedCategory;
  String? selectedClass;
  List<ClassModel> classes = [];
  bool loadingClasses = false;

  final List<String> categories = [
    "Playgroup",
    "Nursery",
    "Kindergarten",
  ]; // KG Final removed

  Future<void> loadClassesByCategory(String category) async {
    setState(() {
      loadingClasses = true;
      classes = [];
      selectedClass = null;
    });

    try {
      final result = await widget.controller.getClassesByCategory(category);
      setState(() {
        classes = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading classes: $e")));
    } finally {
      setState(() {
        loadingClasses = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Manage ${widget.student.childName}"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ================= PROMOTION / DEMOTION =================
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: "Select Category",
                prefixIcon: Icon(Icons.category),
              ),
              items:
                  categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
              onChanged: (val) {
                setState(() {
                  selectedCategory = val;
                  selectedClass = null;
                  classes = [];
                });
                if (val != null) loadClassesByCategory(val);
              },
            ),
            const SizedBox(height: 16),
            if (selectedCategory != null)
              loadingClasses
                  ? const Center(child: CircularProgressIndicator())
                  : classes.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("No classes available in this category"),
                  )
                  : DropdownButtonFormField<String>(
                    value: selectedClass,
                    decoration: const InputDecoration(
                      labelText: "Select Class",
                      prefixIcon: Icon(Icons.class_),
                    ),
                    items:
                        classes
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  "${c.gradeName} (${c.studentCount}/${c.capacity})",
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedClass = val;
                      });
                    },
                  ),
            const SizedBox(height: 16),
            // ================= GRADUATE BUTTON =================
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text("Graduate Student?"),
                        content: const Text(
                          "This will archive all grades and mark the student as a past student.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Graduate"),
                          ),
                        ],
                      ),
                );

                if (confirmed != true) return;

                await widget.controller.graduateStudent(
                  student: widget.student,
                );

                if (!context.mounted) return;
                Navigator.pop(context); // close dialog
              },
              child: const Text("Graduate / Archive"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed:
              (selectedCategory != null && selectedClass != null)
                  ? _confirmPromotion
                  : null,
          child: const Text("Promote/Demote"),
        ),
      ],
    );
  }

  Future<void> _confirmPromotion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Are you sure?"),
            content: const Text(
              "All grades will be archived and student will be moved to the selected class.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes"),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    await widget.controller.promoteStudent(
      student: widget.student,
      newClassId: selectedClass!,
      category: "complete", // always complete now
    );

    if (!context.mounted) return;
    Navigator.pop(context);
  }
}
