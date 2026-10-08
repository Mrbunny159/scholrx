import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/glass_card.dart';

class QuizScreen extends StatefulWidget {
  final String semester;
  final String subjectName;
  const QuizScreen({super.key, required this.semester, required this.subjectName});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  bool _isTransitioning = false; // 🔴 UI Cool-down State
  
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  // 🔴 FIRESTORE: Fetch Questions
  Future<void> _fetchQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('semester', isEqualTo: widget.semester)
          .where('subject', isEqualTo: widget.subjectName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          _questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Error fetching questions: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _submitAnswer() {
    if (_selectedOptionIndex == null) return;

    setState(() {
      _isAnswered = true;
      _isTransitioning = true; // Start Cool-down UI
      if (_selectedOptionIndex == _questions[_currentIndex]['answer']) {
        _score++;
      }
    });

    // 🔴 COOL-DOWN: Wait 1.5 seconds smoothly
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          if (_currentIndex < _questions.length - 1) {
            _currentIndex++;
            _selectedOptionIndex = null;
            _isAnswered = false;
            _isTransitioning = false;
          } else {
            _isTransitioning = false;
            _saveScoreAndShowResult();
          }
        });
      }
    });
  }

  // 🔴 FIRESTORE: Save Score to Leaderboard
  Future<void> _saveScoreAndShowResult() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // 1. Save in user's personal history
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('quiz_records').add({
        'subject': widget.subjectName,
        'semester': widget.semester,
        'score': _score,
        'total': _questions.length,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Add to Global Leaderboard
      await FirebaseFirestore.instance.collection('leaderboard').doc(user.uid).set({
        'name': user.displayName ?? 'Student',
        'email': user.email,
        'total_score': FieldValue.increment(_score), // Increments global points
        'last_played': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    _showResultDialog();
  }

  void _showResultDialog() {
    final theme = Theme.of(context);
    final percentage = (_score / _questions.length) * 100;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(percentage >= 50 ? Icons.emoji_events : Icons.sentiment_dissatisfied, size: 80, color: percentage >= 50 ? Colors.amber : Colors.redAccent),
              const SizedBox(height: 20),
              Text(percentage >= 50 ? 'Test Completed!' : 'Keep Practicing!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('You scored $_score out of ${_questions.length}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text('Points added to Leaderboard! 🏆', style: TextStyle(fontSize: 12, color: theme.primaryColor)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Finish', style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: theme.primaryColor)));
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.subjectName), elevation: 0, backgroundColor: Colors.transparent),
        body: const Center(child: Text('No questions found for this quiz.')),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName, style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Text('${_currentIndex + 1}/${_questions.length}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.primaryColor)),
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.scaffoldBackgroundColor, theme.primaryColor.withValues(alpha: 0.05)])),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              color: theme.primaryColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 30),

            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Text(question['question'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, height: 1.4)),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: ListView.builder(
                itemCount: question['options'].length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedOptionIndex == index;
                  final isCorrect = index == question['answer'];
                  
                  Color optionColor = theme.colorScheme.surface;
                  Color borderColor = theme.colorScheme.onSurface.withValues(alpha: 0.1);

                  if (_isAnswered) {
                    if (isCorrect) {
                      optionColor = Colors.green.withValues(alpha: 0.2);
                      borderColor = Colors.green;
                    } else if (isSelected && !isCorrect) {
                      optionColor = Colors.redAccent.withValues(alpha: 0.2);
                      borderColor = Colors.redAccent;
                    }
                  } else if (isSelected) {
                    optionColor = theme.primaryColor.withValues(alpha: 0.1);
                    borderColor = theme.primaryColor;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: _isAnswered ? null : () => setState(() => _selectedOptionIndex = index),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: optionColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Row(
                          children: [
                            Text(String.fromCharCode(65 + index), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _isAnswered && isCorrect ? Colors.green : theme.colorScheme.onSurface)),
                            const SizedBox(width: 16),
                            Expanded(child: Text(question['options'][index], style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface))),
                            if (_isAnswered && isCorrect) const Icon(Icons.check_circle, color: Colors.green),
                            if (_isAnswered && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.redAccent),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔴 THE COOL-DOWN UI OR SUBMIT BUTTON
            if (_isTransitioning)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor)),
                    const SizedBox(width: 12),
                    Text('Analyzing... Loading next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                  ],
                ),
              )
            else if (!_isAnswered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _selectedOptionIndex == null ? Colors.grey : theme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _selectedOptionIndex == null ? null : _submitAnswer,
                child: const Text('Submit Answer', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}