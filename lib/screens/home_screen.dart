import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/home_cards.dart';
import 'quiz_screen.dart';
import 'update_screens.dart';
import 'vocabulary_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good morning, Julian', style: t(13, FontWeight.w500, cOnSurfaceVariant)),
                        const SizedBox(height: 3),
                        Text('Ready to learn?', style: t(25, FontWeight.w800, cOnSurface)),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: cPrimary,
                    child: Text('JD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cPrimary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('7 day streak', style: t(13, FontWeight.w600, Colors.white.withOpacity(.85))),
                          const SizedBox(height: 5),
                          Text('Keep your momentum going.', style: t(18, FontWeight.w800, Colors.white)),
                          const SizedBox(height: 13),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: const LinearProgressIndicator(
                              value: .72,
                              minHeight: 7,
                              backgroundColor: Color(0x55FFFFFF),
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 48),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text('Today', style: t(17, FontWeight.w800, cOnSurface)),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(child: StatCard(icon: Icons.menu_book_rounded, value: '18', label: 'Words')),
                  SizedBox(width: 10),
                  Expanded(child: StatCard(icon: Icons.check_circle_outline_rounded, value: '84%', label: 'Accuracy')),
                  SizedBox(width: 10),
                  Expanded(child: StatCard(icon: Icons.timer_outlined, value: '12m', label: 'Study')),
                ],
              ),
              const SizedBox(height: 20),
              Text('Continue learning', style: t(17, FontWeight.w800, cOnSurface)),
              const SizedBox(height: 10),
              ActionCard(
                icon: Icons.style_rounded,
                title: 'Vocabulary study',
                subtitle: '12 words waiting for review',
                button: 'Study now',
                onTap: () => open(context, const VocabularyScreen()),
              ),
              const SizedBox(height: 10),
              ActionCard(
                icon: Icons.psychology_alt_rounded,
                title: 'Practice quiz',
                subtitle: 'Test your understanding',
                button: 'Start quiz',
                onTap: () => open(context, const QuizScreen()),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cSurfaceContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_download_rounded, color: cTertiary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vocabulary is up to date', style: t(13, FontWeight.w700, cOnSurface)),
                          const SizedBox(height: 3),
                          Text('Offline study is ready.', style: t(12, FontWeight.w500, cOnSurfaceVariant)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => open(context, const VocabularyUpdateNotice()),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
