class UserProgress {
  final String userId;
  final int wordId;
  final int status; // 0 = new, 1 = learning, 2 = learned, 3 = mastered
  final int leitnerBox;
  final int correctCount;
  final int incorrectCount;
  final int lastReviewed; // Timestamp
  final int nextDue; // Timestamp
  final int isFavorite;

  UserProgress({
    required this.userId,
    required this.wordId,
    this.status = 0,
    this.leitnerBox = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.lastReviewed = 0,
    this.nextDue = 0,
    this.isFavorite = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'word_id': wordId,
      'status': status,
      'leitner_box': leitnerBox,
      'correct_count': correctCount,
      'incorrect_count': incorrectCount,
      'last_reviewed': lastReviewed,
      'next_due': nextDue,
      'is_favorite': isFavorite,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['user_id'] as String,
      wordId: map['word_id'] as int,
      status: map['status'] as int? ?? 0,
      leitnerBox: map['leitner_box'] as int? ?? 0,
      correctCount: map['correct_count'] as int? ?? 0,
      incorrectCount: map['incorrect_count'] as int? ?? 0,
      lastReviewed: map['last_reviewed'] as int? ?? 0,
      nextDue: map['next_due'] as int? ?? 0,
      isFavorite: map['is_favorite'] as int? ?? 0,
    );
  }

  UserProgress copyWith({
    int? status,
    int? leitnerBox,
    int? correctCount,
    int? incorrectCount,
    int? lastReviewed,
    int? nextDue,
    int? isFavorite,
  }) {
    return UserProgress(
      userId: userId,
      wordId: wordId,
      status: status ?? this.status,
      leitnerBox: leitnerBox ?? this.leitnerBox,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextDue: nextDue ?? this.nextDue,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
