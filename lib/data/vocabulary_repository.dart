import '../models/vocabulary_word.dart';
import 'app_database.dart';

class VocabularyRepository {
  static Future<List<VocabularyWord>> load() => AppDatabase.instance.allWords();

  static Future<int> count() => AppDatabase.instance.wordCount();

  static Future<List<VocabularyWord>> search(String query) => AppDatabase.instance.search(query);
}
