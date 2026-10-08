import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SubjectDetailScreen extends StatelessWidget {
  final Map<String, dynamic> subjectData;

  const SubjectDetailScreen({super.key, required this.subjectData});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> modules = subjectData['modules'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          subjectData['name'], 
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ Terminal Meta Dashboard
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetaStat("${subjectData['notesCount']}", "RESOURCES"),
                  Container(width: 1, height: 30, color: AppColors.divider),
                  _buildMetaStat("${subjectData['pyqCount']}", "PAST_PAPERS"),
                  Container(width: 1, height: 30, color: AppColors.divider),
                  _buildMetaStat("${modules.length}", "MODULES"),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 📂 Modules List View Blueprint
            const Text("Syllabus Structure", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("// MODULE ARCHITECTURE LOADED FROM FIREBASE", style: TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 16),

            if (modules.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text("// NO MODULES CONFIGURED", style: TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "0${index + 1}", 
                            style: const TextStyle(fontFamily: 'monospace', color: AppColors.primaryBlue, fontWeight: FontWeight.bold)
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            modules[index].toString(),
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 32),
            
            // ⚡ Access Assets Section
            const Text("Quick Downloads", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildResourceLauncherButton(Icons.description_outlined, "Study Notes")),
                const SizedBox(width: 16),
                Expanded(child: _buildResourceLauncherButton(Icons.history_edu_outlined, "PYQ Papers")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontFamily: 'monospace')),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildResourceLauncherButton(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}