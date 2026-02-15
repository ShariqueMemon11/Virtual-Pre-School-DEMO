// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClassMaterialsModal extends StatefulWidget {
  final String? classId;
  final String? className;
  const ClassMaterialsModal({super.key, this.classId, this.className});

  @override
  State<ClassMaterialsModal> createState() => _ClassMaterialsModalState();
}

class _ClassMaterialsModalState extends State<ClassMaterialsModal> {
  List<Map<String, dynamic>> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    final classId = widget.classId?.trim();
    final className = widget.className?.trim();
    if ((classId == null || classId.isEmpty) &&
        (className == null || className.isEmpty)) {
      setState(() {
        _materials = [];
        _isLoading = false;
      });
      return;
    }
    try {
      setState(() => _isLoading = true);
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('materials');
      if (classId != null && classId.isNotEmpty) {
        query = query.where('classId', isEqualTo: classId);
      } else if (className != null && className.isNotEmpty) {
        query = query.where('className', isEqualTo: className);
      }
      final snapshot = await query.get();

      final loaded = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Class Material',
          'description': data['description'] ?? 'No description provided',
          'fileBase64': data['fileBase64'] ?? '',
          'fileUrl': data['fileUrl'] ?? '',
          'fileName': data['fileName'] ?? 'material.pdf',
          'teacherName': data['teacherName'] ?? 'Teacher',
          'className': data['className'] ?? data['class'] ?? 'Class',
          'uploadedAt': data['uploadedAt'] as Timestamp?,
        };
      }).toList()
        ..sort((a, b) {
          final ta = a['uploadedAt'] as Timestamp?;
          final tb = b['uploadedAt'] as Timestamp?;
          if (ta == null && tb == null) return 0;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta);
        });

      setState(() {
        _materials = loaded;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading materials: $e')),
      );
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _downloadMaterial(Map<String, dynamic> material) async {
    try {
      final String fileName = material['fileName'] as String? ?? 'material.pdf';
      final String fileBase64 = material['fileBase64'] as String? ?? '';
      final String fileUrl = material['fileUrl'] as String? ?? '';

      if (fileBase64.isNotEmpty) {
        final bytes = base64Decode(fileBase64);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..download = fileName
          ..click();
        html.Url.revokeObjectUrl(url);
      } else if (fileUrl.isNotEmpty) {
        html.window.open(fileUrl, '_blank');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File data not available.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: isMobile ? screenWidth * 0.9 : 800.w,
        height: isMobile ? MediaQuery.of(context).size.height * 0.8 : 600.h,
        padding: EdgeInsets.all(isMobile ? 20 : 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_copy,
                  size: isMobile ? 28 : 28.sp,
                  color: Colors.deepPurple,
                ),
                SizedBox(width: isMobile ? 10 : 10.w),
                Text(
                  'Class Materials',
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, size: isMobile ? 28 : 24),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20.h),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _materials.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        itemCount: _materials.length,
                        itemBuilder: (context, index) {
                          final material = _materials[index];
                          return _buildMaterialCard(material);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;
    final classId = widget.classId;
    final className = widget.className;
    final hasClass = (classId != null && classId.isNotEmpty) ||
        (className != null && className.isNotEmpty);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: isMobile ? 80 : 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: isMobile ? 16 : 16.h),
            Text(
              'No materials available',
              style: TextStyle(
                fontSize: isMobile ? 18 : 18.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 0),
              child: Text(
                hasClass
                    ? 'Please check back later for new uploads from your teacher.'
                    : 'Class not assigned yet. Contact your teacher for access.',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 14.sp,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    material['title'],
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    material['className'] ?? 'Class',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.purple[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              material['description'],
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(Icons.person, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 6.w),
                Text(
                  'Uploaded by ${material['teacherName']}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 6.w),
                Text(
                  _formatDate(material['uploadedAt'] as Timestamp?),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadMaterial(material),
                icon: const Icon(Icons.download),
                label: Text('Download ${material['fileName']}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

