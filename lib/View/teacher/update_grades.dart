// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_vps/Model/class_model.dart';

class UpdateGradesPage extends StatefulWidget {
  const UpdateGradesPage({super.key});

  @override
  State<UpdateGradesPage> createState() => _UpdateGradesPageState();
}

class _UpdateGradesPageState extends State<UpdateGradesPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  String? _selectedStudentUid; // <-- Add this
  List<Map<String, dynamic>> _studentsInClass = []; // [{uid, name, email}]

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSaving = false;
  ClassModel? _selectedClass;
  bool _isClassListLoading = true;
  List<ClassModel> _availableClasses = [];
  String? _teacherDisplayName;
  String? _teacherEmail;

  @override
  void initState() {
    super.initState();
    _loadAssignedClasses();
  }

  Future<void> _loadAssignedClasses() async {
    setState(() {
      _isClassListLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _availableClasses = [];
          _selectedClass = null;
          _teacherDisplayName = null;
          _teacherEmail = null;
          _isClassListLoading = false;
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
        _availableClasses = classes;
        _selectedClass = classes.isNotEmpty ? classes.first : null;
        _teacherDisplayName = displayName;
        _teacherEmail = email;
        _isClassListLoading = false;
      });
      if (_selectedClass != null) {
        await _loadStudentsForSelectedClass();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _availableClasses = [];
        _selectedClass = null;
        _isClassListLoading = false;
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
          final data = s.data() as Map<String, dynamic>;
          return {
            'uid': s.id,
            'childName': data['childName'] ?? 'Student',
            'email': data['email'] ?? '',
          };
        }).toList();
    if (_studentsInClass.isNotEmpty) {
      _selectedStudentUid ??= _studentsInClass.first['uid'];
      // _studentNameController.text = _studentsInClass.first['childName']; // Removed
    }
    setState(() {});
  }

  Future<void> _saveGrade() async {
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class first')),
      );
      return;
    }
    if (!_formKey.currentState!.validate() || _selectedStudentUid == null)
      return;
    setState(() => _isSaving = true);
    try {
      final teacher = _auth.currentUser;
      final teacherName =
          _teacherDisplayName ??
          teacher?.displayName ??
          (teacher?.email?.split('@').first ?? 'Unknown Teacher');
      final teacherEmail = _teacherEmail ?? teacher?.email ?? 'Unknown Email';
      final selectedStudent = _studentsInClass.firstWhere(
        (x) => x['uid'] == _selectedStudentUid,
        orElse: () => {},
      );
      await _firestore.collection('grades').add({
        'studentUid': _selectedStudentUid,
        'studentName': selectedStudent['childName'] ?? '',
        'class': _selectedClass!.gradeName,
        'classId': _selectedClass!.id,
        'subject': _subjectController.text.trim(),
        'grade': _gradeController.text.trim(),
        'teacherName': teacherName,
        'teacherEmail': teacherEmail,
        'updatedAt': DateTime.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Grade Added Successfully!')),
      );
      _subjectController.clear();
      _gradeController.clear();
      _selectedStudentUid = null;
      await _loadStudentsForSelectedClass();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(' Failed to add grade: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteGrade(String docId) async {
    await _firestore.collection('grades').doc(docId).delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(' Grade deleted')));
  }

  @override
  Widget build(BuildContext context) {
    const lavender = Color(0xFFD9C3F7);
    const mintGreen = Color(0xFFB7E4C7);
    const lightYellow = Color(0xFFF7EBC3);
    const pink = Color(0xFFFFC8DD);
    const bgColor = Color(0xFFF7F5F2);

    final teacherEmail = _teacherEmail ?? _auth.currentUser?.email;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: lavender,
        title: const Text(
          'Update Grades',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add or Update Student Grades',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              //  Class Dropdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child:
                    _isClassListLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _availableClasses.isEmpty
                        ? Column(
                          children: const [
                            Icon(Icons.info_outline, color: Colors.deepPurple),
                            SizedBox(height: 8),
                            Text(
                              'No classes assigned yet. Please contact admin.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                        : DropdownButtonFormField<String>(
                          value: _selectedClass?.id,
                          decoration: InputDecoration(
                            hintText: 'Select Class',
                            prefixIcon: const Icon(
                              Icons.class_,
                              color: Colors.deepPurple,
                            ),
                            filled: true,
                            fillColor: mintGreen.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items:
                              _availableClasses
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(c.gradeName),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedClass = _availableClasses.firstWhere(
                                (c) => c.id == value,
                              );
                            });
                          },
                          validator:
                              (value) =>
                                  value == null
                                      ? 'Please select a class'
                                      : null,
                        ),
              ),

              const SizedBox(height: 20),

              //  Add Grade Form
              if (_selectedClass != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Student Name Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedStudentUid,
                          items:
                              _studentsInClass.map((student) {
                                return DropdownMenuItem<String>(
                                  value: student['uid'] as String,
                                  child: Text(student['childName']),
                                );
                              }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedStudentUid = val;
                              // no _studentNameController
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Select Student',
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.deepPurple,
                            ),
                            filled: true,
                            fillColor: lavender.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator:
                              (v) => v == null ? 'Select a student' : null,
                        ),
                        SizedBox(height: 12),
                        _buildTextField(
                          _subjectController,
                          'Subject',
                          Icons.book,
                          lightYellow,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          _gradeController,
                          'Grade (A+, A, B, etc.)',
                          Icons.grade,
                          pink,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveGrade,
                          icon:
                              _isSaving
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.save),
                          label: Text(_isSaving ? 'Saving...' : 'Save Grade'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lavender,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_selectedClass != null) ...[
                const SizedBox(height: 30),
                Text(
                  'Grades for ${_selectedClass!.gradeName}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                StreamBuilder<QuerySnapshot>(
                  stream:
                      _firestore
                          .collection('grades')
                          .where('classId', isEqualTo: _selectedClass!.id)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No grades found for this class.'),
                      );
                    }
                    final docs = snapshot.data!.docs;
                    // Map uid -> {name, grades: [{subject, grade}]}
                    final Map<String, Map<String, dynamic>> studentToGrades =
                        {};
                    for (var doc in docs) {
                      final d = doc.data() as Map<String, dynamic>;
                      final uid = d['studentUid'] ?? '';
                      if (uid.isEmpty) continue;
                      studentToGrades.putIfAbsent(
                        uid,
                        () => {
                          'name': d['studentName'] ?? 'Student',
                          'grades': <Map<String, String>>[],
                        },
                      );
                      (studentToGrades[uid]!['grades']
                              as List<Map<String, String>>)
                          .add({
                            'subject': (d['subject'] ?? '').toString(),
                            'grade': (d['grade'] ?? '').toString(),
                          });
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: studentToGrades.length,
                      itemBuilder: (context, idx) {
                        final entry = studentToGrades.entries.elementAt(idx);
                        final name = entry.value['name'];
                        final grades =
                            entry.value['grades'] as List<Map<String, String>>;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                idx.isEven
                                    ? mintGreen.withOpacity(0.4)
                                    : lightYellow.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.school, color: Colors.deepPurple),
                              SizedBox(width: 12),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  children:
                                      grades
                                          .map(
                                            (g) => Chip(
                                              label: Text(
                                                "${g['subject']}: ${g['grade']}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              backgroundColor: Colors.deepPurple
                                                  .withOpacity(0.12),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignedStudentsList(Color mintGreen, Color lightYellow) {
    if (_selectedClass == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('Students')
                .where('assignedClass', isEqualTo: _selectedClass!.id)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No students assigned to this class yet.'),
            );
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final data = students[index].data() as Map<String, dynamic>;
              final bgColor =
                  index.isEven
                      ? mintGreen.withOpacity(0.3)
                      : lightYellow.withOpacity(0.3);

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.deepPurple),
                  title: Text(data['childName'] ?? 'Student'),
                  subtitle: Text(data['email'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }

  //  Reusable Field Builder
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    Color color,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: color.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Enter $label' : null,
    );
  }
}
