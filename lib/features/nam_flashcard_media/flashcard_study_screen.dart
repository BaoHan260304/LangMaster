import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/flashcard_model.dart';
import '../../core/models/topic_model.dart';
import '../../core/mock_data/initial_data.dart';
import '../quan_dashboard_topics/topic_manager_service.dart';
import '../muoi_dictionary_algo/recommendation_algo.dart';
import 'media_loader_widget.dart';

/// Màn hình học từ vựng Flashcard:
/// - Hiệu ứng lật thẻ 3D (Front: Từ + Phiên âm + Media; Back: Nghĩa + Ví dụ câu)
/// - Thanh tiến độ học (Card X / Y)
/// - Đánh giá nhanh: "Cần ôn lại" / "Đã nhớ" (tích hợp cập nhật thuật toán từ sai)
class FlashcardStudyScreen extends StatefulWidget {
  final TopicModel topic;

  const FlashcardStudyScreen({super.key, required this.topic});

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  late List<FlashcardModel> _cards;
  int _currentIndex = 0;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _cards = InitialData.sampleFlashcards
        .where((c) => c.topicId == widget.topic.id)
        .toList();

    _pageController = PageController();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  void _flipCard() {
    if (_flipController.isAnimating) return;
    if (_isFront) {
      _flipController.forward();
      setState(() => _isFront = false);
    } else {
      _flipController.reverse();
      setState(() => _isFront = true);
    }
  }

  void _goToNextCard() {
    if (_currentIndex < _cards.length - 1) {
      if (!_isFront) {
        _flipController.reset();
        _isFront = true;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousCard() {
    if (_currentIndex > 0) {
      if (!_isFront) {
        _flipController.reset();
        _isFront = true;
      }
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _markCardRemembered(bool remembered) {
    if (_cards.isEmpty) return;
    final card = _cards[_currentIndex];

    // Cập nhật thống kê học tập (Member 1 - TopicManagerProvider)
    final topicManager =
        Provider.of<TopicManagerProvider>(context, listen: false);
    topicManager.recordWordStudied(isMastered: remembered);

    // Cập nhật thuật toán ôn tập (MistakeAlgorithmProvider) nếu có
    final algoProvider =
        Provider.of<MistakeAlgorithmProvider>(context, listen: false);
    algoProvider.recordAttempt(
      word: card.word,
      meaning: card.meaning,
      isCorrect: remembered,
      isPronunciationTest: false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          remembered
              ? 'Tuyệt vời! Đã ghi nhận thuộc từ "${card.word}"'
              : 'Đã thêm "${card.word}" vào danh sách cần ôn tập',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: remembered ? const Color(0xFF10B981) : Colors.orange.shade700,
      ),
    );

    if (_currentIndex < _cards.length - 1) {
      _goToNextCard();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.topic.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: _cards.isEmpty
              ? const SizedBox.shrink()
              : LinearProgressIndicator(
                  value: (_currentIndex + 1) / _cards.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                  minHeight: 3.5,
                ),
        ),
      ),
      body: _cards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có flashcard nào trong chủ đề này',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Thanh chỉ báo số thẻ
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Thẻ ${_currentIndex + 1} / ${_cards.length}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.touch_app_outlined,
                                  size: 14, color: Color(0xFF4F46E5)),
                              SizedBox(width: 4),
                              Text(
                                'Chạm thẻ để lật',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Khung hiển thị Flashcard với hiệu ứng lật 3D
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _cards.length,
                      onPageChanged: (idx) {
                        setState(() {
                          _currentIndex = idx;
                          if (!_isFront) {
                            _flipController.reset();
                            _isFront = true;
                          }
                        });
                      },
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 6.0),
                          child: GestureDetector(
                            onTap: _flipCard,
                            child: AnimatedBuilder(
                              animation: _flipAnimation,
                              builder: (context, child) {
                                final angle = _flipAnimation.value * math.pi;
                                final isUnder = _flipAnimation.value > 0.5;

                                return Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(angle),
                                  alignment: Alignment.center,
                                  child: isUnder
                                      ? Transform(
                                          transform: Matrix4.identity()
                                            ..rotateY(math.pi),
                                          alignment: Alignment.center,
                                          child: _buildCardBack(card),
                                        )
                                      : _buildCardFront(card),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Thanh nút điều khiển & đánh giá
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Nút "Cần ôn lại"
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _markCardRemembered(false),
                                icon: const Icon(Icons.refresh_rounded,
                                    color: Color(0xFFEF4444), size: 18),
                                label: const Text(
                                  'Cần ôn lại',
                                  style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  side: BorderSide(
                                      color: Colors.red.shade200, width: 1.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.red.shade50.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Nút "Đã nhớ"
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _markCardRemembered(true),
                                icon: const Icon(Icons.check_circle_outline,
                                    size: 18),
                                label: const Text(
                                  'Đã thuộc',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Nút Previous / Next nhỏ gọn
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: _currentIndex > 0
                                  ? _goToPreviousCard
                                  : null,
                              icon: const Icon(Icons.arrow_back_ios_rounded,
                                  size: 14),
                              label: const Text('Thẻ trước',
                                  style: TextStyle(fontSize: 12)),
                            ),
                            TextButton.icon(
                              onPressed: _currentIndex < _cards.length - 1
                                  ? _goToNextCard
                                  : null,
                              iconAlignment: IconAlignment.end,
                              icon: const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 14),
                              label: const Text('Thẻ kế tiếp',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Mặt trước Flashcard: Từ vựng + Phiên âm + Khung đa phương tiện
  Widget _buildCardFront(FlashcardModel card) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo.shade100, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Từ vựng
            Text(
              card.word,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Phiên âm IPA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                card.phonetic,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4F46E5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Đa phương tiện minh họa (Image, Audio, Video)
            MultiMediaCardContent(
              imageUrl: card.imageUrl,
              audioUrl: card.audioUrl,
              videoUrl: card.videoUrl,
            ),
          ],
        ),
      ),
    );
  }

  /// Mặt sau Flashcard: Nghĩa tiếng Việt + Ví dụ câu
  Widget _buildCardBack(FlashcardModel card) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'NGHĨA TIẾNG VIỆT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F766E),
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            card.meaning,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F766E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 16),
          const Text(
            'Từ gốc tiếng Anh:',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            card.word,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.phonetic,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hãy liên tưởng đến bối cảnh thực tế trong video/hình ảnh để nhớ lâu hơn!',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

