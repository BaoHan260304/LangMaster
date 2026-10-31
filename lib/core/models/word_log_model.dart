class WordLogModel {
  final String word;
  final String meaning;
  int wrongTypingCount;
  int wrongPronounceCount;
  int correctStreak;
  DateTime lastWrongTime;

  WordLogModel({
    required this.word,
    required this.meaning,
    this.wrongTypingCount = 0,
    this.wrongPronounceCount = 0,
    this.correctStreak = 0,
    required this.lastWrongTime,
  });

  int get totalMistakes => wrongTypingCount + wrongPronounceCount;

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'meaning': meaning,
      'wrongTypingCount': wrongTypingCount,
      'wrongPronounceCount': wrongPronounceCount,
      'correctStreak': correctStreak,
      'lastWrongTime': lastWrongTime.toIso8601String(),
    };
  }

  factory WordLogModel.fromMap(Map<String, dynamic> map) {
    return WordLogModel(
      word: map['word'] as String,
      meaning: map['meaning'] as String,
      wrongTypingCount: map['wrongTypingCount'] as int? ?? 0,
      wrongPronounceCount: map['wrongPronounceCount'] as int? ?? 0,
      correctStreak: map['correctStreak'] as int? ?? 0,
      lastWrongTime:
          DateTime.tryParse(map['lastWrongTime'] as String? ?? '') ??
              DateTime.now(),
    );
  }
}

