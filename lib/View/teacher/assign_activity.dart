// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AssignActivityPage extends StatefulWidget {
  const AssignActivityPage({super.key});

  @override
  State<AssignActivityPage> createState() => _AssignActivityPageState();
}

class _AssignActivityPageState extends State<AssignActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _classController = TextEditingController();
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? teacherName;
  String? teacherEmail;
  String? _fileName;
  String? _fileUrl;

  @override
  void initState() {
    super.initState();
    _loadTeacherInfo();
  }

  void _loadTeacherInfo() {
    final user = _auth.currentUser;
    setState(() {
      teacherEmail = user?.email ?? 'areeba@previrtual.edu.pk';
      teacherName = user?.displayName ?? 'Areeba Andleeb';
    });
  }

  // Pick a date
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  // Pick a time
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  // Pick file (PDF/Image)
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final ref = _storage.ref().child('activities/${file.name}');
      await ref.putData(file.bytes!);
      final url = await ref.getDownloadURL();

      setState(() {
        _fileName = file.name;
        _fileUrl = url;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File "${file.name}" uploaded successfully!')),
      );
    }
  }

  // Save Activity to Firestore
  Future<void> _saveActivity() async {
    if (_formKey.currentState!.validate() && _dueDate != null) {
      final dueDateTime = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        _dueTime?.hour ?? 0,
        _dueTime?.minute ?? 0,
      );

      await _firestore.collection('activities').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'class': _classController.text.trim(),
        'dueDate': Timestamp.fromDate(dueDateTime),
        'assignedAt': Timestamp.now(),
        'teacherName': teacherName ?? 'Areeba Andleeb',
        'teacherEmail': teacherEmail ?? 'areeba@previrtual.edu.pk',
        'fileName': _fileName ?? '',
        'fileUrl': _fileUrl ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Activity Assigned Successfully!')),
      );

      _titleController.clear();
      _descController.clear();
      _classController.clear();
      setState(() {
        _dueDate = null;
        _dueTime = null;
        _fileName = null;
        _fileUrl = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields properly')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const lavender = Color(0xFFD9C3F7);
    const lightYellow = Color(0xFFF7EBC3);
    const mintGreen = Color(0xFFB7E4C7);
    const pink = Color(0xFFFFC8DD);
    const bgColor = Color(0xFFF7F5F2);

    final isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: lavender,
        title: const Text(
          'Assign Activities',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isWideScreen
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildActivityForm(lavender, lightYellow, mintGreen),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: _buildActivityList(lavender, pink, lightYellow),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildActivityForm(lavender, lightYellow, mintGreen),
                    const SizedBox(height: 20),
                    _buildActivityList(lavender, pink, lightYellow),
                  ],
                ),
              ),
      ),
    );
  }

  // Activity Form
  Widget _buildActivityForm(
    Color lavender,
    Color lightYellow,
    Color mintGreen,
  ) {
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Activity',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              teacherEmail != null
                  ? 'Logged in as: $teacherName ($teacherEmail)'
                  : 'Loading teacher info...',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Activity Title',
                prefixIcon: const Icon(Icons.title, color: Colors.deepPurple),
                filled: true,
                fillColor: lavender.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Enter activity title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Description',
                prefixIcon: const Icon(
                  Icons.description,
                  color: Colors.deepPurple,
                ),
                filled: true,
                fillColor: lightYellow.withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Enter description' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _classController,
              decoration: InputDecoration(
                hintText: 'Class (e.g., Grade KG-A)',
                prefixIcon: const Icon(Icons.class_, color: Colors.deepPurple),
                filled: true,
                fillColor: mintGreen.withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Enter class name' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? 'No due date selected'
                        : 'Due: ${_dueDate!.toLocal().toString().split(' ')[0]}'
                              '${_dueTime != null ? ' at ${_dueTime!.format(context)}' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.calendar_month,
                    color: Colors.deepPurple,
                  ),
                  onPressed: _pickDate,
                ),
                IconButton(
                  icon: const Icon(Icons.access_time, color: Colors.deepPurple),
                  onPressed: _pickTime,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(
                _fileName == null
                    ? 'Attach File (optional)'
                    : 'File: $_fileName',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: mintGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveActivity,
              icon: const Icon(Icons.send),
              label: const Text('Assign Activity'),
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
    );
  }

  // Assigned Activity List
  Widget _buildActivityList(Color lavender, Color pink, Color lightYellow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assigned Activities',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('activities')
              .where('teacherEmail', isEqualTo: teacherEmail)
              .orderBy('dueDate', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No upcoming activities yet.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final data = docs[i].data() as Map<String, dynamic>;
                final color = i.isEven
                    ? pink.withOpacity(0.4)
                    : lightYellow.withOpacity(0.5);

                final due = data['dueDate']?.toDate();
                final dueText = due != null
                    ? '${due.toString().split(' ')[0]} at ${TimeOfDay.fromDateTime(due).format(context)}'
                    : 'No due date';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: lavender,
                      child: const Icon(
                        Icons.assignment,
                        color: Colors.deepPurple,
                      ),
                    ),
                    title: Text(
                      data['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['description'] ?? ''),
                        Text('Class: ${data['class'] ?? ''}'),
                        Text('Due: $dueText'),
                        if ((data['fileName'] ?? '').isNotEmpty)
                          Text(' Attached: ${data['fileName']}'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
