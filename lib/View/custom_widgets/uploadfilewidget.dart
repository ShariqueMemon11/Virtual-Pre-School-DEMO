import 'package:flutter/material.dart';

typedef FilePickedCallback = void Function(String base64, String fileName);

class UploadFileWidget extends StatelessWidget {
  final FilePickedCallback onFilePicked;
  final String? fileName;
  final List<String>? allowedExtensions;

  const UploadFileWidget({
    super.key,
    required this.onFilePicked,
    this.fileName,
    this.allowedExtensions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            fileName == null || fileName!.isEmpty
                ? 'No file selected'
                : fileName!,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            // Stub: In tests or non-implemented platforms, just emit a dummy file
            onFilePicked('', 'dummy.txt');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Stub file selected: dummy.txt')),
            );
          },
          child: const Text('Choose File'),
        ),
      ],
    );
  }
}
