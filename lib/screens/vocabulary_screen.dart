import 'package:flutter/material.dart';

import '../data/user_progress_repository.dart';
import '../models/vocabulary_word.dart';
import '../theme.dart';
import '../widgets/highlighted_sentence.dart';
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
  List<VocabularyWord>? _loadedWords;

  @override
  void initState() {
    super.initState();
    futureWords = UserProgressRepository.getStudySession(20);
  }

  void next(int wordId, bool isKnown) async {
    // Fire and forget updating the progress
    UserProgressRepository.updateProgress(wordId, isKnown);

    setState(() {
      if (isKnown) {
        known++;
      } else {
        learning++;
      }
      card++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        title: Text('Vocabulary', style: t(18, FontWeight.w700, cOnSurface)),
        actions: [
          if (_loadedWords != null && card < _loadedWords!.length)
            Center(
              child: Text(
                '${card + 1} / ${_loadedWords!.length}',
                style: t(12, FontWeight.w700, cOnSurfaceVariant),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<List<VocabularyWord>>(
        future: futureWords,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator(color: cPrimary));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Could not load vocabulary or nothing to study.', style: t(15, FontWeight.w600, cError)));
          }
          _loadedWords = snapshot.data!;
          final words = _loadedWords!;
          
          if (card >= words.length) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: cPrimary),
                  const SizedBox(height: 16),
                  Text('Session Complete!', style: t(24, FontWeight.w800, cOnSurface)),
                  const SizedBox(height: 8),
                  Text('You learned $known words and are still learning $learning words.', style: t(14, FontWeight.w500, cOnSurfaceVariant)),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Home'),
                  )
                ],
              ),
            );
          }
          
          final word = words[card];
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
                            child: SingleChildScrollView(
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
                                  if (word.hasExample) ...[
                                    const SizedBox(height: 18),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: cSurfaceLow,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: cSurfaceContainer),
                                      ),
                                      child: Column(
                                        children: [
                                          HighlightedSentence(
                                            sentence: word.exampleSentenceIdn,
                                            targetWord: word.indonesian,
                                            textAlign: TextAlign.center,
                                            defaultStyle: t(14, FontWeight.w500, cOnSurface, height: 1.4),
                                            highlightStyle: t(14, FontWeight.w800, cPrimary, height: 1.4),
                                          ),
                                          if (word.exampleSentenceEng.trim().isNotEmpty) ...[
                                            const SizedBox(height: 5),
                                            Text(
                                              word.exampleSentenceEng,
                                              textAlign: TextAlign.center,
                                              style: t(12, FontWeight.w500, cOnSurfaceVariant, height: 1.35),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 18),
                                  TextButton.icon(
                                    onPressed: word.hasExtras ? () => showWordExtrasSheet(context, word) : null,
                                    icon: const Icon(Icons.menu_book_outlined, size: 18),
                                    label: Text(
                                      word.hasExtras ? 'Usage & collocation' : 'No extra notes',
                                      style: t(13, FontWeight.w700, word.hasExtras ? cPrimary : cOnSurfaceVariant),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => next(word.wordId, false),
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
                              onPressed: () => next(word.wordId, true),
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
