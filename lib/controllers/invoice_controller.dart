import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_vps/Model/invoice_model.dart';

class InvoiceController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> generateInvoices() async {
    final studentsSnapshot = await _firestore.collection('Students').get();

    for (final studentDoc in studentsSnapshot.docs) {
      final data = studentDoc.data();

      // Skip if no class assigned
      if (data['assignedClass'] == null) continue;

      final String classId = data['assignedClass'];

      final classDoc =
          await _firestore.collection('classes').doc(classId).get();

      if (!classDoc.exists) continue;

      final invoice = Invoice(
        studentId: studentDoc.id,
        studentName: data['childName'] ?? '',
        classId: classId,
        className: classDoc['gradeName'] ?? '',
        classFee: classDoc['classFee'] ?? 0,
        date: Timestamp.now(),
        status: 'pending',
      );

      await _firestore.collection('Invoices').add(invoice.toMap());
    }
  }
}
