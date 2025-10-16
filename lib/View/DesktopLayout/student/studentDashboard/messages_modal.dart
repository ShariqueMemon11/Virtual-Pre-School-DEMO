import 'dart:convert';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessagesModal extends StatefulWidget {
  const MessagesModal({super.key});

  @override
  State<MessagesModal> createState() => _MessagesModalState();
}

class _MessagesModalState extends State<MessagesModal> {
  bool isLoading = true;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        isLoading = true;
      });

      final snapshot =
          await FirebaseFirestore.instance.collection('notifications').get();

      if (!mounted) return;

      final items =
          snapshot.docs
              .map((doc) {
                final data = doc.data();
                final String audience = (data['audience'] ?? '').toString();
                final bool isForStudents = audience.toLowerCase().contains(
                  'student',
                );
                return {
                  'id': doc.id,
                  'title': data['title'] ?? 'Notification',
                  'body': data['body'] ?? '',
                  'uploadedDocument':
                      data['uploadedDocument'], // base64 (optional)
                  'documentName': data['documentName'] ?? 'document',
                  'createdAt': data['createdAt'] ?? Timestamp.now(),
                  'isForStudents': isForStudents,
                };
              })
              .where((n) => n['isForStudents'] == true)
              .toList();

      items.sort((a, b) {
        final ta = a['createdAt'] as Timestamp? ?? Timestamp.now();
        final tb = b['createdAt'] as Timestamp? ?? Timestamp.now();
        return tb.compareTo(ta);
      });

      setState(() {
        notifications = items;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $e')),
        );
      }
    }
  }

  Future<void> _downloadBase64(String base64, String fileName) async {
    try {
      final bytes = base64Decode(base64);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..download = fileName
        ..click();
      html.Url.revokeObjectUrl(url);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading $fileName (${bytes.length} bytes)...'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error downloading file: $e')));
    }
  }

  String _formatDate(Timestamp timestamp) {
    final d = timestamp.toDate();
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year} at ${d.hour}:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: 800.w,
        height: 600.h,
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mail_outline, size: 28.sp, color: Colors.purple),
                SizedBox(width: 10.w),
                Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : notifications.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final n = notifications[index];
                          return _notificationCard(n);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.outgoing_mail, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 12.h),
          Text(
            'No messages yet',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _notificationCard(Map<String, dynamic> n) {
    final String? base64Doc = n['uploadedDocument'] as String?;
    final String fileName = (n['documentName'] as String?) ?? 'document';
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
                    n['title'] ?? 'Notification',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16.sp,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDate(n['createdAt'] as Timestamp),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if ((n['body'] as String).isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                n['body'],
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              ),
            ],
            if (base64Doc != null && base64Doc.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.attach_file, size: 16.sp, color: Colors.purple),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      fileName,
                      style: TextStyle(fontSize: 14.sp, color: Colors.purple),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _downloadBase64(base64Doc, fileName),
                    icon: Icon(
                      Icons.download,
                      color: Colors.purple,
                      size: 20.sp,
                    ),
                    tooltip: 'Download attachment',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
