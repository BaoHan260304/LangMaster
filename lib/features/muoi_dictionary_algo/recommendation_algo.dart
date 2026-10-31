import 'package:flutter/material.dart';
import '../../core/models/word_log_model.dart';
import '../../core/database/local_db_helper.dart';

/// Provider quản lý Thuật toán Gợi ý và Ưu tiên Ôn tập Từ Sai (Member 3):
/// Công thức Urgency Score S:
/// S = (W_type * 1.5 + W_pronounce * 2.0) * D_recency - (C_streak * 1.2)
/// Trong đó:
/// - W_type: Số lần gõ sai từ
/// - W_pronounce: Số lần phát âm sai (trọng số 2.0 vì khó sửa hơn)
/// - D_recency: Hệ số thời gian (1.5 nếu sai trong 24h, 1.0 nếu lâu hơn)
/// - C_streak: Chuỗi nhớ đúng liên tiếp để giảm độ ưu tiên cảnh báo
class MistakeAlgorithmProvider extends ChangeNotifier {
  final Map<String, WordLogModel> _wordLogs = {};
  int _practiceInteractionCounter = 0;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  int get practiceInteractionCounter => _practiceInteractionCounter;

  MistakeAlgorithmProvider() {
    _loadFromDatabase();
  }

  /// Tải dữ liệu lịch sử từ SQLite khi khởi động
  Future<void> _loadFromDatabase() async {
    try {
      final logs = await LocalDbHelper.instance.getAllWordLogs();
      for (var log in logs) {
        _wordLogs[log.word.toLowerCase().trim()] = log;
      }
    } catch (e) {
      debugPrint('Error loading word logs from SQLite: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ghi nhận kết quả thực hành (Gõ phím hoặc Đọc phát âm)
  Future<void> recordAttempt({
    required String word,
    required String meaning,
    required bool isCorrect,
    required bool isPronunciationTest,
  }) async {
    final key = word.toLowerCase().trim();
    final existing = _wordLogs[key] ??
        WordLogModel(
          word: word,
          meaning: meaning,
          lastWrongTime: DateTime.now(),
        );

    if (isCorrect) {
      existing.correctStreak += 1;
    } else {
      existing.correctStreak = 0; // Reset streak khi sai
      existing.lastWrongTime = DateTime.now();
      if (isPronunciationTest) {
        existing.wrongPronounceCount += 1;
      } else {
        existing.wrongTypingCount += 1;
      }
    }

    _wordLogs[key] = existing;
    _practiceInteractionCounter++;

    // Lưu vào SQLite
    try {
      await LocalDbHelper.instance.insertOrUpdateWordLog(existing);
    } catch (e) {
      debugPrint('Error saving to SQLite: $e');
    }

    notifyListeners();
  }

  /// Tính điểm ưu tiên ôn tập (Urgency Score - S)
  double calculateUrgencyScore(WordLogModel log) {
    if (log.totalMistakes == 0) return 0.0;

    final hoursSinceLastMistake =
        DateTime.now().difference(log.lastWrongTime).inHours;
    final double recencyMultiplier = hoursSinceLastMistake <= 24 ? 1.5 : 1.0;

    final double baseErrorScore =
        (log.wrongTypingCount * 1.5) + (log.wrongPronounceCount * 2.0);
    final double recoveryDeduction = log.correctStreak * 1.2;

    final double finalScore =
        (baseErrorScore * recencyMultiplier) - recoveryDeduction;
    return finalScore < 0 ? 0.1 : finalScore;
  }

  /// Lấy danh sách TOP 10 từ sai nhiều nhất theo thuật toán
  List<WordLogModel> getTop10MistakeWords() {
    final allMistakes =
        _wordLogs.values.where((log) => log.totalMistakes > 0).toList();

    allMistakes.sort(
        (a, b) => calculateUrgencyScore(b).compareTo(calculateUrgencyScore(a)));

    return allMistakes.take(10).toList();
  }

  /// Gợi ý từ ôn tập định kỳ:
  /// Cứ sau mỗi 5 lần tương tác, nếu có từ sai thì gợi ý từ có Urgency Score cao nhất
  WordLogModel? getScheduledReminderWord() {
    if (_practiceInteractionCounter > 0 &&
        _practiceInteractionCounter % 5 == 0) {
      final topList = getTop10MistakeWords();
      if (topList.isNotEmpty) {
        return topList.first;
      }
    }
    return null;
  }

  /// Đặt lại bộ đếm sau khi người dùng đã xem popup nhắc lại
  void dismissReminder() {
    _practiceInteractionCounter = 0;
    notifyListeners();
  }
}

