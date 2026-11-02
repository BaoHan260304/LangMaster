import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/mock_data/initial_data.dart';

class DuoQuestion {
  final String word;
  final String correctAnswer;
  final List<String> options;

  DuoQuestion({
    required this.word,
    required this.correctAnswer,
    required this.options,
  });
}

/// Controller điều khiển logic trận đấu Duo Game (Member 4):
/// - Timer.periodic 100ms cho mỗi round 3.5s
/// - Hệ thống tính điểm: Tốc độ + Hệ số nhân Strike (10 * Strike)
/// - Phạt khóa tay 1 giây khi chọn sai
/// - Hỗ trợ cả 2 chế độ: 1v1 Trên cùng thiết bị hoặc Đấu với Bot AI
class DuoGameController extends ChangeNotifier {
  int p1Score = 0;
  int p1Strike = 0;
  bool p1Locked = false;

  int p2Score = 0;
  int p2Strike = 0;
  bool p2Locked = false;

  int currentQuestionIndex = 0;
  double timeLeft = 3.5;
  Timer? _roundTimer;
  Timer? _botTimer;
  bool isGameOver = false;
  bool isBotMode = false;

  late List<DuoQuestion> questions;

  DuoGameController() {
    _generateQuestionsFromMock();
  }

  void _generateQuestionsFromMock() {
    final list = <DuoQuestion>[];
    final allCards = InitialData.sampleFlashcards;

    for (var card in allCards) {
      final others = allCards
          .where((c) => c.word != card.word)
          .map((c) => c.meaning)
          .toList()
        ..shuffle();

      final options = [card.meaning, ...others.take(3)]..shuffle();

      list.add(DuoQuestion(
        word: card.word,
        correctAnswer: card.meaning,
        options: options,
      ));
    }

    list.shuffle();
    questions = list.take(8).toList(); // Mỗi trận đấu 8 câu hỏi
  }

  void startGame({bool vsBot = false}) {
    isBotMode = vsBot;
    p1Score = 0;
    p1Strike = 0;
    p1Locked = false;
    p2Score = 0;
    p2Strike = 0;
    p2Locked = false;
    currentQuestionIndex = 0;
    isGameOver = false;

    _generateQuestionsFromMock();
    _startRoundTimer();
    notifyListeners();
  }

  void _startRoundTimer() {
    _roundTimer?.cancel();
    _botTimer?.cancel();
    timeLeft = 3.5;

    _roundTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      timeLeft -= 0.1;
      if (timeLeft <= 0) {
        timeLeft = 0;
        // Hết giờ mà chưa ai trả lời -> Reset streak cả 2
        p1Strike = 0;
        p2Strike = 0;
        _nextQuestion();
      }
      notifyListeners();
    });

    // Nếu chơi với Bot AI, Bot tự động ra quyết định ngẫu nhiên
    if (isBotMode && !isGameOver) {
      final botThinkTime = 1.2 + Random().nextDouble() * 1.6; // 1.2s - 2.8s
      _botTimer = Timer(Duration(milliseconds: (botThinkTime * 1000).toInt()), () {
        if (!isGameOver && !p2Locked && timeLeft > 0.3) {
          final curQ = questions[currentQuestionIndex];
          // 70% Bot chọn đúng, 30% chọn sai
          final isBotCorrect = Random().nextDouble() < 0.70;
          final choice = isBotCorrect
              ? curQ.correctAnswer
              : curQ.options.firstWhere((opt) => opt != curQ.correctAnswer);

          submitAnswer(playerNumber: 2, selectedOption: choice);
        }
      });
    }
  }

  void submitAnswer({
    required int playerNumber,
    required String selectedOption,
  }) {
    if (isGameOver) return;
    if (playerNumber == 1 && p1Locked) return;
    if (playerNumber == 2 && p2Locked) return;
    if (currentQuestionIndex >= questions.length) return;

    final correctAns = questions[currentQuestionIndex].correctAnswer;
    final isCorrect = selectedOption == correctAns;

    if (isCorrect) {
      final speedBonus = (timeLeft * 5).toInt();
      if (playerNumber == 1) {
        p1Strike++;
        p2Strike = 0; // Phá vỡ chuỗi của đối thủ
        p1Score += (10 * p1Strike) + speedBonus;
      } else {
        p2Strike++;
        p1Strike = 0;
        p2Score += (10 * p2Strike) + speedBonus;
      }
      _nextQuestion();
    } else {
      // Bấm sai: reset strike về 0 và khóa bấm 1 giây
      if (playerNumber == 1) {
        p1Strike = 0;
        p1Locked = true;
        Timer(const Duration(seconds: 1), () {
          p1Locked = false;
          notifyListeners();
        });
      } else {
        p2Strike = 0;
        p2Locked = true;
        Timer(const Duration(seconds: 1), () {
          p2Locked = false;
          notifyListeners();
        });
      }
      notifyListeners();
    }
  }

  void _nextQuestion() {
    _botTimer?.cancel();
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      _startRoundTimer();
    } else {
      _roundTimer?.cancel();
      isGameOver = true;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    _botTimer?.cancel();
    super.dispose();
  }
}

