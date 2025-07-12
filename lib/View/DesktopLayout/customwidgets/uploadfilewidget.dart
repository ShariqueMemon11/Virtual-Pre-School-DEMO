import 'package:flutter/material.dart';

class UploadFileWidget extends StatelessWidget {
  final VoidCallback onFilePicked;
  final String? fileName;

  const UploadFileWidget({
    super.key,
    required this.onFilePicked,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: onFilePicked,
          icon: Icon(Icons.upload_file),
          label: Text('Upload File'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            fileName ?? 'No file selected',
            style: TextStyle(fontSize: 14, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
