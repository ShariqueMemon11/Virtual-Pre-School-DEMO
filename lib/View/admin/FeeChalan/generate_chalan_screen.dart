import 'package:demo_vps/controllers/invoice_controller.dart';
import 'package:flutter/material.dart';

class GenerateChalanScreen extends StatefulWidget {
  const GenerateChalanScreen({super.key});

  @override
  State<GenerateChalanScreen> createState() => _GenerateChalanScreenState();
}

class _GenerateChalanScreenState extends State<GenerateChalanScreen> {
  // 🔥 CONTROLLER IS INITIALIZED HERE (NO NULL)
  final InvoiceController controller = InvoiceController();

  bool loading = false;

  Future<void> createInvoices() async {
    setState(() => loading = true);

    try {
      await controller.generateInvoices();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoices generated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Invoices')),
      body: Center(
        child:
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: createInvoices,
                  child: const Text('Generate Invoices'),
                ),
      ),
    );
  }
}
