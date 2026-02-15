// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../custom_widgets/upload_file_widget.dart';

class FeeChallanModal extends StatefulWidget {
  const FeeChallanModal({super.key});

  @override
  State<FeeChallanModal> createState() => _FeeChallanModalState();
}

class _FeeChallanModalState extends State<FeeChallanModal> {
  List<Map<String, dynamic>> challans = [];
  bool isLoading = true;
  // Store file selection per challan ID
  final Map<String, String> _selectedFileNames = {};
  final Map<String, String> _selectedFileBase64s = {};

  @override
  void initState() {
    super.initState();
    _loadChallans();
  }

  Future<void> _loadChallans() async {
    try {
      setState(() {
        isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          challans = [];
          isLoading = false;
        });
        return;
      }

      // Get student document ID from Students collection
      String? studentDocId;
      try {
        final studentsQuery = await FirebaseFirestore.instance
            .collection('Students')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        
        if (studentsQuery.docs.isNotEmpty) {
          studentDocId = studentsQuery.docs.first.id;
        }
      } catch (_) {
        // If Students collection query fails, try with user UID as fallback
        studentDocId = user.uid;
      }

      List<QueryDocumentSnapshot> invoiceDocs = [];

      // Try to fetch challans using studentId first
      if (studentDocId != null) {
        try {
          // Simple query without orderBy to avoid index requirement
          final querySnapshot = await FirebaseFirestore.instance
              .collection('Invoices')
              .where('studentId', isEqualTo: studentDocId)
              .get();
          invoiceDocs = querySnapshot.docs;
          
          // Sort client-side by date (descending)
          invoiceDocs.sort((a, b) {
            final dateA = a['date'] as Timestamp;
            final dateB = b['date'] as Timestamp;
            return dateB.compareTo(dateA);
          });
        } catch (e) {
          // Error querying by studentId, continue to fallback
        }
      }

      // Fallback: try querying by email if studentId didn't work
      if (invoiceDocs.isEmpty && user.email != null) {
        try {
          final querySnapshot = await FirebaseFirestore.instance
              .collection('Invoices')
              .where('studentEmail', isEqualTo: user.email)
              .get();
          invoiceDocs = querySnapshot.docs;
          
          // Sort client-side since we can't use orderBy with where on different field
          invoiceDocs.sort((a, b) {
            final dateA = a['date'] as Timestamp;
            final dateB = b['date'] as Timestamp;
            return dateB.compareTo(dateA);
          });
        } catch (_) {
          // If email query also fails, show empty
        }
      }

      if (invoiceDocs.isEmpty) {
        setState(() {
          challans = [];
          isLoading = false;
        });
        return;
      }

      if (!mounted) return;

      // Build challan list with payment slip info
      final List<Map<String, dynamic>> loaded = await Future.wait(
        invoiceDocs.map((doc) async {
          final data = doc.data() as Map<String, dynamic>;
          
          // Check if there's a payment slip for this challan
          String? paymentSlipFileName;
          String? paymentSlipBase64;
          Timestamp? slipUploadedAt;
          
          try {
            final slipQuery = await FirebaseFirestore.instance
                .collection('payment_slips')
                .where('invoiceId', isEqualTo: doc.id)
                .limit(1)
                .get();
                
            if (slipQuery.docs.isNotEmpty) {
              final slipData = slipQuery.docs.first.data();
              paymentSlipFileName = slipData['fileName'];
              paymentSlipBase64 = slipData['fileBase64'];
              slipUploadedAt = slipData['uploadedAt'];
            }
          } catch (_) {
            // Ignore payment slip query errors
          }

          return {
            'id': doc.id,
            'studentName': data['studentName'] ?? 'Student',
            'className': data['className'] ?? 'Unknown Class',
            'classFee': data['classFee'] ?? 0,
            'date': data['date'] ?? Timestamp.now(),
            'status': data['status'] ?? 'pending',
            'accountNumber': data['accountNumber'] ?? '',
            'paymentSlipFileName': paymentSlipFileName,
            'paymentSlipBase64': paymentSlipBase64,
            'slipUploadedAt': slipUploadedAt,
          };
        }).toList(),
      );

      setState(() {
        challans = loaded;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          challans = [];
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading challans: $e')),
        );
      }
    }
  }

  Future<void> _downloadChallan(String challanId, String studentName, 
      String className, int classFee, Timestamp date, String accountNumber) async {
    try {
      // Generate a simple PDF-like content (in real app, you'd use pdf package)
      final challanContent = '''
Fee Challan

Student: $studentName
Class: $className
Fee Amount: Rs. $classFee
Date: ${_formatDate(date)}
Challan ID: $challanId

Bank Account Number: $accountNumber

Please pay the fee amount and upload the payment slip.
      ''';
      
      final bytes = utf8.encode(challanContent);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.AnchorElement(href: url)
        ..download = 'fee_challan_${challanId.substring(0, 8)}.txt'
        ..click();

      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Challan downloaded successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading challan: $e')),
      );
    }
  }

  Future<void> _uploadPaymentSlip(String challanId) async {
    final selectedFileBase64 = _selectedFileBase64s[challanId];
    final selectedFileName = _selectedFileNames[challanId];
    
    if (selectedFileBase64 == null || selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to upload payment slip')),
        );
        return;
      }

      // Check if payment slip already exists
      final existing = await FirebaseFirestore.instance
          .collection('payment_slips')
          .where('invoiceId', isEqualTo: challanId)
          .limit(1)
          .get();
          
      if (existing.docs.isNotEmpty) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Text('Already uploaded'),
            content: const Text(
              'You have already uploaded a payment slip for this challan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      final fileBytes = base64Decode(selectedFileBase64);
      final fileSizeInMB = fileBytes.length / (1024 * 1024);

      // Enforce 1 MB max upload size
      if (fileBytes.length > 1024 * 1024) {
        setState(() {
          _selectedFileNames.remove(challanId);
          _selectedFileBase64s.remove(challanId);
        });

        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Text('File too large'),
            content: Text(
              'The selected file is ${fileSizeInMB.toStringAsFixed(2)} MB. The maximum allowed size is 1 MB.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      if (!mounted) return;

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10),
              Text('Uploading payment slip...'),
            ],
          ),
          duration: Duration(days: 1),
        ),
      );

      // Get student info
      String studentName = user.displayName ?? 'Student';
      try {
        final studentsQuery = await FirebaseFirestore.instance
            .collection('Students')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        if (studentsQuery.docs.isNotEmpty) {
          final sdata = studentsQuery.docs.first.data();
          final resolvedName = (sdata['childName'] ?? sdata['studentName'])?.toString();
          if (resolvedName != null && resolvedName.trim().isNotEmpty) {
            studentName = resolvedName.trim();
          }
        }
      } catch (_) {
        // Keep fallback
      }

      // Create payment slip document
      await FirebaseFirestore.instance
          .collection('payment_slips')
          .add({
        'invoiceId': challanId,
        'studentId': user.uid,
        'studentEmail': user.email,
        'studentName': studentName,
        'fileName': selectedFileName,
        'fileBase64': selectedFileBase64,
        'fileSize': fileBytes.length,
        'uploadedAt': Timestamp.now(),
        'status': 'pending_verification',
      });

      // Update invoice status to pending verification
      await FirebaseFirestore.instance
          .collection('Invoices')
          .doc(challanId)
          .update({'status': 'pending_verification'});

      if (!mounted) return;

      // Clear selected file
      setState(() {
        _selectedFileNames.remove(challanId);
        _selectedFileBase64s.remove(challanId);
        
        // Update local challan status
        final idx = challans.indexWhere((c) => c['id'] == challanId);
        if (idx != -1) {
          challans[idx]['status'] = 'pending_verification';
          challans[idx]['paymentSlipFileName'] = selectedFileName;
          challans[idx]['slipUploadedAt'] = Timestamp.now();
        }
      });

      // Clear loading and show success
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment slip uploaded successfully! (${fileSizeInMB.toStringAsFixed(2)} MB)',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading payment slip: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending_verification':
        return Colors.orange;
      case 'pending':
      default:
        return Colors.red;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'PAID';
      case 'pending_verification':
        return 'PENDING VERIFICATION';
      case 'pending':
      default:
        return 'UNPAID';
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
            // Header
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: isMobile ? 28 : 28.sp,
                  color: Colors.green,
                ),
                SizedBox(width: isMobile ? 10 : 10.w),
                Text(
                  'My Fee Challans',
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

            // Content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : challans.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: challans.length,
                          itemBuilder: (context, index) {
                            final challan = challans[index];
                            return _buildChallanCard(challan);
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
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_outlined,
              size: isMobile ? 80 : 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: isMobile ? 16 : 16.h),
            Text(
              'No fee challans available',
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
                'Fee challans will appear here when generated by admin',
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

  Widget _buildChallanCard(Map<String, dynamic> challan) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;
    final status = challan['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Challan Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fee Challan - ${challan['className']}',
                        style: TextStyle(
                          fontSize: isMobile ? 17 : 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isMobile ? 4 : 4.h),
                      Text(
                        'Amount: Rs. ${challan['classFee']}',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 8.w,
                    vertical: isMobile ? 6 : 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 12.sp,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 8 : 8.h),

            // Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: isMobile ? 16 : 16.sp,
                  color: Colors.grey[500],
                ),
                SizedBox(width: isMobile ? 6 : 4.w),
                Text(
                  'Generated: ${_formatDate(challan['date'])}',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 12 : 12.h),

            // Download Challan Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadChallan(
                  challan['id'],
                  challan['studentName'],
                  challan['className'],
                  challan['classFee'],
                  challan['date'],
                  challan['accountNumber'],
                ),
                icon: Icon(Icons.download, size: isMobile ? 20 : 18),
                label: Text(
                  'Download Challan',
                  style: TextStyle(fontSize: isMobile ? 15 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 14 : 12,
                  ),
                ),
              ),
            ),

            SizedBox(height: isMobile ? 12 : 12.h),

            // Payment Slip Section
            if (status == 'paid')
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 12 : 12.w),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: isMobile ? 22 : 20.sp,
                    ),
                    SizedBox(width: isMobile ? 8 : 8.w),
                    Expanded(
                      child: Text(
                        'Payment verified and completed',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 14.sp,
                          color: Colors.green[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (status == 'pending_verification')
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pending, color: Colors.orange[700], size: 20.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Payment slip uploaded - Pending verification',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (challan['paymentSlipFileName'] != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        'Uploaded: ${challan['paymentSlipFileName']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.orange[600],
                        ),
                      ),
                      if (challan['slipUploadedAt'] != null)
                        Text(
                          'On: ${_formatDate(challan['slipUploadedAt'])}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.orange[600],
                          ),
                        ),
                    ],
                  ],
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Payment Slip:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    UploadFileWidget(
                      onFilePicked: (base64, fileName) {
                        setState(() {
                          _selectedFileBase64s[challan['id']] = base64;
                          _selectedFileNames[challan['id']] = fileName;
                        });
                      },
                      fileName: _selectedFileNames[challan['id']],
                      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _selectedFileBase64s[challan['id']] != null
                            ? () => _uploadPaymentSlip(challan['id'])
                            : null,
                        icon: const Icon(Icons.upload),
                        label: const Text('Submit Payment Slip'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}