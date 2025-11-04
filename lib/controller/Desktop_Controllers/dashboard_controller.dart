import 'package:flutter/material.dart';

class DashboardController extends ChangeNotifier {
  bool _isMenuOpen = false;
  bool get isMenuOpen => _isMenuOpen;

  void toggleMenu() {
    _isMenuOpen = !_isMenuOpen;
    notifyListeners();
  }
}
