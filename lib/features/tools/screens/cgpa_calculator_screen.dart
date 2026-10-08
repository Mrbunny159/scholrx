import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';

class CgpaCalculatorScreen extends StatefulWidget {
  const CgpaCalculatorScreen({super.key});

  @override
  State<CgpaCalculatorScreen> createState() => _CgpaCalculatorScreenState();
}

class _CgpaCalculatorScreenState extends State<CgpaCalculatorScreen> {
  Map<String, double> savedSgpas = {};
  bool _isLoading = true;
  double _cgpa = 0.0;
  double _percentage = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchAndCalculateCgpa();
  }

  Future<void> _fetchAndCalculateCgpa() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('academic_records').doc('sgpa_records').get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        Map<String, double> fetchedSgpas = {};
        double totalSgpa = 0.0;
        int count = 0;

        data.forEach((key, value) {
          if (key.startsWith('Sem ') && value['sgpa'] != null) {
            double sgpa = (value['sgpa'] as num).toDouble();
            fetchedSgpas[key] = sgpa;
            totalSgpa += sgpa;
            count++;
          }
        });

        var sortedKeys = fetchedSgpas.keys.toList()..sort();
        Map<String, double> sortedSgpas = {for (var k in sortedKeys) k: fetchedSgpas[k]!};

        double finalCgpa = count > 0 ? (totalSgpa / count) : 0.0;
        double finalPercentage = finalCgpa > 0 ? ((finalCgpa * 7.1) + 11) : 0.0;

        setState(() {
          savedSgpas = sortedSgpas;
          _cgpa = finalCgpa;
          _percentage = finalPercentage;
        });

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'overall_cgpa': double.parse(_cgpa.toStringAsFixed(2)),
          'overall_percentage': double.parse(_percentage.toStringAsFixed(2)),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("ERR: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(children: const [Icon(Icons.info_outline, color: AppColors.primaryBlue), SizedBox(width: 8), Text('Calculations Info')]),
        content: const Text(
          "1. CGPA:\nCalculated as the average of all your saved SGPAs.\n\n2. Percentage:\nUses the standard Mumbai University 10-point scale formula:\nPercentage = (CGPA × 7.1) + 11",
          style: TextStyle(height: 1.5, color: AppColors.textPrimary),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it!', style: TextStyle(color: AppColors.primaryBlue)))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Overall CGPA', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)), 
        backgroundColor: AppColors.background, 
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [IconButton(icon: const Icon(Icons.info_outline, color: AppColors.primaryBlue), onPressed: _showInfoDialog)],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Avg CGPA', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'monospace')),
                          const SizedBox(height: 8),
                          Text(_cgpa.toStringAsFixed(2), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      Container(width: 1, height: 60, color: AppColors.divider),
                      Column(
                        children: [
                          const Text('Percentage', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'monospace')),
                          const SizedBox(height: 8),
                          Text('${_percentage.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Fetched Semester SGPAs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
              ),

              Expanded(
                child: savedSgpas.isEmpty 
                  ? const Center(child: Text('// NO RECORDS DETECTED\nSave SGPAs first to generate index.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontFamily: 'monospace')))
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      itemCount: savedSgpas.length,
                      itemBuilder: (context, index) {
                        String semKey = savedSgpas.keys.elementAt(index);
                        double sgpaValue = savedSgpas[semKey]!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.bookmark_added_rounded, color: AppColors.primaryBlue, size: 24),
                                    const SizedBox(width: 16),
                                    Text(semKey, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                                  ],
                                ),
                                Text(sgpaValue.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primaryBlue, fontFamily: 'monospace')),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
    );
  }
}