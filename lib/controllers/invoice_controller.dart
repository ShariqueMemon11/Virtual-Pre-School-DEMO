import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_vps/Model/invoice_model.dart';

class InvoiceController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> generateInvoices() async {
    final Timestamp batchDate = Timestamp.now(); // 🔥 same timestamp for all

    final studentsSnapshot = await _firestore.collection('Students').get();

    for (final studentDoc in studentsSnapshot.docs) {
      final data = studentDoc.data();

      if (data['assignedClass'] == null) continue;

      final classId = data['assignedClass'];
      final classDoc =
          await _firestore.collection('classes').doc(classId).get();

      if (!classDoc.exists) continue;

      final invoice = Invoice(
        studentId: studentDoc.id,
        studentName: data['childName'] ?? '',
        classId: classId,
        className: classDoc['gradeName'] ?? '',
        classFee: classDoc['classFee'] ?? 0,
        date: batchDate, // 🔥 grouped by this
        status: 'pending',
        accountNumber: '03163082532', // Or get from classDoc['accountNumber']
      );

      // Add the invoice with additional email field for easier querying
      final invoiceData = invoice.toMap();
      invoiceData['studentEmail'] = data['email']; // Add email for easier student matching

      await _firestore.collection('Invoices').add(invoiceData);
    }
  }

  /// Stream invoices grouped by generation date
  Stream<Map<Timestamp, List<QueryDocumentSnapshot>>> invoicesGroupedByDate() {
    return _firestore
        .collection('Invoices')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          final Map<Timestamp, List<QueryDocumentSnapshot>> grouped = {};

          for (var doc in snapshot.docs) {
            final Timestamp date = doc['date'];
            grouped.putIfAbsent(date, () => []).add(doc);
          }

          return grouped;
        });
  }

  /// Delete entire chalan group
  Future<void> deleteChalanGroup(Timestamp date) async {
    final query =
        await _firestore
            .collection('Invoices')
            .where('date', isEqualTo: date)
            .get();

    final batch = _firestore.batch();
    for (var doc in query.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Stream<Map<String, List<QueryDocumentSnapshot>>> invoicesByClass(
    Timestamp date,
  ) {
    return _firestore
        .collection('Invoices')
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snapshot) {
          final Map<String, List<QueryDocumentSnapshot>> grouped = {};

          for (var doc in snapshot.docs) {
            final className = doc['className'] ?? 'Unknown Class';
            grouped.putIfAbsent(className, () => []).add(doc);
          }

          return grouped;
        });
  }

  Future<DocumentSnapshot> getInvoiceById(String invoiceId) {
    return _firestore.collection('Invoices').doc(invoiceId).get();
  }
}
