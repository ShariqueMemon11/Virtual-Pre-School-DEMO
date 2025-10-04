import 'package:demo_vps/controller/firebase_options.dart';
import 'package:demo_vps/responsive.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';

// Last Changes of part 1
void main() async {
  //main
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintBaselinesEnabled = false; // make sure this is off
  // Initialize Firebase with the default options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Helper method to build circles

    return Responsive();
  }
}
