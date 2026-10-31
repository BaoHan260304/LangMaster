import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/word_log_model.dart';
import 'recommendation_algo.dart';

/// Màn hình hiển thị TOP 10 từ vựng sai nhiều nhất (Member 3):
/// Xếp hạng theo Urgency Score S = (W_type * 1.5 + W_pronounce * 2.0) * D_recency - (C_streak * 1.2)
/// Cung cấp nút Ôn tập trực tiếp để xóa bỏ cảnh báo khi trả lời đúng
class TopMistakesScreen extends StatelessWidget {
  const TopMistakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Top 10 Từ Cần Ôn Luyện',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<MistakeAlgorithmProvider>(
        builder: (context, algoProvider, child) {
          final topMistakes = algoProvider.getTop10MistakeWords();

          if (topMistakes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_outline_rounded,
                          size: 64, color: Color(0xFF10B981)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rất tốt! Không có từ nào cần cảnh báo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy thử làm bài kiểm tra gõ từ hoặc phát âm trong Từ điển để hệ thống ghi nhận tiến độ học của bạn.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Banner giải thích thuật toán
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.indigo.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.insights_rounded,
                        color: Color(0xFF4F46E5), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Điểm Ưu Tiên (S) tự động tăng khi sai và giảm dần khi bạn luyện tập nhớ đúng.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.indigo.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Danh sách Top 10
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: topMistakes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final log = topMistakes[index];
                    final score = algoProvider.calculateUrgencyScore(log);
                    return _buildMistakeCard(context, index + 1, log, score);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMistakeCard(
      BuildContext context, int rank, WordLogModel log, double score) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank <= 3 ? Colors.red.shade200 : Colors.grey.shade200,
          width: rank <= 3 ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Huy hiệu thứ hạng
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: rank == 1
                      ? Colors.red.shade600
                      : (rank == 2
                          ? Colors.orange.shade700
                          : (rank == 3
                              ? Colors.amber.shade700
                              : Colors.grey.shade400)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Từ vựng & Nghĩa
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.word,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      log.meaning,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Điểm Urgency Score S
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Ưu tiên',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      score.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Thống kê chi tiết lỗi và nút ôn tập
          Row(
            children: [
              _buildStatChip(
                Icons.keyboard_alt_outlined,
                'Gõ sai: ${log.wrongTypingCount}',
                Colors.orange.shade800,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                Icons.mic_none_rounded,
                'Đọc sai: ${log.wrongPronounceCount}',
                Colors.red.shade700,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                Icons.bolt_rounded,
                'Chuỗi: ${log.correctStreak}',
                const Color(0xFF10B981),
              ),
              const Spacer(),

              // Nút ôn lại nhanh
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _showQuickPracticeDialog(context, log),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.replay_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Ôn ngay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showQuickPracticeDialog(BuildContext context, WordLogModel log) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.flash_on_rounded, color: Colors.amber),
              const SizedBox(width: 8),
              const Text('Ôn tập nhanh',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nghĩa tiếng Việt:',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                log.meaning,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Gõ từ tiếng Anh tương ứng...',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () {
                final input = textController.text.trim();
                final isCorrect =
                    input.toLowerCase() == log.word.toLowerCase();

                final algoProvider = Provider.of<MistakeAlgorithmProvider>(
                    context,
                    listen: false);
                algoProvider.recordAttempt(
                  word: log.word,
                  meaning: log.meaning,
                  isCorrect: isCorrect,
                  isPronunciationTest: false,
                );

                Navigator.pop(dialogCtx);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isCorrect
                          ? 'Chính xác! Chuỗi đúng tăng lên, điểm cảnh báo đã giảm.'
                          : 'Chưa chính xác! Đáp án đúng là "${log.word}"',
                    ),
                    backgroundColor: isCorrect
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Kiểm tra'),
            ),
          ],
        );
      },
    );
  }
}

