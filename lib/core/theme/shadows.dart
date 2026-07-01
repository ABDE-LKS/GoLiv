import 'package:flutter/material.dart';

class AppShadows {
  // Elevation — Cards: 0px offset, 8px blur, 4% black opacity
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 0),
    ),
  ];

  static List<BoxShadow> bottomSheetShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, -4),
    ),
  ];
}
