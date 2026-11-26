import 'package:material_ui/material_ui.dart';

/// Colours and type for the prototype. Warm, calm and high-contrast.
class AppColors {
  static const background = Color(0xFFFFF6E5); // warm paper
  static const ink = Color(0xFF264653); // dark blue-green text
  static const teal = Color(0xFF2A9D8F);
  static const saffron = Color(0xFFF4A261);
  static const sun = Color(0xFFE9C46A);
  static const pomegranate = Color(0xFFD62839);
  static const leaf = Color(0xFF52B788);
  static const guide = Color(0xFFE3D7C3); // tracing guide
  static const card = Colors.white;
}

const String appFont = 'Vazirmatn';

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: appFont,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      surface: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: appFont,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    ),
  );
}
