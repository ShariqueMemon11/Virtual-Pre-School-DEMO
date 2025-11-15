import 'package:demo_vps/firebase_options.dart';
import 'package:demo_vps/responsive.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
void main() async {
  //main
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintBaselinesEnabled = false;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Helper method to build circlesimport 'teacheradmissionwidget.dart';

    return Responsive();
  }
}