// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadFileWidget extends StatelessWidget {
  /// Callback when a file is picked -> (base64, fileName)
  final Function(String base64, String fileName) onFilePicked;
  final String? fileName;

  /// Allowed file types: PDF + Images
  final List<String> allowedExtensions;

  const UploadFileWidget({
    super.key,
    required this.onFilePicked,
    this.fileName,
    this.allowedExtensions = const ['pdf', 'jpg', 'jpeg', 'png'],
  });

  Future<void> _pickFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.single.bytes != null) {
        final pickedFile = result.files.single;
        final extension = pickedFile.extension?.toLowerCase();

        // 🚫 Block unsupported files (extra safety)
        if (extension == null || !allowedExtensions.contains(extension)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Only PDF and image files are allowed."),
            ),
          );
          return;
        }

        Uint8List fileBytes = pickedFile.bytes!;
        String base64String = base64Encode(fileBytes);

        onFilePicked(base64String, pickedFile.name);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No file selected.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error picking file: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => _pickFile(context),
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload File'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            fileName ?? 'No file selected',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
