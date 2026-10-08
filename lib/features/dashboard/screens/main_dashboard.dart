import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/user_provider.dart';

// Core Application Interfaces
import '../../study/screens/study_screen.dart';
import '../../tests/screens/tests_screen.dart';
import '../../ai_assistant/screens/ai_assistant_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../tools/screens/tools_screen.dart';
import '../../placement/screens/placement_prep_screen.dart';
import '../../tools/screens/attendance_screen.dart';
import '../../tools/screens/planner_screen.dart';
import '../../tools/screens/cgpa_calculator_screen.dart';
import '../widgets/leaderboard_widget.dart';

// 🧠 RIVERPOD MULTI-TAB ROUTER CONTROL PIPELINES
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
final studyFilterIndexProvider = StateProvider<int>((ref) => 0); // 🟢 Syncs internal filters of Study Screen

class MainDashboard extends ConsumerWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> screens = [
      const HomeDashboardView(),
      const StudyScreen(),
      const TestsScreen(),
      const AIAssistantScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: screens[currentIndex],
          ),

          // Freezed Layout System Coordinates
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                child: _buildFloatingNavBar(context, ref, currentIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar(BuildContext context, WidgetRef ref, int currentIndex) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_filled, "Home", currentIndex, ref),
          _buildNavItem(1, Icons.menu_book_rounded, "Study", currentIndex, ref),
          _buildNavItem(2, Icons.quiz_rounded, "Tests", currentIndex, ref),
          _buildNavItem(3, Icons.auto_awesome, "AI", currentIndex, ref),
          _buildNavItem(4, Icons.person_rounded, "Profile", currentIndex, ref),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, int currentIndex, WidgetRef ref) {
    bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => ref.read(bottomNavIndexProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.all(isActive ? 12 : 8),
              decoration: BoxDecoration(color: isActive ? AppColors.primaryBlue : Colors.transparent, shape: BoxShape.circle),
              child: Icon(icon, color: isActive ? Colors.white : AppColors.textSecondary, size: isActive ? 22 : 26),
            ),
            if (!isActive) ...[
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500)),
            ]
          ],
        ),
      ),
    );
  }
}

class HomeDashboardView extends ConsumerWidget {
  const HomeDashboardView({super.key});

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userDataProvider);
    final attendanceAsyncValue = ref.watch(attendanceProvider);

    return userAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      error: (error, stack) => Center(child: Text('ERR: TRACE_LOST\n$error', style: const TextStyle(fontFamily: 'monospace'))),
      data: (userData) {
        final userName = userData?['fullName'] ?? 'ScholrX Agent';
        final firstName = userName.split(' ')[0];
        final currentSem = userData?['semester'] ?? 'Sem 4';
        final currentCourse = userData?['course'] ?? 'B.Sc. IT';
        
        String attendanceData = '-/-';
        attendanceAsyncValue.whenData((attData) {
          if (attData != null && attData.isNotEmpty) {
            int present = 0, total = 0;
            attData.forEach((key, value) {
              if (value == 'P') present++;
              if (value == 'P' || value == 'A') total++;
            });
            if (total > 0) attendanceData = '${((present / total) * 100).toStringAsFixed(0)}%';
          }
        });

        final String targetStudy = userData?['dailyTarget'] ?? '2 Hours';
        final String activeGoal = userData?['primaryGoal'] ?? 'Syllabus Tracker';
        final Map<String, dynamic>? lastStudiedMap = userData?['lastStudied'] != null ? Map<String, dynamic>.from(userData?['lastStudied']) : null;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(firstName),
              const SizedBox(height: 24),
              _buildSemesterPill(currentSem, currentCourse),
              const SizedBox(height: 32),
              _buildSectionTitle('Academic Snapshot', 'See All'),
              const SizedBox(height: 16),
              _buildAcademicSnapshot(context, attendanceData, targetStudy, activeGoal),
              const SizedBox(height: 32),
              _buildSectionTitle('Quick Actions', null),
              const SizedBox(height: 16),
              _buildQuickActions(context, ref), // 🔴 Injected Provider Context Here
              const SizedBox(height: 32),
              _buildSectionTitle('Continue Learning', 'See All'),
              const SizedBox(height: 16),
              _buildContinueLearningCard(lastStudiedMap, ref),
              const SizedBox(height: 32),
              const LeaderboardWidget(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(String firstName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getGreeting(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 4),
            Text("$firstName 👋", style: const TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          ],
        ),
        const CircleAvatar(radius: 22, backgroundColor: AppColors.primaryLightTint, child: Icon(Icons.person, color: AppColors.primaryBlue)),
      ],
    );
  }

  Widget _buildSemesterPill(String semester, String course) {
    final String displaySemester = semester.startsWith('Sem') ? semester : 'Semester $semester';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(100), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.school_rounded, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Text("$displaySemester • $course", style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAcademicSnapshot(BuildContext context, String attendance, String targetStudy, String activeGoal) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceScreen())),
            child: _buildStatCard("Attendance", attendance, AppColors.primaryBlue),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CgpaCalculatorScreen())),
            child: _buildStatCard("Daily Target", targetStudy, AppColors.successGreen),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PlannerScreen())),
            child: _buildStatCard("Focus", activeGoal.split(' ')[0], AppColors.warningOrange),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: 0.7, backgroundColor: AppColors.divider, color: accent, minHeight: 3, borderRadius: BorderRadius.circular(5)),
        ],
      ),
    );
  }

  // 🔴 SYNC ROUTING CODES MATRIX VIA QUICK ACTIONS
  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildActionBtn(Icons.description_outlined, "Notes", () {
          ref.read(studyFilterIndexProvider.notifier).state = 1; // 🧠 Sets 'Notes' tab automatically active
          ref.read(bottomNavIndexProvider.notifier).state = 1;  // Switch view frame window
        }),
        _buildActionBtn(Icons.history_edu, "PYQs", () {
          ref.read(studyFilterIndexProvider.notifier).state = 2; // 🧠 Sets 'PYQs' tab automatically active
          ref.read(bottomNavIndexProvider.notifier).state = 1;
        }),
        _buildActionBtn(Icons.check_circle_outline, "Quiz", () {
          ref.read(bottomNavIndexProvider.notifier).state = 2;  // Routes smoothly to Quiz window pipeline
        }),
        _buildActionBtn(Icons.auto_awesome, "AI Doubt", () {
          ref.read(bottomNavIndexProvider.notifier).state = 3;  // Drops context directly inside neural core chat
        }),
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50, width: 50,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]),
            child: Icon(icon, color: AppColors.primaryBlue, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildContinueLearningCard(Map<String, dynamic>? lastStudied, WidgetRef ref) {
    final String courseTitle = lastStudied?['title'] ?? 'No Active Session';
    final String chapterTitle = lastStudied?['unit'] ?? 'Select content in Library';
    final double rawProgress = (lastStudied?['progress'] ?? 0.0).toDouble();
    final String percentageString = lastStudied?['percentage'] ?? '0%';

    return GestureDetector(
      onTap: () {
        ref.read(studyFilterIndexProvider.notifier).state = 0; // Reset state filter context back to 'All'
        ref.read(bottomNavIndexProvider.notifier).state = 1;
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15)]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: AppColors.primaryLightTint, shape: BoxShape.circle),
              child: const Icon(Icons.code_rounded, color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(courseTitle, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(chapterTitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: rawProgress, backgroundColor: AppColors.divider, color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(10)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(percentageString, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String? action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        if (action != null) Text(action, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}