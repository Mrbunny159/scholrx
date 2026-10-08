import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BaseScreenLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;

  const BaseScreenLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🟢 FIXED: Ab yeh naya Apple background color use karega
      backgroundColor: AppColors.background, 
      appBar: title != null
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: showBackButton
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              title: Text(
                title!,
                style: const TextStyle(
                  color: AppColors.textPrimary, 
                  fontSize: 24, 
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3, // Apple uses tight letter spacing for headers
                ),
              ),
              actions: actions,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Generous Apple-style whitespace
          child: child,
        ),
      ),
    );
  }
}