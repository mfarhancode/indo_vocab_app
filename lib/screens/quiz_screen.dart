import 'package:flutter/material.dart';

import '../theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int selected = -1;
  final answers = ['to clean', 'to defend', 'to borrow', 'to travel'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        title: Text('Practice', style: t(18, FontWeight.w700, cOnSurface)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('5 / 8', style: t(12, FontWeight.w700, cOnSurfaceVariant))),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: cSurfaceContainer, borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: [
                        const Icon(Icons.psychology_alt_rounded, color: cPrimary),
                        const SizedBox(width: 10),
                        Text('Affixation Reflex', style: t(14, FontWeight.w700, cPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('What does “mempertahankan” mean?', style: t(24, FontWeight.w800, cOnSurface)),
                  const SizedBox(height: 8),
                  Text('Choose the closest English meaning.', style: t(14, FontWeight.w500, cOnSurfaceVariant)),
                  const SizedBox(height: 22),
                  ...List.generate(4, (i) {
                    final active = selected == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => setState(() => selected = i),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: active ? cPrimary.withOpacity(.08) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: active ? cPrimary : cSurfaceContainer, width: active ? 1.5 : 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: active ? cPrimary : cSurfaceHigh),
                                child: Text(
                                  String.fromCharCode(65 + i),
                                  style: t(11, FontWeight.w800, active ? Colors.white : cOnSurfaceVariant),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(answers[i], style: t(14, FontWeight.w600, cOnSurface)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: selected < 0 ? null : () => setState(() => selected = 1),
                      style: FilledButton.styleFrom(
                        backgroundColor: cPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Check answer', style: t(15, FontWeight.w700, Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
