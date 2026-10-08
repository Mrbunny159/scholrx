import 'package:flutter/material.dart';
import '../../../core/widgets/glass_card.dart';
import 'subject_detail_screen.dart'; // Isko hum next banayenge

class PlacementPrepScreen extends StatelessWidget {
  const PlacementPrepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dummy Placement Subjects
    final List<Map<String, dynamic>> subjects = [
      {'name': 'Python', 'icon': Icons.code, 'color': Colors.blue},
      {'name': 'Java', 'icon': Icons.coffee, 'color': Colors.orange},
      {'name': 'System Design', 'icon': Icons.architecture, 'color': Colors.purple},
      {'name': 'Networking', 'icon': Icons.router, 'color': Colors.teal},
      {'name': 'Data Engineering', 'icon': Icons.dataset, 'color': Colors.indigo},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Placement Prep', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.primaryColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubjectDetailScreen(
                        subjectName: subject['name'],
                        iconColor: subject['color'],
                      ),
                    ),
                  );
                },
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (subject['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(subject['icon'], size: 28, color: subject['color']),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject['name'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Interview Q&A, MCQs & Coding',
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}