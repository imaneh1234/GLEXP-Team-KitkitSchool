import 'package:material_ui/material_ui.dart';

import 'screens/home_screen.dart';
import 'theme.dart';

void main() {
  runApp(const FarsiPlayLearnApp());
}

/// Working title only. The final name must NOT use "Kitkit" or "Enuma",
/// which are trademarks of Enuma, Inc.
const String appTitle = 'بازی‌آموز';

class FarsiPlayLearnApp extends StatelessWidget {
  const FarsiPlayLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      // Persian (Iran). Setting the locale makes Flutter lay the whole
      // interface out right-to-left and mirror arrows and menus.
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const HomeScreen(),
    );
  }
}
