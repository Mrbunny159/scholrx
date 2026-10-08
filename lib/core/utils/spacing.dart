import 'package:flutter/material.dart';

// Extension to use integers for spacing, e.g., 16.kH or 24.kW
extension SpacingExtension on num {
  SizedBox get kH => SizedBox(height: toDouble());
  SizedBox get kW => SizedBox(width: toDouble());
}