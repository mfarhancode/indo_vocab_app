import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indovoca/theme.dart';
import 'package:indovoca/widgets/highlighted_sentence.dart';

void main() {
  testWidgets('HighlightedSentence highlights target word case-insensitively while preserving original casing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HighlightedSentence(
            sentence: 'Gubernur akan mengunjungi sekolah besok.',
            targetWord: 'gubernur',
          ),
        ),
      ),
    );

    // Find the RichText widget
    final richTextFinder = find.byType(RichText);
    expect(richTextFinder, findsOneWidget);

    final richText = tester.widget<RichText>(richTextFinder);
    final textSpan = richText.text as TextSpan;

    // Children: [TextSpan("Gubernur", bold, cPrimary), TextSpan(" akan mengunjungi sekolah besok.", normal, cOnSurface)]
    expect(textSpan.children, isNotNull);
    expect(textSpan.children!.length, 2);

    final firstSpan = textSpan.children![0] as TextSpan;
    expect(firstSpan.text, 'Gubernur'); // Preserves capital 'G'
    expect(firstSpan.style?.fontWeight, FontWeight.w800);
    expect(firstSpan.style?.color, cPrimary);

    final secondSpan = textSpan.children![1] as TextSpan;
    expect(secondSpan.text, ' akan mengunjungi sekolah besok.');
    expect(secondSpan.style?.fontWeight, FontWeight.w500);
    expect(secondSpan.style?.color, cOnSurface);
  });

  testWidgets('HighlightedSentence respects word boundaries (e.g. "di" vs "dingin")', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HighlightedSentence(
            sentence: 'Saya tinggal di rumah dingin.',
            targetWord: 'di',
          ),
        ),
      ),
    );

    final richText = tester.widget<RichText>(find.byType(RichText));
    final textSpan = richText.text as TextSpan;

    // "Saya tinggal " -> normal
    // "di" -> highlighted
    // " rumah dingin." -> normal ("dingin" must not have "di" highlighted)
    expect(textSpan.children!.length, 3);
    expect((textSpan.children![0] as TextSpan).text, 'Saya tinggal ');
    expect((textSpan.children![1] as TextSpan).text, 'di');
    expect((textSpan.children![1] as TextSpan).style?.color, cPrimary);
    expect((textSpan.children![2] as TextSpan).text, ' rumah dingin.');
  });

  testWidgets('HighlightedSentence highlights multiple occurrences in a sentence', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HighlightedSentence(
            sentence: 'Buku ini adalah buku baru.',
            targetWord: 'buku',
          ),
        ),
      ),
    );

    final richText = tester.widget<RichText>(find.byType(RichText));
    final textSpan = richText.text as TextSpan;

    // "Buku" (highlighted)
    // " ini adalah " (normal)
    // "buku" (highlighted)
    // " baru." (normal)
    expect(textSpan.children!.length, 4);
    expect((textSpan.children![0] as TextSpan).text, 'Buku');
    expect((textSpan.children![0] as TextSpan).style?.color, cPrimary);
    expect((textSpan.children![1] as TextSpan).text, ' ini adalah ');
    expect((textSpan.children![2] as TextSpan).text, 'buku');
    expect((textSpan.children![2] as TextSpan).style?.color, cPrimary);
    expect((textSpan.children![3] as TextSpan).text, ' baru.');
  });
}
