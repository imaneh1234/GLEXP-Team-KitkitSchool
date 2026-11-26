import 'package:material_ui/material_ui.dart';

import '../data/voice_script.dart';
import '../main.dart' show appTitle;
import '../services/audio_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'about_screen.dart';
import 'counting_screen.dart';
import 'letter_sounds_screen.dart';
import 'tracing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      _Activity(
        title: 'صدای حرف‌ها',
        voice: VoiceScript.homeSounds,
        icon: Icons.hearing_rounded,
        color: AppColors.teal,
        builder: (_) => const LetterSoundsScreen(),
      ),
      _Activity(
        title: 'بنویسیم',
        voice: VoiceScript.homeTracing,
        icon: Icons.gesture_rounded,
        color: AppColors.saffron,
        builder: (_) => const TracingScreen(),
      ),
      _Activity(
        title: 'بشماریم',
        voice: VoiceScript.homeCounting,
        icon: Icons.apps_rounded,
        color: AppColors.pomegranate,
        builder: (_) => const CountingScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
        // In right-to-left layouts "leading" sits on the right and
        // "actions" on the left, automatically.
        leading: Padding(
          padding: const EdgeInsets.all(6),
          child: SpeakerButton(
            size: 44,
            onPressed: () => AudioService.instance.say(VoiceScript.welcome),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'درباره‌ی این برنامه (برای بزرگ‌ترها)',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => const AboutScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [for (final a in activities) _ActivityTile(activity: a)],
            ),
          ),
        ),
      ),
    );
  }
}

class _Activity {
  const _Activity({
    required this.title,
    required this.voice,
    required this.icon,
    required this.color,
    required this.builder,
  });

  final String title;
  final VoiceLine voice;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final _Activity activity;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final size = (width - 72).clamp(150.0, 230.0);
    return Semantics(
      button: true,
      label: activity.title,
      child: Material(
        color: activity.color,
        elevation: 4,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () {
            AudioService.instance.say(activity.voice);
            Navigator.of(context).push(MaterialPageRoute<void>(builder: activity.builder));
          },
          child: SizedBox(
            width: size,
            height: size,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(activity.icon, size: size * 0.45, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  activity.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
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
