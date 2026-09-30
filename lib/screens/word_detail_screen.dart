import 'package:flutter/material.dart';

import '../models/vocabulary_word.dart';
import '../theme.dart';
import '../widgets/word_details.dart';

class WordDetailScreen extends StatelessWidget {
  const WordDetailScreen({super.key, required this.word});
  final VocabularyWord word;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(word.indonesian, style: t(18, FontWeight.w700, cOnSurface)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: cSurfaceContainer),
                  ),
                  child: WordDetailsView(word: word),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
