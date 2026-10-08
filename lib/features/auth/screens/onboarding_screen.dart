import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'splash_screen.dart'; // GridPainter import karne ke liye
import '../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {'id': 'SYS_01', 'title': 'Knowledge Database', 'desc': 'Access your B.Sc IT curriculum, study materials, and PYQs globally.', 'icon': Icons.folder_shared_rounded},
    {'id': 'SYS_02', 'title': 'AI Copilot', 'desc': 'Engage ScholrX AI. Decrypt complex bugs and DBMS queries instantly.', 'icon': Icons.memory_rounded},
    {'id': 'SYS_03', 'title': 'Telemetry Sync', 'desc': 'Track attendance thresholds and GPA performance with live analytics.', 'icon': Icons.radar_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomPaint(
        painter: BlueprintGridPainter(), // 🟢 Blueprint Grid Background
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('[ SKIP_SEQ ]', style: TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(slide['id'], style: const TextStyle(fontFamily: 'monospace', color: AppColors.primaryBlue, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(16), color: AppColors.surface),
                            child: Icon(slide['icon'], size: 48, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 32),
                          Text(slide['title'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          const SizedBox(height: 16),
                          Text(slide['desc'], style: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("PHASE [ ${_currentPage + 1} / ${_slides.length} ]", style: const TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {
                        if (_currentPage == _slides.length - 1) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        } else {
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          _currentPage == _slides.length - 1 ? 'INITIALIZE' : 'NEXT_NODE',
                          style: const TextStyle(fontFamily: 'monospace', color: AppColors.surface, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}