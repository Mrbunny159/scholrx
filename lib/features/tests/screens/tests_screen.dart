import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class TestsScreen extends ConsumerStatefulWidget {
  const TestsScreen({super.key});

  @override
  ConsumerState<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends ConsumerState<TestsScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Available', 'Attempted', 'Bookmarks'];

  // Mock Tests Data - Isko baad me Firebase 'mock_tests' collection se map karenge
  final List<Map<String, dynamic>> _mockTests = [
    {
      'title': 'DBMS Mock Test 1',
      'questions': 20,
      'duration': 30,
      'icon': Icons.storage_rounded,
    },
    {
      'title': 'Operating Systems Test',
      'questions': 25,
      'duration': 30,
      'icon': Icons.terminal_rounded,
    },
    {
      'title': 'Computer Networks Test',
      'questions': 20,
      'duration': 25,
      'icon': Icons.lan_rounded,
    },
    {
      'title': 'Python Programming Test',
      'questions': 30,
      'duration': 40,
      'icon': Icons.code_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 120), // Bottom padding for Nav Bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            const Text(
              "Mock Tests",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),

            // 2. Hero Banner (Assessment Vibe)
            _buildHeroBanner(),
            const SizedBox(height: 32),

            // 3. Custom Tab Bar (Available, Attempted, etc.)
            _buildCustomTabBar(),
            const SizedBox(height: 24),

            // 4. Mock Tests List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _mockTests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildTestCard(_mockTests[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 Hero Banner Card
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow(),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryLightTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics_rounded, color: AppColors.primaryBlue, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Test. Analyze. Improve.",
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Boost your score with our mock tests.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎛️ Custom Tab Navigation
  Widget _buildCustomTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_tabs.length, (index) {
        bool isSelected = _selectedTabIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          child: Column(
            children: [
              Text(
                _tabs[index],
                style: TextStyle(
                  color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Animated Underline Indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 3,
                width: isSelected ? 40 : 0,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  // 📝 Test Card Item
  Widget _buildTestCard(Map<String, dynamic> test) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow(),
      ),
      child: Row(
        children: [
          // Blue Tinted Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLightTint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(test['icon'], color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          
          // Test Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test['title'],
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "${test['questions']} Questions • ${test['duration']} Min",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Action Button
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to Test Engine Screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLightTint, // Light background
              foregroundColor: AppColors.primaryBlue, // Blue text
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Start", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  List<BoxShadow> _softShadow() {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.02),
        blurRadius: 15,
        offset: const Offset(0, 4),
      ),
    ];
  }
}