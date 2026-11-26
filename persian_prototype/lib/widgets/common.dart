import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../data/voice_script.dart';
import '../services/audio_service.dart';
import '../theme.dart';

final _random = Random();

/// Picks one of the praise lines at random, plays a chime and says it.
Future<void> celebrate() async {
  AudioService.instance.correct();
  await Future<void>.delayed(const Duration(milliseconds: 450));
  await AudioService.instance
      .say(VoiceScript.praise[_random.nextInt(VoiceScript.praise.length)]);
}

/// A large round "listen again" button. Children who cannot read yet rely
/// on this button to hear the instruction again.
class SpeakerButton extends StatelessWidget {
  const SpeakerButton({super.key, required this.onPressed, this.size = 72});

  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'دوباره گوش کن',
      child: Material(
        color: AppColors.saffron,
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(Icons.volume_up_rounded, size: size * 0.55, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// A row of stars showing progress through a short activity.
class StarProgress extends StatelessWidget {
  const StarProgress({super.key, required this.earned, required this.total});

  final int earned;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedScale(
            scale: i < earned ? 1.0 : 0.8,
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            child: Icon(
              i < earned ? Icons.star_rounded : Icons.star_outline_rounded,
              color: i < earned ? AppColors.sun : AppColors.guide,
              size: 34,
            ),
          ),
      ],
    );
  }
}

/// A short "well done" overlay with a bouncing star.
class CelebrationOverlay extends StatelessWidget {
  const CelebrationOverlay({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Center(
          child: AnimatedScale(
            scale: visible ? 1 : 0.3,
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            child: const Icon(Icons.star_rounded, color: AppColors.sun, size: 220,
                shadows: [Shadow(blurRadius: 18, color: Color(0x55000000))]),
          ),
        ),
      ),
    );
  }
}

/// End-of-activity screen: stars, praise, and two big buttons.
class FinishedView extends StatelessWidget {
  const FinishedView({
    super.key,
    required this.stars,
    required this.onPlayAgain,
  });

  final int stars;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StarProgress(earned: stars, total: stars),
            const SizedBox(height: 16),
            const Text('آفرین!', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                BigButton(
                  icon: Icons.replay_rounded,
                  label: 'دوباره',
                  color: AppColors.teal,
                  onPressed: onPlayAgain,
                ),
                BigButton(
                  icon: Icons.home_rounded,
                  label: 'خانه',
                  color: AppColors.saffron,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        textStyle: const TextStyle(fontFamily: appFont, fontSize: 24, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 32),
      label: Text(label),
    );
  }
}
