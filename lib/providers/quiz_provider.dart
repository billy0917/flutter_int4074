import 'package:flutter/material.dart';
import '../models/quiz_question.dart';

class QuizProvider extends ChangeNotifier {
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  String? _error;

  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  QuizQuestion? get currentQuestion =>
      _questions.isEmpty ? null : _questions[_currentIndex];
  List<Map<String, dynamic>> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFinished => _currentIndex >= _questions.length;
  int get correctCount => _results.where((r) => r['isCorrect'] == true).length;
  int get totalCount => _questions.length;

  void setQuestions(List<QuizQuestion> questions) {
    _questions = questions;
    _currentIndex = 0;
    _results.clear();
    _error = null;
    notifyListeners();
  }

  void answerQuestion({
    required bool isCorrect,
    required String userAnswer,
    required String correctAnswer,
    required String questionText,
  }) {
    if (_currentIndex >= _questions.length) return;
    _results.add({
      'isCorrect': isCorrect,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'questionText': questionText,
      'type': _questions[_currentIndex].type,
    });
    notifyListeners();
  }

  void nextQuestion() {
    _currentIndex++;
    notifyListeners();
  }

  void setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  void reset() {
    _questions = [];
    _currentIndex = 0;
    _results.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  int get starRating {
    if (totalCount == 0) return 0;
    final pct = correctCount / totalCount;
    if (pct >= 0.8) return 3;
    if (pct >= 0.6) return 2;
    return 1;
  }
}
