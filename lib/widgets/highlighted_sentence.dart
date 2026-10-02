import 'package:flutter/material.dart';

import '../theme.dart';

/// A widget that renders a sentence with dynamic highlighting for a target word.
///
/// Features:
/// - Uses [RichText] and [TextSpan] to parse and render text fragments.
/// - Case-insensitive matching that preserves original sentence capitalization in UI.
/// - Prioritizes whole-word boundary matching with fallback to substring matching.
/// - Distinct styling: target word is bold in the primary theme color,
///   while the rest of the sentence remains standard un-bolded font.
class HighlightedSentence extends StatelessWidget {
  const HighlightedSentence({
    super.key,
    required this.sentence,
    required this.targetWord,
    this.defaultStyle,
    this.highlightStyle,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  final String sentence;
  final String targetWord;
  final TextStyle? defaultStyle;
  final TextStyle? highlightStyle;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    if (sentence.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveDefaultStyle =
        defaultStyle ?? t(15, FontWeight.w500, cOnSurface, height: 1.45);
    final effectiveHighlightStyle =
        highlightStyle ?? t(15, FontWeight.w800, cPrimary, height: 1.45);

    final cleanTarget = targetWord.trim();
    if (cleanTarget.isEmpty) {
      return RichText(
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        text: TextSpan(
          text: sentence,
          style: effectiveDefaultStyle,
        ),
      );
    }

    final escapedTarget = RegExp.escape(cleanTarget);

    // Try whole-word boundary first so short words don't match inside unrelated words.
    // Fall back to substring matching if no boundary match is found (e.g. affixed forms).
    RegExp regex = RegExp(r'\b' + escapedTarget + r'\b', caseSensitive: false);
    Iterable<Match> matches = regex.allMatches(sentence);

    if (matches.isEmpty) {
      regex = RegExp(escapedTarget, caseSensitive: false);
      matches = regex.allMatches(sentence);
    }

    if (matches.isEmpty) {
      return RichText(
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        text: TextSpan(
          text: sentence,
          style: effectiveDefaultStyle,
        ),
      );
    }

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: sentence.substring(lastEnd, match.start),
            style: effectiveDefaultStyle,
          ),
        );
      }

      // Preserve the exact casing as it appeared in the sentence
      spans.add(
        TextSpan(
          text: sentence.substring(match.start, match.end),
          style: effectiveHighlightStyle,
        ),
      );
      lastEnd = match.end;
    }

    if (lastEnd < sentence.length) {
      spans.add(
        TextSpan(
          text: sentence.substring(lastEnd),
          style: effectiveDefaultStyle,
        ),
      );
    }

    return RichText(
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(
        style: effectiveDefaultStyle,
        children: spans,
      ),
    );
  }
}
