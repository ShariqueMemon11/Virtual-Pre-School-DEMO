// ignore_for_file: file_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_vps/View/admin/FeeChalan/chalan_detail_screen.dart';
import 'package:demo_vps/View/admin/payment_slip_management/payment_slip_management_screen.dart';
import 'package:demo_vps/controllers/invoice_controller.dart';
import 'package:demo_vps/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeeChalanListScreen extends StatelessWidget {
  FeeChalanListScreen({super.key});

  final InvoiceController controller = InvoiceController();
  final DateFormat formatter = DateFormat('dd MMM yyyy • hh:mm a');

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isMobile ? 'Fee Chalans' : 'Fee Chalans Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.fontSize(context, 20),
          ),
        ),
        actions: [
          // Payment Slip Management with notification badge
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('payment_slips')
                .where('status', isEqualTo: 'pending_verification')
                .snapshots(),
            builder: (context, snapshot) {
              final pendingCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
              
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.receipt_long),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentSlipManagementScreen(),
                        ),
                      );
                    },
                    tooltip: 'Manage Payment Slips',
                  ),
                  if (pendingCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          pendingCount > 99 ? '99+' : pendingCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _confirmGenerate(context),
            tooltip: 'Generate New Chalan',
          ),
        ],
      ),
      body: StreamBuilder(
        stream: controller.invoicesGroupedByDate(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final groupedInvoices = snapshot.data!;

          if (groupedInvoices.isEmpty) {
            return const Center(child: Text('No chalans generated yet'));
          }

          return ListView(
            children:
                groupedInvoices.entries.map((entry) {
                  final Timestamp date = entry.key;
                  final invoices = entry.value;

                  final paid =
                      invoices.where((e) => e['status'] == 'paid').length;
                  final pending =
                      invoices.where((e) => e['status'] == 'pending' || e['status'] == 'pending_verification').length;

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      title: Text(
                        formatter.format(date.toDate()),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        children: [
                          Chip(
                            label: Text('Paid: $paid'),
                            backgroundColor: Colors.green.shade100,
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text('Pending: $pending'),
                            backgroundColor: Colors.orange.shade100,
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, date),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ChalanDetailScreen(chalanDate: date),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  /// CONFIRM GENERATE
  void _confirmGenerate(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Generate Fee Chalan'),
            content: const Text(
              'Are you sure you want to generate a new fee chalan for all students?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await InvoiceController().generateInvoices();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chalan generated')),
                  );
                },
                child: const Text('Generate'),
              ),
            ],
          ),
    );
  }

  /// CONFIRM DELETE
  void _confirmDelete(BuildContext context, Timestamp date) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Chalan'),
            content: const Text(
              'Are you sure you want to delete this entire chalan?\nThis action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context);
                  await controller.deleteChalanGroup(date);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chalan deleted')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
