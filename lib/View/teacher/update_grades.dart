// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSaving = false;
  String? _selectedClass;

  final List<String> _classes = [
    'Grade KG-A',
    'Grade KG-B',
    'Grade PG-A',
    'Grade PG-B',
    'Grade 1-A',
    'Grade 1-B',
  ];

  Future<void> _saveGrade() async {
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class first')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final teacher = _auth.currentUser;
      final teacherName = teacher?.displayName ?? 'Unknown Teacher';
      final teacherEmail = teacher?.email ?? 'Unknown Email';

      await _firestore.collection('grades').add({
        'studentName': _studentNameController.text.trim(),
        'class': _selectedClass!,
        'subject': _subjectController.text.trim(),
        'grade': _gradeController.text.trim(),
        'teacherName': teacherName,
        'teacherEmail': teacherEmail,
        'updatedAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Grade Added Successfully!')),
      );

      _studentNameController.clear();
      _subjectController.clear();
      _gradeController.clear();
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

    final teacherEmail = _auth.currentUser?.email;

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
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedClass,
                      decoration: InputDecoration(
                        labelText: 'Select Class',
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
                      items: _classes
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClass = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a class' : null,
                    ),
                  ],
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
                        _buildTextField(
                          _studentNameController,
                          'Student Name',
                          Icons.person,
                          lavender,
                        ),
                        const SizedBox(height: 12),
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
                          icon: _isSaving
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

              const SizedBox(height: 30),

              //  Show Grades of Selected Class
              if (_selectedClass != null) ...[
                Text(
                  'Grades for $_selectedClass',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('grades')
                      .where('teacherEmail', isEqualTo: teacherEmail)
                      .where('class', isEqualTo: _selectedClass)
                      .orderBy('updatedAt', descending: true)
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

                    final grades = snapshot.data!.docs;

                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: grades.length,
                      itemBuilder: (context, i) {
                        final data = grades[i];
                        final bgColor = i.isEven
                            ? mintGreen.withOpacity(0.4)
                            : lightYellow.withOpacity(0.5);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.school,
                              color: Colors.deepPurple,
                            ),
                            title: Text(
                              data['studentName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Subject: ${data['subject']} | Grade: ${data['grade']}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteGrade(data.id),
                            ),
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
        labelText: label,
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
