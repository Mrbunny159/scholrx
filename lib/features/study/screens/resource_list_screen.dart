import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/glass_card.dart';

class ResourceListScreen extends StatelessWidget {
  final String subjectName;
  final String resourceType; // e.g., 'Notes', 'Syllabus', 'PYQ Papers'

  const ResourceListScreen({
    super.key,
    required this.subjectName,
    required this.resourceType,
  });

  // 🔴 URL Launcher Function
  Future<void> _openResourceLink(BuildContext context, String title) async {
    // MVP Dummy Links (In future, these will come from Firebase)
    final Uri url = Uri.parse('https://www.google.com/search?q=${subjectName.replaceAll(' ', '+')}+$resourceType+PDF');

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Dummy list of units/chapters for the selected subject
    final List<String> chapters = [
      'Unit 1: Introduction & Basics',
      'Unit 2: Core Concepts',
      'Unit 3: Advanced Topics',
      'Unit 4: Practical Applications',
      'Unit 5: Case Studies & Revision',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('$subjectName - $resourceType', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.scaffoldBackgroundColor, theme.primaryColor.withValues(alpha: 0.05)],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GlassCard(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      resourceType == 'Notes' ? Icons.description : 
                      resourceType == 'Syllabus' ? Icons.picture_as_pdf : Icons.history_edu, 
                      color: theme.primaryColor
                    ),
                  ),
                  title: Text(chapters[index], style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  subtitle: Text('Tap to view document', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                  trailing: Icon(Icons.open_in_new, size: 18, color: theme.primaryColor),
                  onTap: () => _openResourceLink(context, chapters[index]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}