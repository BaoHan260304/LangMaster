import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';

/// Màn hình thi đấu tốc độ Duo Strike (Member 4):
/// - Chế độ 1v1 Split-screen: Nửa trên của Player 2 được XOAY NGƯỢC 180 ĐỘ (RotatedBox quarterTurns: 2)
///   giúp 2 người ngồi đối diện nhau qua mặt bàn cùng nhìn xuôi chiều, bấm đối kháng tự nhiên!
/// - Chế độ Đấu Bot: Giữ chiều xuôi bình thường để 1 người dễ quan sát Bot.
/// - Đồng hồ đếm ngược 3.5s kịch tính, thưởng chuỗi Strike (🔥 x3 = 10 x Strike), phạt khóa 1s khi chọn sai.
class DuoBattleScreen extends StatefulWidget {
  final bool vsBot;

  const DuoBattleScreen({super.key, required this.vsBot});

  @override
  State<DuoBattleScreen> createState() => _DuoBattleScreenState();
}

class _DuoBattleScreenState extends State<DuoBattleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<DuoGameController>(context, listen: false);
      controller.startGame(vsBot: widget.vsBot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark arena gaming style
      body: Consumer<DuoGameController>(
        builder: (context, controller, child) {
          if (controller.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.isGameOver) {
            return _buildGameOverScreen(context, controller);
          }

          final currentQ = controller.questions[controller.currentQuestionIndex];
          final progress = (controller.timeLeft / 3.5).clamp(0.0, 1.0);

          return SafeArea(
            child: Column(
              children: [
                // 1. NỬA TRÊN: PLAYER 2 HOẶC BOT AI
                // Nếu là 1v1 đối kháng trên cùng thiết bị -> XOAY 180 ĐỘ (quarterTurns: 2)
                Expanded(
                  flex: 5,
                  child: widget.vsBot
                      ? _buildPlayer2Content(controller, currentQ, isRotated: false)
                      : RotatedBox(
                          quarterTurns: 2,
                          child: _buildPlayer2Content(controller, currentQ, isRotated: true),
                        ),
                ),

                // 2. THANH PHÂN CÁCH TRUNG TÂM: ĐỒNG HỒ & THÔNG SỐ VÒNG ĐẤU
                _buildCenterDivider(controller, progress),

                // 3. NỬA DƯỚI: PLAYER 1 (NGƯỜI DÙNG CHÍNH - CHIỀU XUÔI)
                Expanded(
                  flex: 5,
                  child: _buildPlayer1Content(controller, currentQ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Thanh phân cách ở chính giữa màn hình (Chia đôi 2 sân đấu)
  Widget _buildCenterDivider(DuoGameController controller, double progress) {
    Color timerColor = const Color(0xFF10B981);
    if (progress < 0.3) {
      timerColor = const Color(0xFFEF4444);
    } else if (progress < 0.6) {
      timerColor = Colors.amber;
    }

    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nút thoát nhanh về sảnh
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Icon(Icons.close_rounded,
                          size: 16, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        'Rời trận',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ),
              // Thông tin vòng đấu
              Text(
                'Câu ${controller.currentQuestionIndex + 1} / ${controller.questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              // Đồng hồ số
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 14, color: timerColor),
                  const SizedBox(width: 4),
                  Text(
                    '${controller.timeLeft.toStringAsFixed(1)}s',
                    style: TextStyle(
                      color: timerColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Thanh tiến trình đếm ngược 3.5s
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  /// Giao diện Player 2 (Nửa trên)
  Widget _buildPlayer2Content(
    DuoGameController controller,
    DuoQuestion currentQ, {
    required bool isRotated,
  }) {
    final isBot = controller.isBotMode;
    final isLocked = controller.p2Locked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: const Color(0xFF0B132B),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Player 2: Thông tin, Điểm số, Strike Flame
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isBot
                          ? Colors.purple.shade900
                          : const Color(0xFF0284C7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isBot ? Icons.smart_toy_rounded : Icons.person_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBot ? 'Bot AI Tốc Độ' : 'Đối Thủ (Player 2)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (controller.p2Strike >= 3)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🔥 Strike x${controller.p2Strike}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    '${controller.p2Score} pts',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Từ vựng hiển thị cho Player 2
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              currentQ.word,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),

          // Trạng thái nếu bị khóa phạt 1s
          if (isLocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_clock, color: Colors.redAccent, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Bị phạt khóa 1s vì chọn sai!',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else if (isBot)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bot đang phân tích đáp án...',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            // 4 Nút đáp án cho Player 2 (Nếu là 1v1 người với người)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: currentQ.options.map((option) {
                return ElevatedButton(
                  onPressed: isLocked
                      ? null
                      : () {
                          controller.submitAnswer(
                            playerNumber: 2,
                            selectedOption: option,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.white12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: Text(
                    option,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Giao diện Player 1 (Nửa dưới - Chiều xuôi)
  Widget _buildPlayer1Content(
      DuoGameController controller, DuoQuestion currentQ) {
    final isLocked = controller.p1Locked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: const Color(0xFF0F172A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Từ vựng hiển thị cho Player 1
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              currentQ.word,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),

          // Trạng thái nếu bị khóa phạt 1s
          if (isLocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_clock, color: Colors.redAccent, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Bị phạt khóa 1s vì chọn sai!',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // 4 Nút đáp án cho Player 1
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: currentQ.options.map((option) {
              return ElevatedButton(
                onPressed: isLocked
                    ? null
                    : () {
                        controller.submitAnswer(
                          playerNumber: 1,
                          selectedOption: option,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white38,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),

          // Header Player 1 (Ở cạnh dưới màn hình)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Bạn (Player 1)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (controller.p1Strike >= 3)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🔥 Strike x${controller.p1Strike}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    '${controller.p1Score} pts',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Màn hình kết thúc trận đấu và vinh danh người chiến thắng
  Widget _buildGameOverScreen(
      BuildContext context, DuoGameController controller) {
    final p1Wins = controller.p1Score > controller.p2Score;
    final isTie = controller.p1Score == controller.p2Score;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isTie
                    ? Icons.handshake_outlined
                    : (p1Wins
                        ? Icons.emoji_events_rounded
                        : Icons.sentiment_dissatisfied_rounded),
                size: 68,
                color: isTie
                    ? Colors.amber
                    : (p1Wins ? Colors.amber : Colors.redAccent),
              ),
              const SizedBox(height: 12),
              Text(
                isTie
                    ? 'HÒA NHAU!'
                    : (p1Wins ? 'CHIẾN THẮNG!' : 'BẠN ĐÃ THUA!'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Bạn',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.p1Score}',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Text('VS',
                      style: TextStyle(
                          color: Colors.white30,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Column(
                    children: [
                      Text(
                        controller.isBotMode ? 'Bot AI' : 'Đối thủ',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.p2Score}',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Về sảnh'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.startGame(vsBot: controller.isBotMode);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Chơi lại'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

