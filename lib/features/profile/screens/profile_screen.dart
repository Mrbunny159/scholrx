import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/user_provider.dart';

// Import all tools screens for direct routing
import '../../tools/screens/tools_screen.dart';
import '../../tools/screens/attendance_screen.dart';
import '../../tools/screens/planner_screen.dart';
import '../../tools/screens/cgpa_calculator_screen.dart';
import '../../tools/screens/sgpa_calculator_screen.dart';
import '../../tools/screens/percentage_converter_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        error: (error, stack) => Center(child: Text('ERR: PROFILE_LOAD_FAIL\n$error', style: const TextStyle(fontFamily: 'monospace', color: AppColors.errorRed))),
        data: (userData) {
          final String fullName = userData?['fullName'] ?? 'ScholrX Agent';
          final String email = userData?['email'] ?? 'agent@scholrx.com';
          final String semester = userData?['semester'] ?? 'Sem 4';
          final String course = userData?['course'] ?? 'B.Sc. IT';

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Settings", style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const SizedBox(height: 32),
                _buildUserIdentity(fullName, email),
                const SizedBox(height: 32),

                _buildSectionTitle("Academic Preferences"),
                const SizedBox(height: 16),
                _buildAcademicInfo(semester, course),
                const SizedBox(height: 32),

                // 🟢 NEW: ALL SCREENS DIRECTORY FOLDER
                _buildSectionTitle("System Modules (Screens)"),
                const SizedBox(height: 16),
                _buildScreensDirectory(context),
                const SizedBox(height: 32),

                _buildSectionTitle("Account"),
                const SizedBox(height: 16),
                _buildSettingsGroup(context, ref),
                const SizedBox(height: 32),

                _buildLogoutButton(context, ref),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserIdentity(String name, String email) {
    return Row(
      children: [
        Container(
          height: 70, width: 70,
          decoration: BoxDecoration(color: AppColors.primaryLightTint, shape: BoxShape.circle, border: Border.all(color: AppColors.surface, width: 4), boxShadow: _softShadow()),
          child: const Center(child: Icon(Icons.person_rounded, color: AppColors.primaryBlue, size: 36)),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontFamily: 'monospace')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicInfo(String semester, String course) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: _softShadow()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Semester", style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'monospace')),
                const SizedBox(height: 8),
                Text(semester, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: _softShadow()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Course", style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'monospace')),
                const SizedBox(height: 8),
                Text(course, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 📂 DIRECTORY FOLDER FOR ALL SCREENS
  Widget _buildScreensDirectory(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: _softShadow()),
      child: Column(
        children: [
          _buildListTile(Icons.fact_check_outlined, "Attendance Tracker", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()))),
          _buildDivider(),
          _buildListTile(Icons.calendar_month_outlined, "Study Planner", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlannerScreen()))),
          _buildDivider(),
          _buildListTile(Icons.calculate_outlined, "CGPA Calculator", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CgpaCalculatorScreen()))),
          _buildDivider(),
          _buildListTile(Icons.functions, "SGPA Calculator", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SgpaCalculatorScreen()))),
          _buildDivider(),
          _buildListTile(Icons.percent, "Percentage Converter", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PercentageConverterScreen()))),
          _buildDivider(),
          _buildListTile(Icons.handyman_outlined, "Master Tools Hub", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ToolsScreen()))),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: _softShadow()),
      child: Column(
        children: [
          _buildListTile(Icons.bar_chart_rounded, "My Progress", () {}),
          _buildDivider(),
          _buildListTile(Icons.settings_outlined, "Settings", () {}),
          _buildDivider(),
          _buildListTile(Icons.help_outline_rounded, "Help & Support", () {}),
          _buildDivider(),
          _buildListTile(Icons.lock_outline_rounded, "Privacy Policy", () {}),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.divider, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, thickness: 1, color: AppColors.divider, indent: 58);

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        if (!context.mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: AppColors.errorRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.2))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 20),
            SizedBox(width: 12),
            Text("Logout", style: TextStyle(color: AppColors.errorRed, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold));
  List<BoxShadow> _softShadow() => [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 4))];
}