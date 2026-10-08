import 'package:flutter/material.dart';
import '../../../core/widgets/glass_card.dart';

class SubjectDetailScreen extends StatelessWidget {
  final String subjectName;
  final Color iconColor;

  const SubjectDetailScreen({
    super.key,
    required this.subjectName,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('$subjectName Prep', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              iconColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildCategoryCard('Basic Questions', 'Foundational theoretical concepts', Icons.format_list_bulleted, 'Easy', Colors.green, theme),
            _buildCategoryCard('OOPs Questions', 'Classes, Objects, Inheritance', Icons.data_object, 'Medium', Colors.orange, theme),
            _buildCategoryCard('Advanced / Tricky', 'Deep dive into memory & core logic', Icons.psychology, 'Hard', Colors.red, theme),
            _buildCategoryCard('MCQ Quiz', 'Test your knowledge', Icons.check_circle_outline, 'Mixed', theme.primaryColor, theme),
            _buildCategoryCard('Coding Snippets', 'Find the output & debug', Icons.code, 'Medium', Colors.blueGrey, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, IconData icon, String difficulty, Color diffColor, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: diffColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: diffColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                difficulty,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: diffColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}