import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = "";

  double _income = 0;
  double _expenses = 0;
  double _savingsGoal = 0;
  double _bnplCommitments = 0;
  double _currentSavings = 0;

  double _resilienceScore = 65.0;

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;

  double get income => _income;
  double get expenses => _expenses;
  double get savingsGoal => _savingsGoal;
  double get bnplCommitments => _bnplCommitments;
  double get currentSavings => _currentSavings;
  double get resilienceScore => _resilienceScore;

  double get availableToSave => _income - _expenses - _bnplCommitments;

  double get savingsRate {
    if (_income <= 0) return 0;
    final remaining = availableToSave;
    return (remaining / _income) * 100;
  }

  double get savingsProgress {
    if (_savingsGoal <= 0) return 0;
    return (_currentSavings / _savingsGoal).clamp(0.0, 1.0);
  }

  Future<void> login(String name) async {
    _isLoggedIn = true;
    _userName = name;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = "";
    _income = 0;
    _expenses = 0;
    _savingsGoal = 0;
    _bnplCommitments = 0;
    _currentSavings = 0;
    _resilienceScore = 65.0;
    notifyListeners();
  }

  void setFinancialProfile({
    required double income,
    required double expenses,
    required double savingsGoal,
    required double bnplCommitments,
  }) {
    _income = income;
    _expenses = expenses;
    _savingsGoal = savingsGoal;
    _bnplCommitments = bnplCommitments;

    if (_currentSavings == 0) {
      final suggestedStart = availableToSave > 0 ? availableToSave : 0.0;
      _currentSavings = suggestedStart;
    }

    _resilienceScore = _calculateResilienceScore();
    notifyListeners();
  }

  void updateIncome(double value) {
    _income = value;
    _resilienceScore = _calculateResilienceScore();
    notifyListeners();
  }

  void updateExpenses(double value) {
    _expenses = value;
    _resilienceScore = _calculateResilienceScore();
    notifyListeners();
  }

  void updateSavingsGoal(double value) {
    _savingsGoal = value;
    _resilienceScore = _calculateResilienceScore();
    notifyListeners();
  }

  void updateBnplCommitments(double value) {
    _bnplCommitments = value;
    _resilienceScore = _calculateResilienceScore();
    notifyListeners();
  }

  void addSavings(double amount) {
    if (amount <= 0) return;
    _currentSavings += amount;
    _resilienceScore = _calculateResilienceScore();
    notifyListeners();
  }

  void updateCurrentSavings(double value) {
    _currentSavings = value < 0 ? 0 : value;
    _resilienceScore = _calculateResilienceScore();
    notifyListeners();
  }

  void updateScore(double change) {
    _resilienceScore += change;

    if (_resilienceScore > 100) _resilienceScore = 100;
    if (_resilienceScore < 0) _resilienceScore = 0;

    notifyListeners();
  }

  double _calculateResilienceScore() {
    if (_income <= 0) return 0;

    double score = 100;

    final expenseRatio = _expenses / _income;
    final bnplRatio = _bnplCommitments / _income;
    final goalRatio = _savingsGoal / _income;
    final availableRatio = availableToSave / _income;
    final savingsBufferRatio = _currentSavings / _income;

    if (expenseRatio > 0.7) {
      score -= 25;
    } else if (expenseRatio > 0.5) {
      score -= 15;
    } else if (expenseRatio > 0.3) {
      score -= 8;
    }

    if (bnplRatio > 0.3) {
      score -= 30;
    } else if (bnplRatio > 0.2) {
      score -= 20;
    } else if (bnplRatio > 0.1) {
      score -= 10;
    }

    if (goalRatio > 0.35) {
      score -= 10;
    } else if (goalRatio > 0.2) {
      score -= 5;
    }

    if (availableRatio > 0.3) {
      score += 5;
    } else if (availableRatio < 0.1) {
      score -= 10;
    }

    if (savingsBufferRatio >= 3.0) {
      score += 10;
    } else if (savingsBufferRatio >= 1.0) {
      score += 6;
    } else if (savingsBufferRatio >= 0.5) {
      score += 3;
    }

    if (score > 100) score = 100;
    if (score < 0) score = 0;

    return score;
  }
}
