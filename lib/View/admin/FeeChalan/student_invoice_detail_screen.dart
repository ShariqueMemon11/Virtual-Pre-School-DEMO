import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentInvoiceDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot invoiceDoc;

  StudentInvoiceDetailScreen({super.key, required this.invoiceDoc});

  final DateFormat formatter = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final data = invoiceDoc.data() as Map<String, dynamic>;

    final String studentName = data['studentName'];
    final String className = data['className'];
    final int fee = data['classFee'];
    final String status = data['status'];
    final Timestamp date = data['date'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Fee Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Student Name', studentName),
                _row('Class', className),
                _row('Chalan Date', formatter.format(date.toDate())),
                _row('Fee Amount', 'Rs. $fee'),
                const SizedBox(height: 12),
                _statusBadge(status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isPaid = status == 'paid';

    return Center(
      child: Chip(
        label: Text(
          isPaid ? 'PAID' : 'PENDING',
          style: TextStyle(
            color: isPaid ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
      ),
    );
  }
}
