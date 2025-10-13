import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html; // ✅ For download in Flutter Web
import 'package:flutter/material.dart';
import '../../../../controller/DesktopControllers/create_notification_controller.dart';
import '../../../../Model/notification_modal.dart';

class ViewNotificationView extends StatefulWidget {
  final String id;
  const ViewNotificationView({super.key, required this.id});

  @override
  State<ViewNotificationView> createState() => _ViewNotificationViewState();
}

class _ViewNotificationViewState extends State<ViewNotificationView> {
  final NotificationController _controller = NotificationController();
  NotificationModel? _notification;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final notif = await _controller.getNotificationById(widget.id);
    setState(() {
      _notification = notif;
      _loading = false;
    });
  }

  /// ✅ Opens the attached document in a new browser tab
  void _openDocument() {
    if (_notification?.uploadedDocument == null) return;

    final bytes = base64Decode(_notification!.uploadedDocument!);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, "_blank");
    html.Url.revokeObjectUrl(url);
  }

  /// ✅ Downloads the attached document
  void _downloadDocument() {
    if (_notification?.uploadedDocument == null) return;

    final bytes = base64Decode(_notification!.uploadedDocument!);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor =
        html.AnchorElement(href: url)
          ..download = _notification!.documentName ?? "document"
          ..click();

    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          "View Notification",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 156, 129, 219),
        elevation: 3,
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
              : _notification == null
              ? const Center(child: Text("❌ Notification not found"))
              : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    width: 700,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== Header =====
                        Row(
                          children: [
                            const Icon(
                              Icons.notifications_active,
                              color: Colors.deepPurple,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _notification!.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ===== Metadata =====
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                _notification!.audience,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.deepPurple,
                            ),
                            const Spacer(),
                            if (_notification!.createdAt != null)
                              Text(
                                "📅 ${_notification!.createdAt!.toDate().toString().split(' ')[0]}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // ===== Body =====
                        Text(
                          _notification!.body,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),

                        const SizedBox(height: 30),

                        // ===== Attachment Section =====
                        if (_notification!.documentName != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.deepPurple.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.deepPurple,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _notification!.documentName!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),

                                IconButton(
                                  tooltip: "Download",
                                  icon: const Icon(
                                    Icons.download,
                                    color: Colors.green,
                                  ),
                                  onPressed: _downloadDocument,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
