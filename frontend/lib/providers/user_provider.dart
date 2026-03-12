import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = "";

  double _income = 0;
  double _expenses = 0;
  double _savingsGoal = 0;
  double _bnplCommitments = 0;
  double _currentSavings = 0;

  // Stored as 0–100 (dashboard divides by 10 to display, divides by 100 for progress bar)
  double _resilienceScore = 65.0;

  // ── Getters ──────────────────────────────────────────────────────────────
  bool   get isLoggedIn      => _isLoggedIn;
  String get userName        => _userName;
  double get income          => _income;
  double get expenses        => _expenses;
  double get savingsGoal     => _savingsGoal;
  double get bnplCommitments => _bnplCommitments;
  double get currentSavings  => _currentSavings;
  double get resilienceScore => _resilienceScore;

  double get availableToSave => _income - _expenses - _bnplCommitments;

  double get savingsRate {
    if (_income <= 0) return 0;
    return (availableToSave / _income) * 100;
  }

  double get savingsProgress {
    if (_savingsGoal <= 0) return 0;
    return (_currentSavings / _savingsGoal).clamp(0.0, 1.0);
  }

  // ── Auth ─────────────────────────────────────────────────────────────────
  Future<void> login(String name) async {
    _isLoggedIn = true;
    _userName   = name;
    notifyListeners();

    // Populate all fields from Firestore after login
    await loadFromFirestore();
  }

  void logout() {
    _isLoggedIn       = false;
    _userName         = "";
    _income           = 0;
    _expenses         = 0;
    _savingsGoal      = 0;
    _bnplCommitments  = 0;
    _currentSavings   = 0;
    _resilienceScore  = 65.0;
    notifyListeners();
  }

  // ── Load from Firestore ──────────────────────────────────────────────────
  /// Called automatically on login.
  /// Can also be called manually on pull-to-refresh.
  Future<void> loadFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) return;

      final d = doc.data()!;

      _income          = _num(d['income']);
      _expenses        = _num(d['expenses']);
      _bnplCommitments = _num(d['bnplCommitments']);
      _currentSavings  = _num(d['currentSavings'] ?? d['savings']);
      _savingsGoal     = _num(d['savingsGoal']);

      if (d['name'] != null && _userName.isEmpty) {
        _userName = d['name'] as String;
      }

      // Firestore stores resilienceScore as 0–10 (from backend scoreOut10).
      // Multiply × 10 so dashboard math works (score/10 display, score/100 bar).
      final stored = _num(d['resilienceScore']);
      if (stored > 0) {
        _resilienceScore = stored <= 10 ? stored * 10 : stored;
      } else {
        // No backend score yet — use local calculation
        _resilienceScore = _calculateResilienceScore();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('UserProvider.loadFromFirestore error: $e');
    }
  }

  // ── Financial profile ────────────────────────────────────────────────────
  void setFinancialProfile({
    required double income,
    required double expenses,
    required double savingsGoal,
    required double bnplCommitments,
  }) {
    _income          = income;
    _expenses        = expenses;
    _savingsGoal     = savingsGoal;
    _bnplCommitments = bnplCommitments;

    if (_currentSavings == 0) {
      _currentSavings = availableToSave > 0 ? availableToSave : 0.0;
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
    _currentSavings  = value < 0 ? 0 : value;
    _resilienceScore = _calculateResilienceScore();
    notifyListeners();
  }

  void updateScore(double change) {
    _resilienceScore = (_resilienceScore + change).clamp(0.0, 100.0);
    notifyListeners();
  }

  /// Called by ResilienceScreen after calcResilience succeeds.
  /// Backend returns scoreOut10 (0–10). Multiply × 10 to match
  /// the 0–100 scale that dashboard expects.
  void updateResilienceScore(double scoreOut10) {
    _resilienceScore = (scoreOut10 * 10).clamp(0.0, 100.0);
    notifyListeners();

    // Persist back to Firestore as 0–10 so calcResilience can read it
    _persistScore(scoreOut10);
  }

  Future<void> _persistScore(double scoreOut10) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'resilienceScore': scoreOut10},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('UserProvider._persistScore error: $e');
    }
  }

  // ── Local score fallback (used before backend returns) ───────────────────
  double _calculateResilienceScore() {
    if (_income <= 0) return 0;

    double score = 100;

    final expenseRatio       = _expenses        / _income;
    final bnplRatio          = _bnplCommitments / _income;
    final goalRatio          = _savingsGoal     / _income;
    final availableRatio     = availableToSave  / _income;
    final savingsBufferRatio = _currentSavings  / _income;

    if      (expenseRatio > 0.7) score -= 25;
    else if (expenseRatio > 0.5) score -= 15;
    else if (expenseRatio > 0.3) score -= 8;

    if      (bnplRatio > 0.3) score -= 30;
    else if (bnplRatio > 0.2) score -= 20;
    else if (bnplRatio > 0.1) score -= 10;

    if      (goalRatio > 0.35) score -= 10;
    else if (goalRatio > 0.2)  score -= 5;

    if      (availableRatio > 0.3) score += 5;
    else if (availableRatio < 0.1) score -= 10;

    if      (savingsBufferRatio >= 3.0) score += 10;
    else if (savingsBufferRatio >= 1.0) score += 6;
    else if (savingsBufferRatio >= 0.5) score += 3;

    return score.clamp(0.0, 100.0);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int)    return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
