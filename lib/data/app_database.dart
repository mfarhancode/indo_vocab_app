import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/vocabulary_word.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<void> init() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    await database;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = kIsWeb ? 'indovoca.db' : p.join(await getDatabasesPath(), 'indovoca.db');
    final db = await openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE user_progress (
              user_id TEXT,
              word_id INTEGER,
              status INTEGER,
              leitner_box INTEGER,
              correct_count INTEGER,
              incorrect_count INTEGER,
              last_reviewed INTEGER,
              next_due INTEGER,
              is_favorite INTEGER,
              PRIMARY KEY (user_id, word_id)
            )
          ''');
          await db.execute('''
            CREATE TABLE user_summary (
              user_id TEXT PRIMARY KEY,
              total_words_seen INTEGER,
              total_words_learned INTEGER,
              total_words_mastered INTEGER,
              furthest_rank INTEGER,
              current_streak INTEGER,
              longest_streak INTEGER,
              last_study_date TEXT,
              updated_at INTEGER
            )
          ''');
        }
      },
    );
    await _importFromJsonIfEmpty(db);
    return db;
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE vocabulary (
        word_id INTEGER PRIMARY KEY,
        indonesian TEXT NOT NULL,
        translation TEXT NOT NULL,
        pos TEXT NOT NULL,
        frequency_rank INTEGER NOT NULL,
        usage_note TEXT NOT NULL,
        collocation_idn TEXT NOT NULL,
        collocation_eng TEXT NOT NULL,
        example_sentence_idn TEXT NOT NULL,
        example_sentence_eng TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE app_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_vocab_search ON vocabulary(indonesian, translation)');
    
    await db.execute('''
      CREATE TABLE user_progress (
        user_id TEXT,
        word_id INTEGER,
        status INTEGER,
        leitner_box INTEGER,
        correct_count INTEGER,
        incorrect_count INTEGER,
        last_reviewed INTEGER,
        next_due INTEGER,
        is_favorite INTEGER,
        PRIMARY KEY (user_id, word_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE user_summary (
        user_id TEXT PRIMARY KEY,
        total_words_seen INTEGER,
        total_words_learned INTEGER,
        total_words_mastered INTEGER,
        furthest_rank INTEGER,
        current_streak INTEGER,
        longest_streak INTEGER,
        last_study_date TEXT,
        updated_at INTEGER
      )
    ''');
  }

  Future<void> _importFromJsonIfEmpty(Database db) async {
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM vocabulary')) ?? 0;
    if (count > 0) return;

    final raw = await rootBundle.loadString('assets/vocab_cleaned_reindexed.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    final batch = db.batch();
    for (final item in decoded) {
      final word = VocabularyWord.fromJson(item as Map<String, dynamic>);
      batch.insert('vocabulary', word.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
    await db.insert(
      'app_meta',
      {'key': 'vocab_source', 'value': 'vocab_cleaned_reindexed.json'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<VocabularyWord>> allWords() async {
    final db = await database;
    final rows = await db.query('vocabulary', orderBy: 'frequency_rank ASC');
    return rows.map(VocabularyWord.fromMap).toList();
  }

  Future<int> wordCount() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM vocabulary')) ?? 0;
  }

  Future<List<VocabularyWord>> search(String query, {int limit = 200}) async {
    final db = await database;
    final q = query.trim();
    if (q.isEmpty) {
      final rows = await db.query('vocabulary', orderBy: 'frequency_rank ASC', limit: limit);
      return rows.map(VocabularyWord.fromMap).toList();
    }
    final like = '%$q%';
    final rows = await db.query(
      'vocabulary',
      where: 'indonesian LIKE ? OR translation LIKE ? OR pos LIKE ?',
      whereArgs: [like, like, like],
      orderBy: 'frequency_rank ASC',
      limit: limit,
    );
    return rows.map(VocabularyWord.fromMap).toList();
  }
}
