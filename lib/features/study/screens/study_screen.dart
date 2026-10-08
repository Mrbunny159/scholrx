import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/user_provider.dart';
// 🔴 FIX: Dashboard import kiya taaki 'studyFilterIndexProvider' mil sake
import '../../dashboard/screens/main_dashboard.dart'; 
import 'subject_detail_screen.dart';

final dynamicSubjectsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userSem) {
  final String formattedSemDoc = userSem.startsWith('Sem') ? userSem : 'Sem $userSem';

  return FirebaseFirestore.instance
      .collection('academic_content')
      .doc('B.Sc IT')
      .collection('semesters')
      .doc(formattedSemDoc)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) return [];
        
        final data = snapshot.data()!;
        if (data['subjects'] == null) return [];

        final List<dynamic> subjectsList = data['subjects'];
        return subjectsList.map((item) {
          if (item is Map) {
            return {
              'id': item['subjectId'] ?? '',
              'name': item['name'] ?? 'Unknown Module',
              'notesCount': item['notesCount'] ?? 0,
              'pyqCount': item['pyqCount'] ?? 0,
              'modules': item['modules'] ?? [],
            };
          }
          return {
            'id': '',
            'name': item.toString(),
            'notesCount': 0,
            'pyqCount': 0,
            'modules': [],
          };
        }).toList();
      });
});

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  final List<String> _filters = ['All', 'Notes', 'PYQs', 'Books', 'Imp. Qs'];

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userDataProvider);
    
    // 🧠 GLOBAL ROUTER STATE: Ab filter yahan se control hoga
    final currentFilterIndex = ref.watch(studyFilterIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        error: (err, stack) => Center(child: Text('ERR: OFFLINE_MODE -> $err', style: const TextStyle(fontFamily: 'monospace'))),
        data: (userData) {
          final String userSemester = userData?['semester'] ?? 'Sem 4';
          final subjectsAsync = ref.watch(dynamicSubjectsProvider(userSemester));

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userSemester.startsWith('Sem') ? "$userSemester Core" : "Semester $userSemester",
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                const Text('// SELECT ARCHITECTURE MODULE TO ACCESS CONTENT', style: TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 20),
                
                _buildSearchBar(),
                const SizedBox(height: 24),
                
                // 🔴 UI mein filter tabs pass kiye
                _buildFilterTabs(currentFilterIndex),
                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Core Modules", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("System Verified", style: TextStyle(color: AppColors.primaryBlue, fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),

                subjectsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                  error: (err, stack) => Center(child: Text('ERR: STREAM_FAILED\n$err', style: const TextStyle(color: AppColors.errorRed, fontFamily: 'monospace'))),
                  data: (subjects) {
                    if (subjects.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Center(child: Text("// DATA_NODE_EMPTY\nCheck Firestore configuration.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontFamily: 'monospace'))),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: subjects.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildSubjectCard(subjects[index]);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: _softShadow()),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search notes, blueprints, source codes...",
          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(int currentSelected) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          bool isSelected = currentSelected == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                // 🔴 Yahan pe click karne se Riverpod ka global state update hota hai
                ref.read(studyFilterIndexProvider.notifier).state = index;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : AppColors.surface,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: isSelected ? [] : _softShadow(),
                ),
                child: Center(
                  child: Text(
                    _filters[index], 
                    style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    return GestureDetector(
      onTap: () {
        // Naye UI layout par direct routing
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailScreen(subjectData: subject),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: _softShadow()),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primaryLightTint, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.terminal_rounded, color: AppColors.primaryBlue, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject['name'], style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text("${subject['notesCount']} Notes • ${subject['pyqCount']} PYQs", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 24),
          ],
        ),
      ),
    );
  }

  List<BoxShadow> _softShadow() => [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 4))];
}