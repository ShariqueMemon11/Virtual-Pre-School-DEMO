// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadMaterialPage extends StatefulWidget {
  const UploadMaterialPage({super.key});

  @override
  State<UploadMaterialPage> createState() => _UploadMaterialPageState();
}

class _UploadMaterialPageState extends State<UploadMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _classController = TextEditingController();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  String? teacherName;
  String? teacherEmail;
  String? _fileName;
  String? _fileUrl;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadTeacherInfo();
  }

  void _loadTeacherInfo() {
    final user = _auth.currentUser;
    teacherEmail = user?.email ?? 'areeba@previrtual.edu.pk';
    teacherName = user?.displayName ?? 'Areeba Andleeb';
  }

  // Pick and Upload File
  Future<void> _pickFile() async {
    final picked = await FilePicker.platform.pickFiles();

    if (picked != null && picked.files.single.path != null) {
      final file = File(picked.files.single.path!);
      final name = picked.files.single.name;

      setState(() {
        _fileName = name;
        _uploadProgress = 0.0;
        _isUploading = true;
      });

      try {
        final ref = _storage.ref('materials/$name');
        final uploadTask = ref.putFile(file);

        uploadTask.snapshotEvents.listen((event) {
          setState(() {
            _uploadProgress = event.bytesTransferred / event.totalBytes;
          });
        });

        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();

        setState(() {
          _fileUrl = url;
          _isUploading = false;
          _uploadProgress = 1.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' File "$name" uploaded successfully!')),
        );
      } catch (e) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(' Upload failed: $e')));
      }
    }
  }

  Future<void> _saveMaterial() async {
    if (_formKey.currentState!.validate() && _fileUrl != null) {
      await _firestore.collection('materials').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'class': _classController.text.trim(),
        'uploadedAt': Timestamp.now(),
        'teacherName': teacherName,
        'teacherEmail': teacherEmail,
        'fileName': _fileName,
        'fileUrl': _fileUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Material uploaded successfully!')),
      );

      _titleController.clear();
      _descController.clear();
      _classController.clear();
      setState(() {
        _fileName = null;
        _fileUrl = null;
        _uploadProgress = 0.0;
        _isUploading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Fill all fields and upload a file.')),
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
        child: isWide
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
              'Logged in as: $teacherName ($teacherEmail)',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Material Title',
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
                labelText: 'Description',
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
                labelText: 'Class (e.g., Grade KG-A)',
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

            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(
                _fileName == null
                    ? 'Attach File (PDF/Image)'
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

            if (_isUploading) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.grey[300],
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 5),
              Text(
                'Uploading: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _saveMaterial,
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
          stream: _firestore
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
                final color = i.isEven
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
                        Text('Class: ${data['class'] ?? ''}'),
                        Text('File: ${data['fileName'] ?? ''}'),
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
