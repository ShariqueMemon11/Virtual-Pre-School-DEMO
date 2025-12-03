// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../custom_widgets/upload_file_widget.dart';

class UploadMaterialPage extends StatefulWidget {
  const UploadMaterialPage({super.key});

  @override
  State<UploadMaterialPage> createState() => _UploadMaterialPageState();
}

class _UploadMaterialPageState extends State<UploadMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
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
      // ignore errors, keep fallback
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

  Future<void> _saveMaterial() async {
    if (_classId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No class assigned to this teacher')));
      return;
    }
    if (_fileBase64 == null || _fileName == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please attach a file')));
      return;
    }

    if (_formKey.currentState!.validate()) {
      await _firestore.collection('materials').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'classId': _classId,
        'className': _className,
        'uploadedAt': Timestamp.now(),
        'teacherName': teacherName,
        'teacherEmail': teacherEmail,
        'fileName': _fileName,
        'fileBase64': _fileBase64,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Material uploaded successfully!')),
      );

      _titleController.clear();
      _descController.clear();
      setState(() {
        _fileName = null;
        _fileBase64 = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Fill all fields and upload a file.')),
      );
    }
  }

  Future<void> _downloadMaterial(String? fileBase64, String? fileName) async {
    if (fileBase64 == null || fileBase64.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file data available to download.')),
      );
      return;
    }
    try {
      final bytes = base64Decode(fileBase64);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..download = fileName ?? 'material.pdf'
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to download file: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const lavender = Color(0xFFD9C3F7);
    const lightYellow = Color(0xFFF7EBC3);
    const mintGreen = Color(0xFFB7E4C7);
    const pink = Color(0xFFFFC8DD);
    const bgColor = Color(0xFFF7F5F2);

    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Upload Materials',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: lavender,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child:
            isWide
                ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildForm(lavender, lightYellow, mintGreen),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: _buildList(lavender, pink, lightYellow),
                    ),
                  ],
                )
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildForm(lavender, lightYellow, mintGreen),
                      const SizedBox(height: 20),
                      _buildList(lavender, pink, lightYellow),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildForm(Color lavender, Color lightYellow, Color mintGreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload New Material',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              teacherEmail != null && teacherName != null
                  ? 'Logged in as: $teacherName ($teacherEmail)'
                  : teacherEmail != null
                      ? 'Logged in as: $teacherEmail'
                      : 'Loading teacher info...',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Material Title',
                prefixIcon: const Icon(Icons.title, color: Colors.deepPurple),
                filled: true,
                fillColor: lavender.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Enter material title' : null,
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

            _isClassLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.all(16),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _className == null ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 12),

            UploadFileWidget(
              fileName: _fileName,
              onFilePicked: (base64, fileName) {
                setState(() {
                  _fileName = fileName;
                  _fileBase64 = base64;
                });
              },
              allowedExtensions: const [
                'pdf',
                'doc',
                'docx',
                'png',
                'jpg',
                'jpeg',
              ],
            ),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveMaterial,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Upload Material'),
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

  Widget _buildList(Color lavender, Color pink, Color lightYellow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Uploaded Materials',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream:
              _firestore
                  .collection('materials')
                  .orderBy('uploadedAt', descending: true)
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
                    'No materials uploaded yet.',
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
                final fileName = data['fileName'] as String? ?? '';
                final className =
                    data['className'] ?? data['class'] ?? 'Not specified';
                final fileBase64 = data['fileBase64'] as String? ?? '';
                final color =
                    i.isEven
                        ? pink.withOpacity(0.4)
                        : lightYellow.withOpacity(0.5);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: lavender,
                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.deepPurple,
                      ),
                    ),
                    title: Text(
                      data['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['description'] ?? ''),
                        Text('Class: $className'),
                        Text('File: $fileName'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed:
                          fileBase64.isEmpty
                              ? null
                              : () => _downloadMaterial(fileBase64, fileName),
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
