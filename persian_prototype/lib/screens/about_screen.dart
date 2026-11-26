import 'package:material_ui/material_ui.dart';

/// Information for parents, teachers and reviewers, including attribution.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const body = TextStyle(fontSize: 18, height: 1.8);
    return Scaffold(
      appBar: AppBar(title: const Text('درباره‌ی این برنامه')),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'این یک نمونه‌ی آزمایشی برای آموزش خواندن، نوشتن و شمردن به کودکان ۴ تا ۸ ساله است. '
                'همه‌ی بخش‌ها بدون اینترنت کار می‌کنند.',
                style: body,
              ),
              SizedBox(height: 16),
              Text(
                'با الهام از طراحی آموزشی Kitkit School ساخته شده است. '
                'Kitkit School را شرکت Enuma ساخته و با مجوزهای Apache 2.0 و CC BY 4.0 منتشر کرده است. '
                'Kitkit و Enuma نشان‌های تجاری شرکت Enuma هستند و این برنامه به آن شرکت وابسته نیست.',
                style: body,
              ),
              SizedBox(height: 16),
              Text(
                'Inspired by the learning design of Kitkit School by Enuma, Inc. '
                '(Apache License 2.0 / CC BY 4.0). Not affiliated with or endorsed by Enuma. '
                'Font: Vazirmatn by Saber Rastikerdar and contributors (SIL Open Font License 1.1).',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 15, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
