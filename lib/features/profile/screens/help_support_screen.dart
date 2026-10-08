import 'package:flutter/material.dart';
import '../../../core/widgets/glass_card.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, String>> faqs = [
      {'q': 'How does the Attendance Tracker work?', 'a': 'We strictly follow the 75% rule. Tap a date to cycle between Present, Absent, and Holiday.'},
      {'q': 'Are the mock tests based on actual MU syllabus?', 'a': 'Yes, the quizzes are mapped directly to the B.Sc IT curriculum.'},
      {'q': 'How is CGPA calculated?', 'a': 'It uses the standard 10-point scale formula: (CGPA x 7.1) + 11.'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.scaffoldBackgroundColor, theme.primaryColor.withValues(alpha: 0.05)])),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.support_agent_rounded, size: 64, color: theme.primaryColor),
                  const SizedBox(height: 16),
                  Text('How can we help you?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Text('Reach out to us for any issues, bugs, or notes requests.', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email composer opening...')));
                    },
                    icon: const Icon(Icons.email_outlined, color: Colors.white),
                    label: const Text('Contact Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 16),
            ...faqs.map((faq) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ExpansionTile(
                collapsedBackgroundColor: theme.colorScheme.surface,
                backgroundColor: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text(faq['q']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                    child: Text(faq['a']!, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}