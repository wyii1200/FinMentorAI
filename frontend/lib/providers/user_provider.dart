import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = "";
  double _resilienceScore = 65.0; // Starting score

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  double get resilienceScore => _resilienceScore;

  // Simulate a login/signup action
  Future<void> login(String name) async {
    _isLoggedIn = true;
    _userName = name;
    notifyListeners(); // This tells the UI to rebuild!
  }

  void logout() {
    _isLoggedIn = false;
    _userName = "";
    notifyListeners();
  }

  // AI can call this when a user makes a good financial choice
  void updateScore(double change) {
    _resilienceScore += change;
    notifyListeners();
  }
}
