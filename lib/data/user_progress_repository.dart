import 'package:sqflite/sqflite.dart';

import '../models/user_progress.dart';
import '../models/vocabulary_word.dart';
import 'app_database.dart';

class UserProgressRepository {
  static const String currentUserId = 'local_user'; // Mock user id since auth is skipped

  static Future<List<VocabularyWord>> getStudySession(int limit) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Fetch due words
    final dueRows = await db.rawQuery('''
      SELECT v.* FROM vocabulary v
      JOIN user_progress p ON v.word_id = p.word_id
      WHERE p.user_id = ? AND p.next_due <= ?
      ORDER BY p.next_due ASC
      LIMIT ?
    ''', [currentUserId, now, limit]);

    final List<VocabularyWord> words = dueRows.map(VocabularyWord.fromMap).toList();

    // 2. If not enough due words, fetch new words
    if (words.length < limit) {
      final remaining = limit - words.length;
      final newRows = await db.rawQuery('''
        SELECT v.* FROM vocabulary v
        LEFT JOIN user_progress p ON v.word_id = p.word_id AND p.user_id = ?
        WHERE p.word_id IS NULL
        ORDER BY v.frequency_rank ASC
        LIMIT ?
      ''', [currentUserId, remaining]);
      
      words.addAll(newRows.map(VocabularyWord.fromMap).toList());
    }

    return words;
  }

  static Future<void> updateProgress(int wordId, bool isCorrect) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final rows = await db.query(
      'user_progress',
      where: 'user_id = ? AND word_id = ?',
      whereArgs: [currentUserId, wordId],
    );

    UserProgress progress;
    if (rows.isEmpty) {
      progress = UserProgress(userId: currentUserId, wordId: wordId);
    } else {
      progress = UserProgress.fromMap(rows.first);
    }

    int newBox = isCorrect ? progress.leitnerBox + 1 : 1;
    if (newBox > 5) newBox = 5;
    
    int newCorrect = isCorrect ? progress.correctCount + 1 : progress.correctCount;
    int newIncorrect = isCorrect ? progress.incorrectCount : progress.incorrectCount + 1;
    
    // Status: 0=new, 1=learning, 2=learned (box>=3), 3=mastered (box=5)
    int newStatus = 1;
    if (newBox >= 3) newStatus = 2;
    if (newBox == 5) newStatus = 3;

    // Next due based on box
    int daysToAdd = 1; // default for box 1 or incorrect
    if (isCorrect) {
      if (newBox == 1) daysToAdd = 1;
      else if (newBox == 2) daysToAdd = 2;
      else if (newBox == 3) daysToAdd = 4;
      else if (newBox == 4) daysToAdd = 8;
      else if (newBox == 5) daysToAdd = 16;
    }

    final nextDue = DateTime.now().add(Duration(days: daysToAdd)).millisecondsSinceEpoch;

    final updated = progress.copyWith(
      leitnerBox: newBox,
      status: newStatus,
      correctCount: newCorrect,
      incorrectCount: newIncorrect,
      lastReviewed: now,
      nextDue: nextDue,
    );

    await db.insert(
      'user_progress',
      updated.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
