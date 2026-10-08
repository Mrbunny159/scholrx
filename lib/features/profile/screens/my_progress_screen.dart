import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/glass_card.dart';

class MyProgressScreen extends StatefulWidget {
  const MyProgressScreen({super.key});

  @override
  State<MyProgressScreen> createState() => _MyProgressScreenState();
}

class _MyProgressScreenState extends State<MyProgressScreen> {
  double _cgpa = 0.0;
  int _quizPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProgress();
  }

  Future<void> _fetchProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Fetch CGPA
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data()!.containsKey('overall_cgpa')) {
          _cgpa = (userDoc.data()!['overall_cgpa'] as num).toDouble();
        }

        // Fetch Quiz Points from Leaderboard
        final leaderDoc = await FirebaseFirestore.instance.collection('leaderboard').doc(user.uid).get();
        if (leaderDoc.exists && leaderDoc.data()!.containsKey('total_score')) {
          _quizPoints = (leaderDoc.data()!['total_score'] as num).toInt();
        }
      } catch (e) {
        debugPrint("Error: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Progress')),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.scaffoldBackgroundColor, theme.primaryColor.withValues(alpha: 0.05)])),
        child: _isLoading 
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildStatCard(context, 'Academic CGPA', _cgpa > 0 ? _cgpa.toStringAsFixed(2) : 'Not Set', Icons.school_outlined, Colors.blue),
                const SizedBox(height: 16),
                _buildStatCard(context, 'Quiz Leaderboard Points', '$_quizPoints Pts', Icons.emoji_events_outlined, Colors.amber),
                const SizedBox(height: 16),
                _buildStatCard(context, 'Attendance', 'Check Tracker', Icons.fact_check_outlined, Colors.green), // Redirect to attendance
              ],
            ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}