import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'cgpa_calculator_screen.dart';
import 'sgpa_calculator_screen.dart';
import 'percentage_converter_screen.dart';
import 'attendance_screen.dart';
import 'planner_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Academic Tools', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const Text('// SELECT A MODULE TO EXECUTE', style: TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 20),
          _buildToolCard(
            context,
            title: 'Attendance Tracker',
            subtitle: 'Monitor 75% criteria via calendar matrix',
            icon: Icons.fact_check_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen())),
          ),
          _buildToolCard(
            context,
            title: 'Study Planner',
            subtitle: 'Task scheduling and reminder protocols',
            icon: Icons.calendar_month_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlannerScreen())),
          ),
          _buildToolCard(
            context,
            title: 'CGPA Calculator',
            subtitle: 'Compute overall degree performance index',
            icon: Icons.calculate_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CgpaCalculatorScreen())),
          ),
          _buildToolCard(
            context,
            title: 'SGPA Calculator',
            subtitle: 'Calculate current semester grade points',
            icon: Icons.functions,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SgpaCalculatorScreen())),
          ),
          _buildToolCard(
            context,
            title: 'Percentage Converter',
            subtitle: 'Convert CGPA via University standard formula',
            icon: Icons.percent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PercentageConverterScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primaryLightTint, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, size: 28, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace')),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}