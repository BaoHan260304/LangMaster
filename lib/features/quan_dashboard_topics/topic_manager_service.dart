import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/mock_data/initial_data.dart';
import '../../core/models/topic_model.dart';

/// Provider Quản lý Tiến độ Học tập & Chủ đề Tùy chỉnh (Member 1 - Leader):
/// - Quản lý danh sách chủ đề (Mặc định + Chủ đề do người học tự tạo)
/// - Theo dõi Streak học tập hàng ngày (Daily Study Streak)
/// - Thiết lập mục tiêu học từ vựng mỗi ngày (Daily Goal)
/// - Thống kê số từ đã học, số từ đã thuộc (Mastered Words)
class TopicManagerProvider extends ChangeNotifier {
  List<TopicModel> _topics = [];
  int _studyStreakDays = 1;
  int _dailyGoal = 10;
  int _wordsStudiedToday = 0;
  int _masteredWordsCount = 0;
  String _lastStudyDate = '';

  List<TopicModel> get topics => _topics;
  int get studyStreakDays => _studyStreakDays;
  int get dailyGoal => _dailyGoal;
  int get wordsStudiedToday => _wordsStudiedToday;
  int get masteredWordsCount => _masteredWordsCount;
  double get dailyProgress =>
      _dailyGoal > 0 ? (_wordsStudiedToday / _dailyGoal).clamp(0.0, 1.0) : 0.0;

  List<TopicModel> get customTopics =>
      _topics.where((t) => t.isCustom).toList();

  TopicManagerProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    _topics = InitialData.getTopics();
    final prefs = await SharedPreferences.getInstance();

    // 1. Tải danh sách chủ đề tự tạo
    final customTopicsJson = prefs.getStringList('custom_topics') ?? [];
    for (var str in customTopicsJson) {
      try {
        final map = jsonDecode(str) as Map<String, dynamic>;
        _topics.add(TopicModel.fromMap(map));
      } catch (e) {
        debugPrint('Error parsing custom topic: $e');
      }
    }

    // 2. Tải thông số Streak và mục tiêu
    _dailyGoal = prefs.getInt('daily_goal') ?? 10;
    _masteredWordsCount = prefs.getInt('mastered_words_count') ?? 0;
    _studyStreakDays = prefs.getInt('study_streak_days') ?? 1;
    _lastStudyDate = prefs.getString('last_study_date') ?? '';

    final todayStr = _formatDate(DateTime.now());
    if (_lastStudyDate == todayStr) {
      _wordsStudiedToday = prefs.getInt('words_studied_today') ?? 0;
    } else {
      // Ngày mới -> kiểm tra duy trì streak
      if (_lastStudyDate.isNotEmpty) {
        final lastDate = DateTime.tryParse(_lastStudyDate);
        if (lastDate != null) {
          final difference = DateTime.now().difference(lastDate).inDays;
          if (difference > 1) {
            _studyStreakDays = 1; // Bị gián đoạn -> reset streak
            await prefs.setInt('study_streak_days', _studyStreakDays);
          }
        }
      }
      _wordsStudiedToday = 0;
      await prefs.setInt('words_studied_today', 0);
    }

    notifyListeners();
  }

  /// Ghi nhận khi người dùng vừa học hoặc ôn 1 từ
  Future<void> recordWordStudied({required bool isMastered}) async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _formatDate(DateTime.now());

    // Cập nhật streak nếu đây là lần học đầu tiên trong ngày mới
    if (_lastStudyDate != todayStr) {
      if (_lastStudyDate.isNotEmpty) {
        final lastDate = DateTime.tryParse(_lastStudyDate);
        if (lastDate != null) {
          final diff = DateTime.now().difference(lastDate).inDays;
          if (diff == 1) {
            _studyStreakDays += 1;
          } else if (diff > 1) {
            _studyStreakDays = 1;
          }
        }
      }
      _lastStudyDate = todayStr;
      await prefs.setString('last_study_date', _lastStudyDate);
      await prefs.setInt('study_streak_days', _studyStreakDays);
    }

    _wordsStudiedToday += 1;
    await prefs.setInt('words_studied_today', _wordsStudiedToday);

    if (isMastered) {
      _masteredWordsCount += 1;
      await prefs.setInt('mastered_words_count', _masteredWordsCount);
    }

    notifyListeners();
  }

  /// Thay đổi mục tiêu học tập hàng ngày (5, 10, 15, 20 từ)
  Future<void> setDailyGoal(int newGoal) async {
    _dailyGoal = newGoal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_goal', newGoal);
    notifyListeners();
  }

  /// Người học tự tạo chủ đề học tập cá nhân (Custom Topic)
  Future<void> addCustomTopic({
    required String title,
    required String description,
    required String iconName,
  }) async {
    final newTopic = TopicModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      flashcardCount: 0,
      iconName: iconName,
      isCustom: true,
    );

    _topics.add(newTopic);

    // Lưu vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final customList = _topics
        .where((t) => t.isCustom)
        .map((t) => jsonEncode(t.toMap()))
        .toList();
    await prefs.setStringList('custom_topics', customList);

    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

