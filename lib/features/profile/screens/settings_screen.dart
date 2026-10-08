import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/providers/user_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController nameController = TextEditingController();
  String? selectedCourse;
  String? selectedSem;
  String? selectedTarget;
  bool isSaving = false;

  // 🔴 Multi-select support ke liye array list banayi
  List<String> selectedGoals = [];

  final List<String> courses = ['B.Sc IT', 'B.Sc CS', 'B.Sc Data Science'];
  final List<String> semesters = ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4', 'Sem 5', 'Sem 6', 'Sem 7', 'Sem 8'];
  final List<String> goals = ['Pass Semester', 'Improve SGPA', 'Improve CGPA', 'Placement Prep', 'Learn Programming'];
  final List<String> targets = ['30 min', '1 hour', '2 hours', '3+ hours'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userData = ref.read(userDataProvider).value;
      if (userData != null) {
        setState(() {
          nameController.text = userData['fullName'] ?? '';
          selectedCourse = userData['course'];
          selectedSem = userData['semester'];
          selectedTarget = userData['dailyTarget'];
          
          // Firebase se existing selected goals array fetch karne ke liye
          if (userData['primaryGoals'] != null) {
            selectedGoals = List<String>.from(userData['primaryGoals']);
          } else if (userData['primaryGoal'] != null) {
            // Safe fallback agar purana single text data pada ho database me
            selectedGoals = [userData['primaryGoal']];
          }
        });
      }
    });
  }

  Future<void> updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fullName': nameController.text.trim(),
        'course': selectedCourse,
        'semester': selectedSem,
        'primaryGoals': selectedGoals, // Array format me save ho raha hai
        'dailyTarget': selectedTarget,
      });
      
      await user.updateDisplayName(nameController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.primaryColor.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PERSONAL DETAILS', style: _labelStyle(theme)),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: nameController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    prefixIcon: Icon(Icons.person_outline, color: theme.primaryColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              Text('ACADEMICS', style: _labelStyle(theme)),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildDropdown('Course', courses, selectedCourse, (val) => setState(() => selectedCourse = val), theme),
                    const SizedBox(height: 18),
                    _buildDropdown('Semester', semesters, selectedSem, (val) => setState(() => selectedSem = val), theme),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Text('GOALS & TARGETS', style: _labelStyle(theme)),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Primary Goal (Multi-Select)', theme),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 12,
                      children: goals.map((g) {
                        final isSelected = selectedGoals.contains(g);
                        return _buildFilterChip(g, isSelected, () {
                          setState(() {
                            if (isSelected) {
                              selectedGoals.remove(g);
                            } else {
                              selectedGoals.add(g);
                            }
                          });
                        }, theme);
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Daily Study Target', theme),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 12,
                      children: targets.map((t) {
                        return _buildChoiceChip(t, selectedTarget == t, () {
                          setState(() => selectedTarget = t);
                        }, theme);
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isSaving ? null : updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: isSaving 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle(ThemeData theme) => TextStyle(
        fontSize: 12, 
        fontWeight: FontWeight.bold, 
        letterSpacing: 1.4, 
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5)
      );
  
  Widget _buildSectionTitle(String title, ThemeData theme) => Text(
        title, 
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)
      );

  Widget _buildDropdown(String hint, List<String> items, String? value, Function(String?) onChanged, ThemeData theme) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: hint, 
        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
      ),
      dropdownColor: theme.colorScheme.surface,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: theme.colorScheme.onSurface)))).toList(),
      onChanged: onChanged,
    );
  }

  // 🟢 Multi-Select Box Helper (FilterChip)
  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, ThemeData theme) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: true,
      checkmarkColor: Colors.white,
      selectedColor: theme.primaryColor,
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.colorScheme.onSurface, 
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.15)
        )
      ),
    );
  }

  // 🔵 Single-Select Box Helper (ChoiceChip)
  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap, ThemeData theme) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.primaryColor,
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.colorScheme.onSurface, 
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.15)
        )
      ),
    );
  }
}