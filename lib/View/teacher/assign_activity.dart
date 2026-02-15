// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../custom_widgets/upload_file_widget.dart';
import '../../utils/responsive_helper.dart';

class AssignActivityPage extends StatefulWidget {
  const AssignActivityPage({super.key});

  @override
  State<AssignActivityPage> createState() => _AssignActivityPageState();
}

class _AssignActivityPageState extends State<AssignActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? teacherName;
  String? teacherEmail;
  String? _fileName;
  String? _fileBase64;
  String? _className;
  String? _classId;
  bool _isClassLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeacherInfo();
  }

  Future<void> _loadTeacherInfo() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        teacherEmail = null;
        teacherName = 'Teacher';
      });
      return;
    }

    final email = user.email ?? '';
    final fallbackName =
        (user.displayName?.trim().isNotEmpty == true)
            ? user.displayName!.trim()
            : (email.isNotEmpty ? email.split('@').first : 'Teacher');

    String resolvedName = fallbackName;
    String? teacherDocId;

    try {
      final teachersSnapshot =
          await _firestore
              .collection('Teachers')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (teachersSnapshot.docs.isNotEmpty) {
        final doc = teachersSnapshot.docs.first;
        final data = doc.data();
        resolvedName =
            (data['name'] as String?)?.trim().isNotEmpty == true
                ? data['name']
                : fallbackName;
        teacherDocId = doc.id;
      } else {
        final applicationsSnapshot =
            await _firestore
                .collection('teacher_applications')
                .where('email', isEqualTo: email)
                .limit(1)
                .get();

        if (applicationsSnapshot.docs.isNotEmpty) {
          final data = applicationsSnapshot.docs.first.data();
          resolvedName =
              (data['name'] ?? data['teacherName'] ?? data['fullName'] ?? '')
                      .toString()
                      .trim()
                      .isNotEmpty
                  ? (data['name'] ?? data['teacherName'] ?? data['fullName'])
                  : fallbackName;
        }
      }
    } catch (_) {
      // ignore errors
    }

    setState(() {
      teacherEmail = email;
      teacherName = resolvedName;
    });

    await _loadAssignedClass(teacherDocId, resolvedName);
  }

  Future<void> _loadAssignedClass(String? teacherId, String? name) async {
    setState(() {
      _isClassLoading = true;
    });

    try {
      QuerySnapshot<Map<String, dynamic>>? snapshot;

      // First try: Query by teacherId (most reliable)
      if (teacherId != null && teacherId.isNotEmpty) {
        snapshot = await _firestore
            .collection('classes')
            .where('teacherid', isEqualTo: teacherId)
            .limit(1)
            .get();
      }

      // Second try: Query by teacher name (exact match)
      if ((snapshot == null || snapshot.docs.isEmpty) && 
          name != null && name.trim().isNotEmpty) {
        snapshot = await _firestore
            .collection('classes')
            .where('teacher', isEqualTo: name.trim())
            .limit(1)
            .get();
      }

      // Third try: Query by teacher email if available
      if ((snapshot == null || snapshot.docs.isEmpty) && 
          teacherEmail != null && teacherEmail!.isNotEmpty) {
        snapshot = await _firestore
            .collection('classes')
            .where('teacherEmail', isEqualTo: teacherEmail)
            .limit(1)
            .get();
      }

      if (!mounted) return;

      if (snapshot == null || snapshot.docs.isEmpty) {
        setState(() {
          _className = null;
          _classId = null;
          _isClassLoading = false;
        });
        return;
      }

      final data = snapshot.docs.first.data();
      setState(() {
        _classId = snapshot!.docs.first.id;
        _className = data['gradeName'] ?? 
                     data['className'] ?? 
                     data['name'] ?? 
                     'Class';
        _isClassLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _className = null;
        _classId = null;
        _isClassLoading = false;
      });
    }
  }

  // Pick a date
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  // Pick a time
  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  // Save Activity to Firestore
  Future<void> saveActivity() async {
    if (_classId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No class assigned to this teacher')),
      );
      return;
    }
    if (_formKey.currentState!.validate() && _dueDate != null) {
      final dueDateTime = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        _dueTime?.hour ?? 0,
        _dueTime?.minute ?? 0,
      );

      await _firestore.collection('assignments').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'classId': _classId,
        'className': _className,
        'status': 'pending',
        'createdAt': Timestamp.now(),
        'dueDate': Timestamp.fromDate(dueDateTime),
        'teacherName': teacherName,
        'teacherEmail': teacherEmail,
        'fileName': _fileName ?? '',
        'fileBase64': _fileBase64 ?? '',
        'assignment': _fileBase64 ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Activity Assigned Successfully!')),
      );

      _titleController.clear();
      _descController.clear();
      setState(() {
        _dueDate = null;
        _dueTime = null;
        _fileName = null;
        _fileBase64 = null;
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

    final isWideScreen = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: lavender,
        title: Text(
          ResponsiveHelper.isMobile(context) ? 'Activities' : 'Assign Activities',
          style: TextStyle(
            color: Colors.black,
            fontSize: ResponsiveHelper.fontSize(context, 20),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.padding(context, 20)),
        child:
            isWideScreen
                ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: buildActivityForm(
                        lavender,
                        lightYellow,
                        mintGreen,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: buildActivityList(lavender, pink, lightYellow),
                    ),
                  ],
                )
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      buildActivityForm(lavender, lightYellow, mintGreen),
                      SizedBox(height: ResponsiveHelper.spacing(context, 20)),
                      buildActivityList(lavender, pink, lightYellow),
                    ],
                  ),
                ),
      ),
    );
  }

  // Activity Form
  Widget buildActivityForm(Color lavender, Color lightYellow, Color mintGreen) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.padding(context, 16)),
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
            Text(
              'Create New Activity',
              style: TextStyle(
                fontSize: ResponsiveHelper.fontSize(context, 22),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(context, 8)),
            Text(
              teacherEmail != null && teacherName != null
                  ? 'Logged in as: $teacherName ($teacherEmail)'
                  : teacherEmail != null
                      ? 'Logged in as: $teacherEmail'
                      : 'Loading teacher info...',
              style: TextStyle(
                color: Colors.black54,
                fontSize: ResponsiveHelper.fontSize(context, 14),
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(context, 16)),
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
            SizedBox(height: ResponsiveHelper.spacing(context, 12)),
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
            SizedBox(height: ResponsiveHelper.spacing(context, 12)),
            _isClassLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                  padding: EdgeInsets.all(ResponsiveHelper.padding(context, 16)),
                  decoration: BoxDecoration(
                    color: mintGreen.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.class_, color: Colors.deepPurple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _className ?? 'No class assigned',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(context, 16),
                            fontWeight: FontWeight.w500,
                            color:
                                _className == null
                                    ? Colors.grey
                                    : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            SizedBox(height: ResponsiveHelper.spacing(context, 12)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? 'No due date selected'
                        : 'Due: ${_dueDate!.toLocal().toString().split(' ')[0]}'
                            '${_dueTime != null ? ' at ${_dueTime!.format(context)}' : ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveHelper.fontSize(context, 14),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.calendar_month,
                    color: Colors.deepPurple,
                    size: ResponsiveHelper.fontSize(context, 24),
                  ),
                  onPressed: pickDate,
                ),
                IconButton(
                  icon: Icon(
                    Icons.access_time,
                    color: Colors.deepPurple,
                    size: ResponsiveHelper.fontSize(context, 24),
                  ),
                  onPressed: pickTime,
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.spacing(context, 12)),
            UploadFileWidget(
              fileName: _fileName,
              allowedExtensions: const [
                'pdf',
                'doc',
                'docx',
                'jpg',
                'jpeg',
                'png',
              ],
              onFilePicked: (base64, fileName) {
                setState(() {
                  _fileName = fileName;
                  _fileBase64 = base64;
                });
              },
            ),
            SizedBox(height: ResponsiveHelper.spacing(context, 16)),
            ElevatedButton.icon(
              onPressed: saveActivity,
              icon: const Icon(Icons.send),
              label: Text(
                'Assign Activity',
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(context, 16),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: lavender,
                foregroundColor: Colors.black,
                minimumSize: Size(
                  double.infinity,
                  ResponsiveHelper.isMobile(context) ? 45 : 50,
                ),
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
  Widget buildActivityList(Color lavender, Color pink, Color lightYellow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Activities',
          style: TextStyle(
            fontSize: ResponsiveHelper.fontSize(context, 22),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: ResponsiveHelper.spacing(context, 12)),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream:
              teacherEmail == null
                  ? const Stream<QuerySnapshot<Map<String, dynamic>>>.empty()
                  : _firestore
                      .collection('assignments')
                      .where('teacherEmail', isEqualTo: teacherEmail)
                      // Order by creation time so previous assignments stay visible.
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
          builder: (context, snapshot) {
            if (teacherEmail == null) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('Loading teacher info...')),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Could not load activities: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No activities yet.',
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
                final data = docs[i].data();
                final color =
                    i.isEven
                        ? pink.withOpacity(0.4)
                        : lightYellow.withOpacity(0.5);

                final dueTimestamp = data['dueDate'];
                final due = dueTimestamp is Timestamp ? dueTimestamp.toDate() : null;
                final dueText =
                    due != null
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.fontSize(context, 16),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['description'] ?? '',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(context, 14),
                          ),
                        ),
                        Text(
                          'Class: ${data['className'] ?? ''}',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(context, 13),
                          ),
                        ),
                        Text(
                          'Due: $dueText',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(context, 13),
                          ),
                        ),
                        if ((data['fileName'] ?? '').isNotEmpty)
                          Text(
                            ' Attached: ${data['fileName']}',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.fontSize(context, 12),
                            ),
                          ),
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
