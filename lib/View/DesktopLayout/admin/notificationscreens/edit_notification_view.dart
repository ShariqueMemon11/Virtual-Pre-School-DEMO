// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../controller/DesktopControllers/create_notification_controller.dart';
import '../../../../Model/notification_model.dart';
import '../../../DesktopLayout/customwidgets/dropdownselectorwidget.dart';
import '../../../DesktopLayout/customwidgets/inputfieldareawidget.dart';
import '../../../DesktopLayout/customwidgets/inputfieldwidget.dart';
import '../../../DesktopLayout/customwidgets/primarybuttonwidget.dart';

class EditNotificationView extends StatefulWidget {
  final String id;
  const EditNotificationView({super.key, required this.id});

  @override
  State<EditNotificationView> createState() => _EditNotificationViewState();
}

class _EditNotificationViewState extends State<EditNotificationView> {
  final NotificationController _controller = NotificationController();
  final _title = TextEditingController();
  final _body = TextEditingController();
  String _audience = "Select Audience";

  bool _loading = true;
  String? _documentName;
  String? _uploadedDocumentBase64;

  final List<String> _audienceOptions = [
    'Select Audience',
    'Students/Parents',
    'Teachers',
    'Admins',
  ];

  @override
  void initState() {
    super.initState();
    _fetchNotification();
  }

  Future<void> _fetchNotification() async {
    final notif = await _controller.getNotificationById(widget.id);
    if (notif != null) {
      setState(() {
        _title.text = notif.title;
        _body.text = notif.body;
        _audience = notif.audience;
        _documentName = notif.documentName;
        _uploadedDocumentBase64 = notif.uploadedDocument;
        _loading = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.single.bytes != null) {
      Uint8List fileBytes = result.files.single.bytes!;
      String base64File = base64Encode(fileBytes);

      setState(() {
        _documentName = result.files.single.name;
        _uploadedDocumentBase64 = base64File;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Notification")),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    InputFieldWidget(input: "Title", controller: _title),
                    const SizedBox(height: 15),
                    InputFieldAreaWidget(input: "Body", controller: _body),
                    const SizedBox(height: 15),
                    DropdownSelectorWidget(
                      options: _audienceOptions,
                      selectedOption: _audience,
                      onChanged: (v) => setState(() => _audience = v!),
                    ),
                    const SizedBox(height: 20),

                    // File Upload Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _documentName ?? "No document selected",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: const Text("Reupload"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    Primarybuttonwidget(
                      input: "Update Notification",
                      run: () async {
                        final updated = NotificationModel(
                          id: widget.id,
                          title: _title.text,
                          body: _body.text,
                          audience: _audience,
                          uploadedDocument: _uploadedDocumentBase64,
                          documentName: _documentName,
                        );
                        await _controller.updateNotification(updated, context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
    );
  }
}
