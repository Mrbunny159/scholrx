import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';

class SgpaCalculatorScreen extends StatefulWidget {
  const SgpaCalculatorScreen({super.key});

  @override
  State<SgpaCalculatorScreen> createState() => _SgpaCalculatorScreenState();
}

class _SgpaCalculatorScreenState extends State<SgpaCalculatorScreen> {
  String selectedSem = 'Sem 1';
  final List<String> semesters = ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4', 'Sem 5', 'Sem 6', 'Sem 7', 'Sem 8'];
  final Map<String, int> gradePoints = {'O (10)': 10, 'A+ (9)': 9, 'A (8)': 8, 'B+ (7)': 7, 'B (6)': 6, 'C (5)': 5, 'D (4)': 4, 'F (0)': 0};

  List<Map<String, dynamic>> subjects = [];
  bool _isLoadingSubjects = true;
  double _sgpa = 0.0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchSubjectsForSem();
  }

  Future<void> _fetchSubjectsForSem() async {
    setState(() => _isLoadingSubjects = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('academic_content').doc('B.Sc IT').collection('semesters').doc(selectedSem).get();

      if (doc.exists && doc.data() != null && doc.data()!['subjects'] != null) {
        List<dynamic> fetchedSubjects = doc.data()!['subjects'];
        setState(() {
          subjects = fetchedSubjects.map((item) {
            String name = (item is Map) ? (item['name'] ?? 'Unknown') : item.toString();
            return {'name': name, 'credit': 2, 'grade': 'O (10)'};
          }).toList();
        });
      } else {
        setState(() => subjects = List.generate(5, (index) => {'name': 'Subject ${index + 1}', 'credit': 2, 'grade': 'O (10)'}));
      }
      _calculateSGPA();
    } catch (e) {
      debugPrint("ERR: $e");
    } finally {
      setState(() => _isLoadingSubjects = false);
    }
  }

  void _calculateSGPA() {
    int totalCredits = 0, earnedPoints = 0;
    for (var subject in subjects) {
      int credit = subject['credit'];
      int point = gradePoints[subject['grade']]!;
      totalCredits += credit;
      earnedPoints += (credit * point);
    }
    setState(() => _sgpa = totalCredits > 0 ? (earnedPoints / totalCredits) : 0.0);
  }

  void _calculateGradeFromMarks(int index) {
    TextEditingController obtainedCtrl = TextEditingController();
    TextEditingController totalCtrl = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Grade: ${subjects[index]['name']}', style: const TextStyle(fontSize: 16, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: obtainedCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Marks Obtained')),
            const SizedBox(height: 10),
            TextField(controller: totalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Marks')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () {
              double obtained = double.tryParse(obtainedCtrl.text) ?? 0;
              double total = double.tryParse(totalCtrl.text) ?? 100;
              double percentage = (obtained / total) * 100;

              String calculatedGrade = 'F (0)';
              if (percentage >= 80) calculatedGrade = 'O (10)';
              else if (percentage >= 70) calculatedGrade = 'A+ (9)';
              else if (percentage >= 60) calculatedGrade = 'A (8)';
              else if (percentage >= 55) calculatedGrade = 'B+ (7)';
              else if (percentage >= 50) calculatedGrade = 'B (6)';
              else if (percentage >= 45) calculatedGrade = 'C (5)';
              else if (percentage >= 40) calculatedGrade = 'D (4)';

              setState(() { subjects[index]['grade'] = calculatedGrade; _calculateSGPA(); });
              Navigator.pop(context);
            },
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('academic_records').doc('sgpa_records').set({
        selectedSem: {'sgpa': _sgpa, 'updatedAt': Timestamp.now()}
      }, SetOptions(merge: true));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SGPA Database Updated!'), backgroundColor: AppColors.successGreen));
    } catch (e) {
      debugPrint('ERR: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SGPA Engine', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)), 
        backgroundColor: AppColors.background, 
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15)]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSem,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        items: semesters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) { if (val != null) { setState(() => selectedSem = val); _fetchSubjectsForSem(); } },
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Projected SGPA', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace')),
                      Text(_sgpa.toStringAsFixed(2), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: _isLoadingSubjects 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: Text(subjects[index]['name'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary))),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: subjects[index]['credit'],
                                  isExpanded: true,
                                  dropdownColor: AppColors.surface,
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                                  items: [1, 2, 3, 4, 5, 6].map((v) => DropdownMenuItem(value: v, child: Text('${v}C', style: const TextStyle(fontSize: 13)))).toList(),
                                  onChanged: (v) { setState(() => subjects[index]['credit'] = v!); _calculateSGPA(); },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: subjects[index]['grade'],
                                  isExpanded: true,
                                  dropdownColor: AppColors.surface,
                                  style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                                  items: gradePoints.keys.map((v) => DropdownMenuItem(value: v, child: Text(v.split(' ')[0], style: const TextStyle(fontSize: 13)))).toList(),
                                  onChanged: (v) { setState(() => subjects[index]['grade'] = v!); _calculateSGPA(); },
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calculate_rounded, size: 22, color: AppColors.textSecondary),
                              onPressed: () => _calculateGradeFromMarks(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveToFirebase,
        backgroundColor: AppColors.textPrimary,
        icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.surface, strokeWidth: 2)) : const Icon(Icons.cloud_upload_rounded, color: AppColors.surface),
        label: const Text('TRANSMIT DATA', style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ),
    );
  }
}