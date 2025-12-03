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
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  String? _selectedStudentUid;
  String? _editingGradeDocId; // Track which grade is being edited
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
          final data = s.data();
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
    if (!_formKey.currentState!.validate() || _selectedStudentUid == null) {
      return;
    }
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

      final subject = _subjectController.text.trim();
      final grade = _gradeController.text.trim();

      final gradeData = {
        'studentUid': _selectedStudentUid,
        'studentName': selectedStudent['childName'] ?? '',
        'class': _selectedClass!.gradeName,
        'classId': _selectedClass!.id,
        'subject': subject,
        'grade': grade,
        'teacherName': teacherName,
        'teacherEmail': teacherEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_editingGradeDocId != null) {
        // Update existing grade being edited
        await _firestore
            .collection('grades')
            .doc(_editingGradeDocId)
            .update(gradeData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' Grade Updated Successfully!')),
        );
        _editingGradeDocId = null;
      } else {
        // Check if grade already exists for this student+subject combination
        final existingGradeQuery =
            await _firestore
                .collection('grades')
                .where('studentUid', isEqualTo: _selectedStudentUid)
                .where('classId', isEqualTo: _selectedClass!.id)
                .where('subject', isEqualTo: subject)
                .limit(1)
                .get();

        if (existingGradeQuery.docs.isNotEmpty) {
          // Update existing grade
          await _firestore
              .collection('grades')
              .doc(existingGradeQuery.docs.first.id)
              .update(gradeData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(' Grade Updated Successfully!')),
          );
        } else {
          // Add new grade
          await _firestore.collection('grades').add(gradeData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(' Grade Added Successfully!')),
          );
        }
      }

      _subjectController.clear();
      _gradeController.clear();
      _selectedStudentUid = null;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(' Failed to save grade: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _editGrade(
    String docId,
    String currentSubject,
    String currentGrade,
  ) async {
    // Find the student UID from the grade document
    final gradeDoc = await _firestore.collection('grades').doc(docId).get();
    if (gradeDoc.exists) {
      final data = gradeDoc.data();
      setState(() {
        _editingGradeDocId = docId;
        _selectedStudentUid = data?['studentUid'];
        _subjectController.text = currentSubject;
        _gradeController.text = currentGrade;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const lavender = Color(0xFFD9C3F7);
    const mintGreen = Color(0xFFB7E4C7);
    const lightYellow = Color(0xFFF7EBC3);
    const pink = Color(0xFFFFC8DD);
    const bgColor = Color(0xFFF7F5F2);

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
                              _loadStudentsForSelectedClass();
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
                              _editingGradeDocId =
                                  null; // Clear editing state when student changes
                              _subjectController.clear();
                              _gradeController.clear();
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
                                  : Icon(
                                    _editingGradeDocId != null
                                        ? Icons.update
                                        : Icons.save,
                                  ),
                          label: Text(
                            _isSaving
                                ? 'Saving...'
                                : (_editingGradeDocId != null
                                    ? 'Update Grade'
                                    : 'Save Grade'),
                          ),
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
                  stream: _firestore.collection('grades').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading grades: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Class ID: ${_selectedClass!.id}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: Text('No data available.'));
                    }

                    final grades = snapshot.data!.docs;

                    // Filter by classId or className as fallback
                    final filteredGrades =
                        grades.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final docClassId = data['classId'] ?? '';
                          final docClassName = data['class'] ?? '';
                          return docClassId == _selectedClass!.id ||
                              docClassName == _selectedClass!.gradeName;
                        }).toList();

                    if (filteredGrades.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.grade_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No grades found for this class.',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total grades in database: ${grades.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            if (grades.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Class ID: ${_selectedClass!.id}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    // Sort by student name client-side
                    filteredGrades.sort((a, b) {
                      final nameA =
                          (a.data() as Map<String, dynamic>)['studentName'] ??
                          '';
                      final nameB =
                          (b.data() as Map<String, dynamic>)['studentName'] ??
                          '';
                      return nameA.compareTo(nameB);
                    });

                    // Group grades by studentUid
                    final Map<String, List<Map<String, dynamic>>>
                    groupedGrades = {};
                    for (var doc in filteredGrades) {
                      final data = doc.data() as Map<String, dynamic>;
                      final studentUid = data['studentUid'] ?? '';
                      if (!groupedGrades.containsKey(studentUid)) {
                        groupedGrades[studentUid] = [];
                      }
                      groupedGrades[studentUid]!.add({
                        'docId': doc.id,
                        ...data,
                      });
                    }

                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: groupedGrades.length,
                      itemBuilder: (context, studentIndex) {
                        final studentUid = groupedGrades.keys.elementAt(
                          studentIndex,
                        );
                        final studentGrades = groupedGrades[studentUid]!;
                        final studentName =
                            studentGrades.first['studentName'] ?? 'Student';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Student Name Header
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.deepPurple,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      studentName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Subject Cards in a Wrap
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children:
                                    studentGrades.map((gradeData) {
                                      final docId = gradeData['docId'];
                                      final subject =
                                          gradeData['subject'] ?? '';
                                      final grade = gradeData['grade'] ?? '';
                                      final cardIndex = studentGrades.indexOf(
                                        gradeData,
                                      );
                                      final cardColor =
                                          cardIndex.isEven
                                              ? mintGreen.withOpacity(0.4)
                                              : lightYellow.withOpacity(0.5);

                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.deepPurple
                                                .withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.school,
                                              color: Colors.deepPurple,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  subject,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  'Grade: $grade',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Colors.deepPurple,
                                                size: 20,
                                              ),
                                              onPressed:
                                                  () => _editGrade(
                                                    docId,
                                                    subject,
                                                    grade,
                                                  ),
                                              tooltip: 'Edit Grade',
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
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
