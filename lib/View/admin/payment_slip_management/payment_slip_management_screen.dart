// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../utils/responsive_helper.dart';

class PaymentSlipManagementScreen extends StatefulWidget {
  const PaymentSlipManagementScreen({super.key});

  @override
  State<PaymentSlipManagementScreen> createState() =>
      _PaymentSlipManagementScreenState();
}

class _PaymentSlipManagementScreenState
    extends State<PaymentSlipManagementScreen> {
  List<Map<String, dynamic>> paymentSlips = [];
  bool isLoading = true;
  String selectedFilter = 'all'; // all, pending, verified, rejected
  int _lastPendingCount = 0; // Track previous pending count for notifications

  @override
  void initState() {
    super.initState();
    _loadPaymentSlips();
    _setupPendingSlipListener();
  }

  void _setupPendingSlipListener() {
    // Listen for new pending payment slips
    FirebaseFirestore.instance
        .collection('payment_slips')
        .where('status', isEqualTo: 'pending_verification')
        .snapshots()
        .listen((snapshot) {
          final currentCount = snapshot.docs.length;

          // Show notification if count increased (new slip uploaded)
          if (_lastPendingCount > 0 && currentCount > _lastPendingCount) {
            final newSlips = currentCount - _lastPendingCount;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.notification_important,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        newSlips == 1
                            ? 'New payment slip uploaded!'
                            : '$newSlips new payment slips uploaded!',
                      ),
                    ],
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'VIEW',
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'pending';
                      });
                      _loadPaymentSlips();
                    },
                  ),
                ),
              );
            }
          }

          _lastPendingCount = currentCount;
        });
  }

  Future<void> _loadPaymentSlips() async {
    try {
      setState(() {
        isLoading = true;
      });

      Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
        'payment_slips',
      );

      if (selectedFilter != 'all') {
        query = query.where(
          'status',
          isEqualTo:
              selectedFilter == 'pending'
                  ? 'pending_verification'
                  : selectedFilter,
        );
      }

      final querySnapshot = await query.get();

      if (!mounted) return;

      // Build payment slip list with invoice details
      final List<Map<String, dynamic>> loaded = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final data = doc.data();

          // Get invoice details
          Map<String, dynamic> invoiceData = {};
          try {
            final invoiceDoc =
                await FirebaseFirestore.instance
                    .collection('Invoices')
                    .doc(data['invoiceId'])
                    .get();
            if (invoiceDoc.exists) {
              invoiceData = invoiceDoc.data() ?? {};
            }
          } catch (_) {
            // Ignore invoice fetch errors
          }

          return {
            'id': doc.id,
            'invoiceId': data['invoiceId'] ?? '',
            'studentId': data['studentId'] ?? '',
            'studentEmail': data['studentEmail'] ?? '',
            'studentName': data['studentName'] ?? 'Unknown Student',
            'fileName': data['fileName'] ?? 'payment_slip.pdf',
            'fileBase64': data['fileBase64'] ?? '',
            'fileSize': data['fileSize'] ?? 0,
            'uploadedAt': data['uploadedAt'] ?? Timestamp.now(),
            'status': data['status'] ?? 'pending_verification',
            'verifiedAt': data['verifiedAt'],
            'verifiedBy': data['verifiedBy'],
            'rejectedAt': data['rejectedAt'],
            'rejectedBy': data['rejectedBy'],
            'rejectionReason': data['rejectionReason'],
            // Invoice details
            'className': invoiceData['className'] ?? 'Unknown Class',
            'classFee': invoiceData['classFee'] ?? 0,
            'invoiceDate': invoiceData['date'],
          };
        }).toList(),
      );

      setState(() {
        paymentSlips = loaded;
        // Sort by uploadedAt on client side (latest first)
        paymentSlips.sort((a, b) {
          final dateA = a['uploadedAt'] as Timestamp;
          final dateB = b['uploadedAt'] as Timestamp;
          return dateB.compareTo(dateA);
        });
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payment slips: $e')),
        );
      }
    }
  }

  Future<void> _verifyPaymentSlip(String slipId, String invoiceId) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Verify Payment'),
              content: const Text(
                'Are you sure you want to verify this payment slip?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Verify'),
                ),
              ],
            ),
      );

      if (confirmed != true) return;

      // Update payment slip status
      await FirebaseFirestore.instance
          .collection('payment_slips')
          .doc(slipId)
          .update({
            'status': 'verified',
            'verifiedAt': Timestamp.now(),
            'verifiedBy': 'admin', // In real app, use current admin user
          });

      // Update invoice status to paid
      await FirebaseFirestore.instance
          .collection('Invoices')
          .doc(invoiceId)
          .update({'status': 'paid'});

      // Reload data
      _loadPaymentSlips();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment verified successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectPaymentSlip(String slipId) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reject Payment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please provide a reason for rejection:'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    hintText: 'Reason for rejection...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Reject'),
              ),
            ],
          ),
    );

    if (confirmed != true || reasonController.text.trim().isEmpty) return;

    try {
      // Update payment slip status
      await FirebaseFirestore.instance
          .collection('payment_slips')
          .doc(slipId)
          .update({
            'status': 'rejected',
            'rejectedAt': Timestamp.now(),
            'rejectedBy': 'admin', // In real app, use current admin user
            'rejectionReason': reasonController.text.trim(),
          });

      // Update invoice status back to pending
      final slip = paymentSlips.firstWhere((s) => s['id'] == slipId);
      await FirebaseFirestore.instance
          .collection('Invoices')
          .doc(slip['invoiceId'])
          .update({'status': 'pending'});

      // Reload data
      _loadPaymentSlips();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment slip rejected'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadPaymentSlip(String fileBase64, String fileName) async {
    try {
      if (fileBase64.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file data available for download')),
        );
        return;
      }

      final bytes = base64Decode(fileBase64);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.AnchorElement(href: url)
        ..download = fileName
        ..click();

      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading $fileName...'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error downloading file: $e')));
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy • hh:mm a').format(date);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending_verification':
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'VERIFIED';
      case 'rejected':
        return 'REJECTED';
      case 'pending_verification':
      default:
        return 'PENDING';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('payment_slips')
                  .where('status', isEqualTo: 'pending_verification')
                  .snapshots(),
          builder: (context, snapshot) {
            final pendingCount =
                snapshot.hasData ? snapshot.data!.docs.length : 0;

            return Row(
              children: [
                Flexible(
                  child: Text(
                    ResponsiveHelper.isMobile(context)
                        ? 'Payment Slips'
                        : 'Payment Slip Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.fontSize(context, 20),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (pendingCount > 0) ...[
                  SizedBox(width: ResponsiveHelper.spacing(context, 8)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.padding(context, 8),
                      vertical: ResponsiveHelper.padding(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$pendingCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.fontSize(context, 12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.padding(context, 16)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  SizedBox(width: ResponsiveHelper.spacing(context, 8)),
                  _buildFilterChip('Pending', 'pending'),
                  SizedBox(width: ResponsiveHelper.spacing(context, 8)),
                  _buildFilterChip('Verified', 'verified'),
                  SizedBox(width: ResponsiveHelper.spacing(context, 8)),
                  _buildFilterChip('Rejected', 'rejected'),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : paymentSlips.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: EdgeInsets.all(
                        ResponsiveHelper.padding(context, 16),
                      ),
                      itemCount: paymentSlips.length,
                      itemBuilder: (context, index) {
                        final slip = paymentSlips[index];
                        return _buildPaymentSlipCard(slip);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          value == 'all'
              ? FirebaseFirestore.instance
                  .collection('payment_slips')
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('payment_slips')
                  .where(
                    'status',
                    isEqualTo:
                        value == 'pending' ? 'pending_verification' : value,
                  )
                  .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        final isSelected = selectedFilter == value;

        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? Colors.deepPurpleAccent : Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                selectedFilter = value;
              });
              _loadPaymentSlips();
            }
          },
          selectedColor: Colors.deepPurpleAccent.withOpacity(0.2),
          checkmarkColor: Colors.deepPurpleAccent,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_outlined, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'No payment slips found',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            selectedFilter == 'all'
                ? 'Payment slips will appear here when students upload them'
                : 'No $selectedFilter payment slips found',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSlipCard(Map<String, dynamic> slip) {
    final status = slip['status'] ?? 'pending_verification';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.padding(context, 16),
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.padding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slip['studentName'],
                        style: TextStyle(
                          fontSize: ResponsiveHelper.fontSize(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(context, 4)),
                      Text(
                        '${slip['className']} • Rs. ${slip['classFee']}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.fontSize(context, 14),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.padding(context, 8),
                    vertical: ResponsiveHelper.padding(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(context, 12),
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveHelper.spacing(context, 12)),

            // Student Info
            Row(
              children: [
                Icon(
                  Icons.email,
                  size: ResponsiveHelper.fontSize(context, 16),
                  color: Colors.grey[500],
                ),
                SizedBox(width: ResponsiveHelper.spacing(context, 4)),
                Expanded(
                  child: Text(
                    slip['studentEmail'],
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(context, 12),
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveHelper.spacing(context, 8)),

            // Upload Info
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: ResponsiveHelper.fontSize(context, 16),
                  color: Colors.grey[500],
                ),
                SizedBox(width: ResponsiveHelper.spacing(context, 4)),
                Expanded(
                  child: Text(
                    'Uploaded: ${_formatDate(slip['uploadedAt'])}',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(context, 12),
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveHelper.spacing(context, 8)),

            // File Info
            Row(
              children: [
                Icon(
                  Icons.attach_file,
                  size: ResponsiveHelper.fontSize(context, 16),
                  color: Colors.blue,
                ),
                SizedBox(width: ResponsiveHelper.spacing(context, 4)),
                Expanded(
                  child: Text(
                    '${slip['fileName']} (${_formatFileSize(slip['fileSize'])})',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(context, 14),
                      color: Colors.blue,
                    ),
                  ),
                ),
                IconButton(
                  onPressed:
                      () => _downloadPaymentSlip(
                        slip['fileBase64'],
                        slip['fileName'],
                      ),
                  icon: const Icon(
                    Icons.download,
                    size: 20,
                    color: Colors.blue,
                  ),
                  tooltip: 'Download Payment Slip',
                ),
              ],
            ),

            // Status-specific info
            if (status == 'verified' && slip['verifiedAt'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Verified on ${_formatDate(slip['verifiedAt'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (status == 'rejected' && slip['rejectedAt'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red[700], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Rejected on ${_formatDate(slip['rejectedAt'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (slip['rejectionReason'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Reason: ${slip['rejectionReason']}',
                        style: TextStyle(fontSize: 12, color: Colors.red[700]),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Action Buttons (only for pending slips)
            if (status == 'pending_verification') ...[
              SizedBox(height: ResponsiveHelper.spacing(context, 16)),
              ResponsiveHelper.isMobile(context)
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                () =>
                                    _verifyPaymentSlip(
                                      slip['id'],
                                      slip['invoiceId'],
                                    ),
                            icon: const Icon(Icons.check),
                            label: const Text('Verify Payment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.spacing(context, 8)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _rejectPaymentSlip(slip['id']),
                            icon: const Icon(Icons.close),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                () =>
                                    _verifyPaymentSlip(
                                      slip['id'],
                                      slip['invoiceId'],
                                    ),
                            icon: const Icon(Icons.check),
                            label: const Text('Verify Payment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.spacing(context, 8)),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _rejectPaymentSlip(slip['id']),
                            icon: const Icon(Icons.close),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
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
