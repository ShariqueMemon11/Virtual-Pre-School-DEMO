import 'package:flutter/material.dart';

class UploadFileWidget extends StatelessWidget {
  const UploadFileWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Handle file upload logic here
      },
      icon: Icon(Icons.upload_file),
      label: Text('Upload File'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: TextStyle(fontSize: 16),
      ),
    );
  }
}
