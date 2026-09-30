import 'package:flutter/material.dart';

import '../data/vocabulary_repository.dart';
import '../models/vocabulary_word.dart';
import '../theme.dart';
import 'word_detail_screen.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});
  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final controller = TextEditingController();
  late Future<List<VocabularyWord>> futureWords;
  late Future<int> futureCount;

  @override
  void initState() {
    super.initState();
    futureCount = VocabularyRepository.count();
    futureWords = VocabularyRepository.search('');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void search(String value) {
    setState(() {
      futureWords = VocabularyRepository.search(value);
    });
  }

  void openWord(VocabularyWord word) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WordDetailScreen(word: word)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: Row(
                  children: [
                    Text('Dictionary', style: t(25, FontWeight.w800, cOnSurface)),
                    const Spacer(),
                    FutureBuilder<int>(
                      future: futureCount,
                      builder: (_, s) => Text(
                        s.hasData ? '${s.data} words' : '',
                        style: t(12, FontWeight.w600, cOnSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                child: TextField(
                  controller: controller,
                  onChanged: search,
                  decoration: InputDecoration(
                    hintText: 'Search Indonesian words',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: cSurfaceContainer),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: cSurfaceContainer),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<VocabularyWord>>(
                  future: futureWords,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator(color: cPrimary));
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(child: Text('Could not load dictionary.', style: t(14, FontWeight.w600, cError)));
                    }
                    final filtered = snapshot.data!;
                    if (filtered.isEmpty) {
                      return Center(child: Text('No words found.', style: t(14, FontWeight.w600, cOnSurfaceVariant)));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 9),
                      itemBuilder: (context, i) {
                        final word = filtered[i];
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            onTap: () => openWord(word),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: cSurfaceContainer),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: cPrimary.withOpacity(.08),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: const Icon(Icons.menu_book_rounded, color: cPrimary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(word.indonesian, style: t(17, FontWeight.w700, cOnSurface)),
                                        const SizedBox(height: 3),
                                        Text(word.translation, style: t(13, FontWeight.w500, cOnSurfaceVariant)),
                                        const SizedBox(height: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: cSecondaryFixed,
                                            borderRadius: BorderRadius.circular(7),
                                          ),
                                          child: Text(word.pos, style: t(10, FontWeight.w700, cSecondary)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Word details',
                                    onPressed: () => openWord(word),
                                    icon: const Icon(Icons.chevron_right_rounded, color: cOnSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
