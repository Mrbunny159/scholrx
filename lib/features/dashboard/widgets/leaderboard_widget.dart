import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/glass_card.dart';

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Top Performers 🏆',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
            ],
          ),
        ),

        // Firebase Stream for Top 3 Scorers
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('leaderboard')
              .orderBy('total_score', descending: true)
              .limit(3) // Top 3 students
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2)));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Be the first one to ace the quiz and clear the board! 🔥',
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final topStudents = snapshot.data!.docs;

            return GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                children: List.generate(topStudents.length, (index) {
                  final student = topStudents[index].data() as Map<String, dynamic>;
                  final name = student['name'] ?? 'Student';
                  final score = student['total_score'] ?? 0;

                  // Rank Medals Logic
                  String rankIcon = '🏅';
                  if (index == 0) rankIcon = '🥇';
                  if (index == 1) rankIcon = '🥈';
                  if (index == 2) rankIcon = '🥉';

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    decoration: BoxDecoration(
                      border: index != topStudents.length - 1
                          ? Border(bottom: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Text(rankIcon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: index == 0 ? FontWeight.bold : FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: index == 0 ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$score Pts',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }
}