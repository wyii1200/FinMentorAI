import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = "";
  double _resilienceScore = 65.0;

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  double get resilienceScore => _resilienceScore;

  // LOGIN METHOD (needed by LoginScreen)
  Future<void> login(String name) async {
    _isLoggedIn = true;
    _userName = name;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = "";
    notifyListeners();
  }

  void updateScore(double change) {
    _resilienceScore += change;

    if (_resilienceScore > 100) _resilienceScore = 100;
    if (_resilienceScore < 0) _resilienceScore = 0;

    notifyListeners();
  }
}
