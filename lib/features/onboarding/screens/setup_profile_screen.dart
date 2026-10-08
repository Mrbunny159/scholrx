import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../dashboard/screens/main_dashboard.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/screens/splash_screen.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  String? selectedCourse;
  String? selectedSem;
  String? selectedYear;
  String? selectedGoal;
  String? selectedTarget;
  
  bool _isLoadingMetaData = true;
  bool isSaving = false;

  // 🔴 DATABASE AUTONOMOUS FALLBACK SELECTION LISTS
  List<String> courses = [];
  List<String> semesters = [];
  List<String> years = [];
  List<String> goals = [];
  List<String> targets = [];

  @override
  void initState() {
    super.initState();
    _fetchConfigurationMetaData();
  }

  // 🧠 LIVE FIRESTORE SYNC: Fetch dropdown lists from 'app_metadata' or fallback safely
  Future<void> _fetchConfigurationMetaData() async {
    try {
      final metaDoc = await FirebaseFirestore.instance.collection('app_metadata').doc('profile_options').get();
      
      if (metaDoc.exists && metaDoc.data() != null) {
        final data = metaDoc.data()!;
        setState(() {
          courses = List<String>.from(data['courses'] ?? []);
          semesters = List<String>.from(data['semesters'] ?? []);
          years = List<String>.from(data['years'] ?? []);
          goals = List<String>.from(data['goals'] ?? []);
          targets = List<String>.from(data['targets'] ?? []);
          _isLoadingMetaData = false;
        });
      } else {
        // Fallback local assignments agar collection runtime empty mile
        _loadLocalFallbacks();
      }
    } catch (e) {
      debugPrint("Metadata trace failed, running fallbacks: $e");
      _loadLocalFallbacks();
    }
  }

  void _loadLocalFallbacks() {
    setState(() {
      courses = ['B.Sc IT', 'B.Sc CS', 'B.Sc Data Science'];
      semesters = ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4', 'Sem 5', 'Sem 6', 'Sem 7 (Honours)', 'Sem 8 (Honours)'];
      years = ['2023', '2024', '2025', '2026'];
      goals = ['Pass Semester', 'Improve SGPA', 'Improve CGPA', 'Placement Prep', 'Learn Programming'];
      targets = ['30 min', '1 hour', '2 hours', '3+ hours'];
      _isLoadingMetaData = false;
    });
  }

  Future<void> saveProfileToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': user.displayName ?? 'Student',
        'email': user.email,
        'course': selectedCourse,
        'semester': selectedSem,
        'admissionYear': selectedYear,
        'primaryGoal': selectedGoal,
        'dailyTarget': selectedTarget,
        'profilePicUrl': '', 
        'isPremium': false,
        'createdAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': true,
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboard()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERR: CONFIG_WRITE_FAILED -> $e'), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFormComplete = selectedCourse != null && 
                                selectedSem != null && 
                                selectedYear != null && 
                                selectedGoal != null && 
                                selectedTarget != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoadingMetaData
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : CustomPaint(
              painter: BlueprintGridPainter(),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NODE_INITIALIZATION', 
                        style: TextStyle(fontFamily: 'monospace', color: AppColors.primaryBlue, letterSpacing: 1.5, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 8),
                      const Text('Configure Profile', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      const Text('// WRITE ACADEMIC PARAMETERS TO DATABASE', style: TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 32),

                      // Profile Avatar Node
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3), width: 2),
                              ),
                              child: const CircleAvatar(
                                radius: 46,
                                backgroundColor: AppColors.surface,
                                child: Icon(Icons.person_outline_rounded, size: 44, color: AppColors.primaryBlue),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: AppColors.textPrimary, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt_outlined, size: 14, color: AppColors.surface),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Section 1: Academics
                      const Text('// LAYER_1: ACADEMICS', style: TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _softShadow(),
                          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          children: [
                            _buildDropdown('SELECT_COURSE', courses, selectedCourse, (val) => setState(() => selectedCourse = val)),
                            const SizedBox(height: 16),
                            _buildDropdown('SELECT_SEMESTER', semesters, selectedSem, (val) => setState(() => selectedSem = val)),
                            const SizedBox(height: 16),
                            _buildDropdown('ADMISSION_YEAR', years, selectedYear, (val) => setState(() => selectedYear = val)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Section 2: Goals Protocols
                      const Text('// LAYER_2: GOAL_PROTOCOLS', style: TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _softShadow(),
                          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PRIMARY_GOAL', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: goals.map((goal) => _buildChip(goal, selectedGoal == goal, () => setState(() => selectedGoal = goal))).toList(),
                            ),
                            const SizedBox(height: 24),
                            const Text('DAILY_STUDY_TARGET', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: targets.map((target) => _buildChip(target, selectedTarget == target, () => setState(() => selectedTarget = target))).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Submit Action Button
                      GestureDetector(
                        onTap: (isFormComplete && !isSaving) ? saveProfileToFirestore : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: isFormComplete 
                                ? AppColors.textPrimary 
                                : AppColors.textSecondary.withValues(alpha: 0.2), 
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isFormComplete 
                                ? [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 5))]
                                : [],
                          ),
                          child: Center(
                            child: isSaving
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: AppColors.surface, strokeWidth: 2)),
                                      SizedBox(width: 12),
                                      Text("COMPILING...", style: TextStyle(fontFamily: 'monospace', color: AppColors.surface, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                    ],
                                  )
                                : Text(
                                    isFormComplete ? '[ COMPILE_AND_LAUNCH ]' : '// REQ: ALL_PARAMETERS',
                                    style: TextStyle(
                                      fontFamily: 'monospace', 
                                      color: isFormComplete ? AppColors.surface : AppColors.textSecondary, 
                                      fontWeight: FontWeight.bold, 
                                      letterSpacing: 1.5
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown(String hint, List<String> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.15))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
        filled: true,
        fillColor: AppColors.background,
      ),
      dropdownColor: AppColors.surface,
      hint: Text(hint, style: const TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary, fontSize: 13, letterSpacing: 1)),
      value: value,
      icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontFamily: 'monospace', color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryBlue,
      labelStyle: TextStyle(
        fontFamily: 'monospace',
        color: isSelected ? Colors.white : AppColors.textPrimary, 
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12
      ),
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? AppColors.primaryBlue : AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
    );
  }

  List<BoxShadow> _softShadow() => [BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 15, offset: const Offset(0, 4))];
}