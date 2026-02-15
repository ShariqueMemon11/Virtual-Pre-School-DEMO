// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_vps/utils/responsive_helper.dart';
import 'dart:convert';
import 'assign_activity.dart';
import 'upload_material.dart';
import 'update_grades.dart';
import 'student_activities_page.dart';
import 'mark_attendance_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? teacherName;
  String? teacherEmail;
  bool _isProfileLoading = true;
  bool _isClassLoading = true;
  String? _assignedClassName;
  int? _assignedClassCapacity;
  int? _assignedStudentCount;
  String? _teacherPhotoBase64;

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTeacherProfile();
  }

  Future<void> _loadTeacherProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          teacherName = 'Unknown';
          teacherEmail = 'Unknown';
          _isProfileLoading = false;
        });
        setState(() => _isClassLoading = false);
        return;
      }

      final email = user.email ?? '';
      final fallbackName =
          (user.displayName?.trim().isNotEmpty == true)
              ? user.displayName!.trim()
              : (email.isNotEmpty ? email.split('@').first : 'Teacher');

      String resolvedName = fallbackName;
      String resolvedEmail = email.isNotEmpty ? email : 'Unknown';
      String? resolvedPhoto;
      String? teacherDocId;

      final teachersSnapshot =
          await _firestore
              .collection('Teachers')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (teachersSnapshot.docs.isNotEmpty) {
        final doc = teachersSnapshot.docs.first;
        final data = doc.data();
        resolvedName =
            (data['name'] as String?)?.trim().isNotEmpty == true
                ? data['name']
                : fallbackName;
        resolvedEmail = data['email'] ?? resolvedEmail;
        resolvedPhoto = data['photoBase64'] ?? resolvedPhoto;
        teacherDocId = doc.id;
      } else {
        final applicationsSnapshot =
            await _firestore
                .collection('teacher_applications')
                .where('email', isEqualTo: email)
                .limit(1)
                .get();

        if (applicationsSnapshot.docs.isNotEmpty) {
          final data = applicationsSnapshot.docs.first.data();
          resolvedName =
              (data['name'] ?? data['teacherName'] ?? data['fullName'] ?? '')
                      .toString()
                      .trim()
                      .isNotEmpty
                  ? (data['name'] ?? data['teacherName'] ?? data['fullName'])
                  : fallbackName;
          resolvedEmail = data['email'] ?? resolvedEmail;
          resolvedPhoto = data['photoBase64'] ?? resolvedPhoto;
        }
      }

      if (!mounted) return;
      setState(() {
        teacherName = resolvedName;
        teacherEmail = resolvedEmail;
        _teacherPhotoBase64 = resolvedPhoto;
        _isProfileLoading = false;
      });

      await _loadAssignedClass(teacherDocId, resolvedName);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        teacherName = 'Unknown';
        teacherEmail = 'Unknown';
        _teacherPhotoBase64 = null;
        _isProfileLoading = false;
        _isClassLoading = false;
        _assignedClassName = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    }
  }

  Future<void> _loadAssignedClass(String? teacherId, String? name) async {
    setState(() {
      _isClassLoading = true;
    });

    try {
      Query<Map<String, dynamic>> query = _firestore.collection('classes');

      if (teacherId != null) {
        query = query.where('teacherid', isEqualTo: teacherId);
      } else if (name != null && name.trim().isNotEmpty) {
        query = query.where('teacher', isEqualTo: name.trim());
      } else {
        setState(() {
          _assignedClassName = null;
          _assignedClassCapacity = null;
          _assignedStudentCount = null;
          _isClassLoading = false;
        });
        return;
      }

      final snapshot = await query.limit(1).get();

      if (!mounted) return;

      if (snapshot.docs.isEmpty) {
        setState(() {
          _assignedClassName = null;
          _assignedClassCapacity = null;
          _assignedStudentCount = null;
          _isClassLoading = false;
        });
        return;
      }

      final data = snapshot.docs.first.data();
      setState(() {
        _assignedClassName = data['gradeName'] ?? 'Assigned Class';
        _assignedClassCapacity = data['capacity'] ?? 0;
        _assignedStudentCount = data['studentCount'] ?? 0;
        _isClassLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _assignedClassName = null;
        _assignedClassCapacity = null;
        _assignedStudentCount = null;
        _isClassLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load class data: $e')));
    }
  }

  ImageProvider? _getTeacherImage() {
    if (_teacherPhotoBase64 != null && _teacherPhotoBase64!.isNotEmpty) {
      try {
        final base64String =
            _teacherPhotoBase64!.contains(',')
                ? _teacherPhotoBase64!.split(',')[1]
                : _teacherPhotoBase64!;
        final bytes = base64Decode(base64String);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Widget _buildTeacherProfileCard() {
    final imageProvider = _getTeacherImage();
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color.fromARGB(255, 151, 123, 218),
            backgroundImage: imageProvider,
            child:
                imageProvider == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child:
                _isProfileLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          teacherName ?? 'Teacher',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          teacherEmail ?? 'No email',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Teacher',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 151, 123, 218),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassInfoCard() {
    return Container(
      height: 160,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child:
          _isClassLoading
              ? const Center(child: CircularProgressIndicator())
              : _assignedClassName == null
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.info_outline, color: Colors.deepPurple),
                  SizedBox(height: 8),
                  Text('No class assigned yet.', textAlign: TextAlign.center),
                ],
              )
              : Row(
                children: [
                  SizedBox(
                    width: 90,
                    height: 95,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value:
                              (_assignedClassCapacity ?? 0) > 0
                                  ? (_assignedStudentCount ?? 0) /
                                      _assignedClassCapacity!
                                  : 0,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orange[700] ?? Colors.orange,
                          ),
                        ),
                        Center(
                          child: Text(
                            '${_assignedStudentCount ?? 0}/${_assignedClassCapacity ?? 0}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Assigned Class',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.orange[700],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _assignedClassName!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Students enrolled: ${_assignedStudentCount ?? 0}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  // Add agenda item
  Future<void> _addAgendaItem() async {
    if (_taskController.text.isEmpty || _timeController.text.isEmpty) return;
    if (teacherEmail == null || teacherEmail!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile not loaded yet')));
      }
      return;
    }

    await _firestore.collection('agenda').add({
      'teacherEmail': teacherEmail,
      'task': _taskController.text.trim(),
      'time': _timeController.text.trim(),
      'createdAt': DateTime.now(),
    });

    _taskController.clear();
    _timeController.clear();

    if (mounted) {
      Future.delayed(const Duration(milliseconds: 200), () {
        Navigator.pop(context);
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agenda added successfully'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // Delete agenda item
  Future<void> _deleteAgenda(String id) async {
    await _firestore.collection('agenda').doc(id).delete();
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF7F5F2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 123, 218),
        elevation: 0,
        titleSpacing: 16,
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.padding(context, 16)),
        child: ResponsiveHelper.isMobile(context)
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainContent(),
                    SizedBox(height: ResponsiveHelper.spacing(context, 20)),
                    _buildAgendaContent(),
                  ],
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      child: _buildMainContent(),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(context, 16)),
                  Expanded(
                    flex: 1,
                    child: _buildAgendaContent(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: ResponsiveHelper.padding(context, 10),
            left: ResponsiveHelper.padding(context, 4),
          ),
          child: Text(
            'Teacher Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.fontSize(context, 25),
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: ResponsiveHelper.padding(context, 4),
            right: ResponsiveHelper.padding(context, 20),
          ),
          child: const Divider(thickness: 0.5, color: Colors.blueGrey),
        ),
        Padding(
          padding: EdgeInsets.only(top: ResponsiveHelper.padding(context, 10)),
          child: ResponsiveHelper.isMobile(context)
              ? Column(
                  children: [
                    _buildTeacherProfileCard(),
                    SizedBox(height: ResponsiveHelper.spacing(context, 20)),
                    _buildClassInfoCard(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTeacherProfileCard()),
                    SizedBox(width: ResponsiveHelper.spacing(context, 20)),
                    Expanded(child: _buildClassInfoCard()),
                  ],
                ),
        ),
        SizedBox(height: ResponsiveHelper.spacing(context, 24)),
        Padding(
          padding: EdgeInsets.only(left: ResponsiveHelper.padding(context, 4)),
          child: Text(
            'Quick Access',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.fontSize(context, 25),
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: ResponsiveHelper.padding(context, 4),
            right: ResponsiveHelper.padding(context, 20),
            top: ResponsiveHelper.padding(context, 4),
          ),
          child: const Divider(thickness: 0.5, color: Colors.blueGrey),
        ),
        Padding(
          padding: EdgeInsets.only(top: ResponsiveHelper.padding(context, 10)),
          child: Wrap(
            spacing: ResponsiveHelper.spacing(context, 30),
            runSpacing: ResponsiveHelper.spacing(context, 20),
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              _quickAccessCard(
                context,
                Icons.videocam,
                'Start Class',
                const Color.fromARGB(255, 238, 212, 248),
                _startClass,
              ),
              _quickAccessCard(
                context,
                Icons.assignment,
                'Assign Activities',
                const Color.fromARGB(255, 238, 212, 248),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AssignActivityPage(),
                    ),
                  );
                },
              ),
              _quickAccessCard(
                context,
                Icons.upload_file,
                'Upload Class Material',
                const Color.fromARGB(255, 249, 236, 184),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UploadMaterialPage(),
                    ),
                  );
                },
              ),
              _quickAccessCard(
                context,
                Icons.grade,
                'Update Grades',
                const Color.fromARGB(255, 212, 248, 238),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UpdateGradesPage(),
                    ),
                  );
                },
              ),
              _quickAccessCard(
                context,
                Icons.list_alt,
                'Student Submissions',
                const Color.fromARGB(255, 238, 212, 248),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentActivitiesPage(),
                    ),
                  );
                },
              ),
              _buildAttendanceCardWithNotification(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgendaContent() {
    if (ResponsiveHelper.isMobile(context)) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.padding(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Agenda",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => showAddAgendaDialog(context),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.spacing(context, 10)),
              SizedBox(
                height: 300,
                child: _buildAgendaList(),
              ),
            ],
          ),
        ),
      );
    }

    // Desktop layout
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(ResponsiveHelper.padding(context, 16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Agenda",
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => showAddAgendaDialog(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(context, 16),
              ),
              child: _buildAgendaList(),
            ),
          ),
          SizedBox(height: ResponsiveHelper.spacing(context, 16)),
        ],
      ),
    );
  }

  Widget _buildAgendaList() {
    return teacherEmail == null
        ? const Center(
            child: Text('Load profile to see agenda.'),
          )
        : StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('agenda')
                .where('teacherEmail', isEqualTo: teacherEmail)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No agenda items yet."));
              }

              final items = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                physics: ResponsiveHelper.isMobile(context)
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final data = items[index].data() as Map<String, dynamic>;
                  final color = index.isEven
                      ? const Color(0xFFD9C3F7)
                      : const Color(0xFFF7EBC3);

                  return Container(
                    margin: EdgeInsets.only(
                      bottom: ResponsiveHelper.spacing(context, 12),
                    ),
                    height: 80,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.padding(context, 12),
                        vertical: ResponsiveHelper.padding(context, 10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  data['time'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveHelper.fontSize(context, 14),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  data['task'] ?? '',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.fontSize(context, 14),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () async {
                              await _deleteAgenda(items[index].id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Agenda deleted successfully'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
  }

  //  Quick Access Card Widget
  static Widget _quickAccessCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 160,
          width: 230,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: Colors.black87),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_circle_right, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceCardWithNotification(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return _quickAccessCard(
        context,
        Icons.how_to_reg,
        'Mark Attendance',
        const Color.fromARGB(255, 184, 236, 249),
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MarkAttendanceScreen(),
            ),
          );
        },
      );
    }

    // Check if today's attendance is marked
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayTimestamp = Timestamp.fromDate(todayStart);

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('attendance')
          .where('date', isEqualTo: todayTimestamp)
          .where('markedBy', isEqualTo: user.uid)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        final hasMarkedToday = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MarkAttendanceScreen(),
              ),
            );
          },
          child: Stack(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  height: 160,
                  width: 230,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 184, 236, 249),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.how_to_reg, size: 28, color: Colors.black87),
                      const Text(
                        'Mark Attendance',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(Icons.arrow_circle_right, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              // Red notification dot if not marked today
              if (!hasMarkedToday)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startClass() async {
    try {
      // 🔹 Generate new Zego room
      final roomId = const Uuid().v4();
      final teacher = "$teacherName Teacher";

      final url = Uri.parse("https://cr-puce.vercel.app/$roomId?name=$teacher");

      // 🔥 Update only the class assigned to logged-in teacher
      final query =
          await FirebaseFirestore.instance
              .collection("classes")
              .where("teacher", isEqualTo: teacherName)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        final classDocId = query.docs.first.id;

        await FirebaseFirestore.instance
            .collection("classes")
            .doc(classDocId)
            .update({"classroomId": roomId, "updatedAt": Timestamp.now()});
      }

      // Open the class link
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open class link")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  //  Add Agenda Dialog
  void showAddAgendaDialog(BuildContext context) {
    _taskController.clear();
    _timeController.clear();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('Add New Agenda'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time (e.g. 9:00 - 9:30)',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    labelText: 'Task (e.g. Review Homework)',
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9C3F7),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _addAgendaItem,
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}
