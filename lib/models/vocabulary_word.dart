class VocabularyWord {
  const VocabularyWord({
    required this.wordId,
    required this.indonesian,
    required this.translation,
    required this.pos,
    required this.usageNote,
    required this.collocationIdn,
    required this.collocationEng,
    required this.exampleSentenceIdn,
    required this.exampleSentenceEng,
    required this.frequencyRank,
  });

  final int wordId;
  final String indonesian;
  final String translation;
  final String pos;
  final String usageNote;
  final String collocationIdn;
  final String collocationEng;
  final String exampleSentenceIdn;
  final String exampleSentenceEng;
  final int frequencyRank;

  bool get hasUsageNote => usageNote.trim().isNotEmpty;
  bool get hasCollocation => collocationIdn.trim().isNotEmpty || collocationEng.trim().isNotEmpty;
  bool get hasExample => exampleSentenceIdn.trim().isNotEmpty || exampleSentenceEng.trim().isNotEmpty;
  bool get hasExtras => hasUsageNote || hasCollocation || hasExample;

  factory VocabularyWord.fromJson(Map<String, dynamic> j) => VocabularyWord(
        wordId: j['wordId'] as int,
        indonesian: (j['indonesian'] ?? '') as String,
        translation: (j['translation'] ?? '') as String,
        pos: (j['pos'] ?? '') as String,
        usageNote: (j['usageNote'] ?? '') as String,
        collocationIdn: (j['collocationIdn'] ?? '') as String,
        collocationEng: (j['collocationEng'] ?? '') as String,
        exampleSentenceIdn: (j['exampleSentenceIdn'] ?? '') as String,
        exampleSentenceEng: (j['exampleSentenceEng'] ?? '') as String,
        frequencyRank: j['frequencyRank'] as int,
      );

  factory VocabularyWord.fromMap(Map<String, dynamic> m) => VocabularyWord(
        wordId: m['word_id'] as int,
        indonesian: (m['indonesian'] ?? '') as String,
        translation: (m['translation'] ?? '') as String,
        pos: (m['pos'] ?? '') as String,
        usageNote: (m['usage_note'] ?? '') as String,
        collocationIdn: (m['collocation_idn'] ?? '') as String,
        collocationEng: (m['collocation_eng'] ?? '') as String,
        exampleSentenceIdn: (m['example_sentence_idn'] ?? '') as String,
        exampleSentenceEng: (m['example_sentence_eng'] ?? '') as String,
        frequencyRank: m['frequency_rank'] as int,
      );

  Map<String, dynamic> toMap() => {
        'word_id': wordId,
        'indonesian': indonesian,
        'translation': translation,
        'pos': pos,
        'frequency_rank': frequencyRank,
        'usage_note': usageNote,
        'collocation_idn': collocationIdn,
        'collocation_eng': collocationEng,
        'example_sentence_idn': exampleSentenceIdn,
        'example_sentence_eng': exampleSentenceEng,
      };
}
