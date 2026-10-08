import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔴 IMPORT PATHS CHECK KAR LENA
import '../../dashboard/screens/main_dashboard.dart';
import 'onboarding_screen.dart';
import '../../../core/theme/app_colors.dart';

class ScholrxSplashScreen extends StatefulWidget {
  const ScholrxSplashScreen({super.key});

  @override
  State<ScholrxSplashScreen> createState() => _ScholrxSplashScreenState();
}

class _ScholrxSplashScreenState extends State<ScholrxSplashScreen> {
  int _bootStep = 0;
  final List<String> _bootLogs = [
    "> INITIALIZING SYSTEM CORE...",
    "> CONNECTING TO FIREBASE DB...",
    "> VERIFYING SECURE TOKENS...",
    "> ACCESS GRANTED."
  ];

  @override
  void initState() {
    super.initState();
    _startBootSequence();
  }

  void _startBootSequence() async {
    for (int i = 0; i < _bootLogs.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _bootStep = i + 1);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    _navigateToNext();
  }

  void _navigateToNext() {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainDashboard()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomPaint(
        painter: BlueprintGridPainter(), // 🟢 THE SECRET CYBER LAB GRID
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.security_rounded, size: 48, color: AppColors.primaryBlue),
                const SizedBox(height: 24),
                const Text(
                  'SCHOLRX // CORE',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 40),
                // Terminal Text Animation
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    _bootStep,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _bootLogs[index],
                        style: const TextStyle(
                          fontFamily: 'monospace', // 🟢 Hacker Vibe Terminal Font
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
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
}

// 🟢 FAINT BLUEPRINT GRID BACKGROUND (Use this in all 3 files)
class BlueprintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;
    
    const double step = 30.0;
    for (double i = 0; i < size.width; i += step) canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += step) canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}