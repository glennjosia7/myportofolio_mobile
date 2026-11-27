import 'package:material_ui/material_ui.dart';

/// Design tokens derived from the Django MyPortfolio website (`static/css/style.css`).
abstract final class AppColors {
  static const paper = Color(0xFF071525);
  static const surface = Color(0xFF0D2236);
  static const surfaceElevated = Color(0xFF123750);
  static const accent = Color(0xFF36C2AE);
  static const accentPressed = Color(0xFF2AA896);
  // Harmonized dark-slate badge surface (8.76:1 contrast with ink).
  static const accentSlate = Color(0xFF1E4B66);
  static const ink = Color(0xFFF6F8FB);
  static const muted = Color(0xFFA9BBCA);
  static const line = Color(0xFF27455B);
  // WCAG 1.4.11 adapted idle input border (3.36:1 against #0D2236 surface).
  static const inputBorder = Color(0xFF4B7794);
  static const danger = Color(0xFFB42318);
  static const errorText = Color(0xFFFF9B8F);
  static const success = Color(0xFF22C55E);
  // Derived warning indicator paired with explicit message copy.
  static const warning = Color(0xFFF59E0B);
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  // Keeps bottom form CTAs clear of transient SnackBars on compact phones.
  static const double formBottomInset = 80;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 10;
  static const double avatar = 14;
  static const double pill = 999;
}

abstract final class AppLayout {
  static const double maxHomeWidth = 840;
  static const double maxFormWidth = 560;
  static const double maxLoginWidth = 440;
  static const double borderWidth = 1;
}
