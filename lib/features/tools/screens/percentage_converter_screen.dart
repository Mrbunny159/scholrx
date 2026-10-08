import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';

class PercentageConverterScreen extends StatefulWidget {
  const PercentageConverterScreen({super.key});

  @override
  State<PercentageConverterScreen> createState() => _PercentageConverterScreenState();
}

class _PercentageConverterScreenState extends State<PercentageConverterScreen> {
  final TextEditingController _cgpaController = TextEditingController();
  double _percentage = 0.0;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _autoFetchCgpa();
  }

  Future<void> _autoFetchCgpa() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null && doc.data()!.containsKey('overall_cgpa')) {
          double savedCgpa = (doc.data()!['overall_cgpa'] as num).toDouble();
          setState(() => _cgpaController.text = savedCgpa.toStringAsFixed(2));
          _calculatePercentage();
        }
      } catch (e) {
        debugPrint("ERR: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  void _calculatePercentage() {
    double cgpa = double.tryParse(_cgpaController.text) ?? 0.0;
    setState(() {
      if (cgpa > 0 && cgpa <= 10) _percentage = (cgpa * 7.1) + 11; 
      else _percentage = 0.0;
    });
  }

  Future<void> _saveToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _percentage == 0.0) return;

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'overall_cgpa': double.tryParse(_cgpaController.text),
        'overall_percentage': double.parse(_percentage.toStringAsFixed(2)),
      }, SetOptions(merge: true));

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Payload Updated!'), backgroundColor: AppColors.successGreen));
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
        title: const Text('Data Conversion', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)), 
        backgroundColor: AppColors.background, 
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
        : Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)]),
                  child: Column(
                    children: [
                      TextField(
                        controller: _cgpaController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (val) => _calculatePercentage(),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'monospace'),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Input CGPA Index',
                          labelStyle: const TextStyle(color: AppColors.textSecondary, fontFamily: 'monospace', fontSize: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.2))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text('CONVERTED VALUE', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 2)),
                      const SizedBox(height: 16),
                      Text(
                        '${_percentage.toStringAsFixed(2)}%',
                        style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, letterSpacing: -2),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Algorithm: (CGPA x 7.1) + 11', 
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: _isSaving ? null : _saveToFirebase,
                    child: _isSaving 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.surface, strokeWidth: 2)) 
                        : const Text('[ INJECT TO PROFILE ]', style: TextStyle(color: AppColors.surface, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1.5)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }
}