import 'package:flutter/material.dart';

import 'highlighted_sentence.dart';
import '../models/vocabulary_word.dart';
import '../theme.dart';

class WordDetailsView extends StatelessWidget {
  const WordDetailsView({
    super.key,
    required this.word,
    this.showHeadline = true,
  });

  final VocabularyWord word;
  final bool showHeadline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeadline) ...[
          Text(word.indonesian, style: t(28, FontWeight.w800, cOnSurface)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(word.pos, cSecondaryFixed, cSecondary),
              _Chip('Frequency #${word.frequencyRank}', cSurfaceContainer, cSecondary),
            ],
          ),
          const SizedBox(height: 16),
          Text(word.translation, style: t(17, FontWeight.w600, cOnSurfaceVariant, height: 1.4)),
          const SizedBox(height: 22),
        ],
        if (word.hasUsageNote)
          _Block(label: 'Usage', body: word.usageNote),
        if (word.hasCollocation)
          _Block(
            label: 'Collocation',
            body: word.collocationIdn,
            caption: word.collocationEng,
            targetWord: word.indonesian,
          ),
        if (word.hasExample)
          _Block(
            label: 'Example',
            body: word.exampleSentenceIdn,
            caption: word.exampleSentenceEng,
            targetWord: word.indonesian,
          ),
        if (!word.hasExtras)
          Text(
            'No extra usage notes, collocations, or examples for this word.',
            style: t(13, FontWeight.w500, cOnSurfaceVariant, height: 1.4),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.background, this.color);
  final String label;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: t(11, FontWeight.w700, color)),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.label,
    required this.body,
    this.caption,
    this.targetWord,
  });

  final String label;
  final String body;
  final String? caption;
  final String? targetWord;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: t(11, FontWeight.w800, cPrimary)),
          const SizedBox(height: 6),
          if (body.trim().isNotEmpty)
            targetWord != null
                ? HighlightedSentence(
                    sentence: body,
                    targetWord: targetWord!,
                    defaultStyle: t(15, FontWeight.w500, cOnSurface, height: 1.45),
                    highlightStyle: t(15, FontWeight.w800, cPrimary, height: 1.45),
                  )
                : Text(body, style: t(15, FontWeight.w600, cOnSurface, height: 1.45)),
          if (caption != null && caption!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(caption!, style: t(13, FontWeight.w500, cOnSurfaceVariant, height: 1.4)),
          ],
        ],
      ),
    );
  }
}

Future<void> showWordExtrasSheet(BuildContext context, VocabularyWord word) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: cSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(22, 12, 22, 24 + MediaQuery.paddingOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cOutlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('More about ${word.indonesian}', style: t(18, FontWeight.w800, cOnSurface)),
              ),
              const SizedBox(height: 16),
              WordDetailsView(word: word, showHeadline: false),
            ],
          ),
        ),
      );
    },
  );
}
