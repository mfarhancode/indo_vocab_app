import 'package:flutter/material.dart';

import '../data/vocabulary_repository.dart';
import '../models/vocabulary_word.dart';
import '../theme.dart';
import '../widgets/word_details.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});
  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  late Future<List<VocabularyWord>> futureWords;
  int card = 0;
  int known = 0;
  int learning = 0;
  final Set<int> bookmarked = {};

  @override
  void initState() {
    super.initState();
    futureWords = VocabularyRepository.load();
  }

  void next(int total, bool isKnown) {
    setState(() {
      if (isKnown) {
        known++;
      } else {
        learning++;
      }
      card = (card + 1) % total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        title: Text('Vocabulary', style: t(18, FontWeight.w700, cOnSurface)),
        actions: [
          FutureBuilder<List<VocabularyWord>>(
            future: futureWords,
            builder: (_, snap) => Center(
              child: Text(
                snap.hasData ? '${card + 1} / ${snap.data!.length}' : 'Loading…',
                style: t(12, FontWeight.w700, cOnSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<List<VocabularyWord>>(
        future: futureWords,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: cPrimary));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Could not load vocabulary.', style: t(15, FontWeight.w600, cError)));
          }
          final words = snapshot.data!;
          final word = words[card % words.length];
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: (card + 1) / words.length,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(color: cSurfaceContainer, borderRadius: BorderRadius.circular(99)),
                            child: Row(
                              children: [
                                const Icon(Icons.auto_awesome, size: 15, color: cSecondary),
                                const SizedBox(width: 5),
                                Text('Frequency #${word.frequencyRank}', style: t(12, FontWeight.w700, cSecondary)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Usage, example, and collocation',
                            onPressed: word.hasExtras ? () => showWordExtrasSheet(context, word) : null,
                            icon: Icon(
                              Icons.info_outline_rounded,
                              color: word.hasExtras ? cPrimary : cOutlineVariant,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (bookmarked.contains(word.wordId)) {
                                  bookmarked.remove(word.wordId);
                                } else {
                                  bookmarked.add(word.wordId);
                                }
                              });
                            },
                            icon: Icon(
                              bookmarked.contains(word.wordId) ? Icons.bookmark : Icons.bookmark_border,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: cSurfaceContainer),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(word.indonesian, textAlign: TextAlign.center, style: t(34, FontWeight.w800, cOnSurface)),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                                  decoration: BoxDecoration(color: cSecondaryFixed, borderRadius: BorderRadius.circular(8)),
                                  child: Text(word.pos, style: t(11, FontWeight.w700, cSecondary)),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  word.translation,
                                  textAlign: TextAlign.center,
                                  style: t(18, FontWeight.w600, cOnSurfaceVariant, height: 1.4),
                                ),
                                const SizedBox(height: 18),
                                TextButton.icon(
                                  onPressed: word.hasExtras ? () => showWordExtrasSheet(context, word) : null,
                                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                                  label: Text(
                                    word.hasExtras ? 'Example & collocation' : 'No extra notes',
                                    style: t(13, FontWeight.w700, word.hasExtras ? cPrimary : cOnSurfaceVariant),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => next(words.length, false),
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Still learning'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                side: BorderSide.none,
                                backgroundColor: cSurfaceHigh,
                                foregroundColor: cOnSurface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => next(words.length, true),
                              icon: const Icon(Icons.check_circle, size: 18),
                              label: const Text('I know it!'),
                              style: FilledButton.styleFrom(
                                backgroundColor: cTertiaryFixed,
                                foregroundColor: cTertiary,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
