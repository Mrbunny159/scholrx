import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Bas itna hi code rahega is file me ab!
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);