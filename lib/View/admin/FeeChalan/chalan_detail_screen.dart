import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_vps/View/admin/FeeChalan/student_invoice_detail_screen.dart';
import 'package:demo_vps/controllers/invoice_controller.dart';
import 'package:flutter/material.dart';

class ChalanDetailScreen extends StatelessWidget {
  final Timestamp chalanDate;

  ChalanDetailScreen({super.key, required this.chalanDate});

  final InvoiceController controller = InvoiceController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Chalan Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: controller.invoicesByClass(chalanDate),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final classGroups = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(12),
            children:
                classGroups.entries.map((entry) {
                  final className = entry.key;
                  final invoices = entry.value;

                  final paid =
                      invoices.where((e) => e['status'] == 'paid').toList();
                  final pending =
                      invoices.where((e) => e['status'] == 'pending' || e['status'] == 'pending_verification').toList();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      title: Text(
                        className,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Paid: ${paid.length} • Pending: ${pending.length}',
                      ),
                      children: [
                        if (pending.isNotEmpty) ...[
                          _sectionTitle('Pending Students'),
                          ...pending.map((doc) => _studentTile(context, doc)),
                        ],
                        if (paid.isNotEmpty) ...[
                          _sectionTitle('Paid Students'),
                          ...paid.map((doc) => _studentTile(context, doc)),
                        ],
                      ],
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _studentTile(BuildContext context, QueryDocumentSnapshot doc) {
    final String status = doc['status'];

    final Color dotColor = status == 'paid' 
        ? Colors.green 
        : status == 'pending_verification' 
            ? Colors.orange 
            : Colors.red;

    return ListTile(
      leading: Icon(Icons.circle, color: dotColor, size: 10),
      title: Text(doc['studentName']),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentInvoiceDetailScreen(invoiceDoc: doc),
          ),
        );
      },
    );
  }
}
