import 'package:flutter/material.dart';
import 'duo_battle_screen.dart';

/// Màn hình Sảnh chờ Game Đối Kháng Tốc Độ (Member 4):
/// Cho phép chọn giữa 2 chế độ:
/// 1. 1v1 Split Screen (Hai người thi đấu trên cùng thiết bị)
/// 2. Luyện tập với Bot AI
class DuoGameLobbyScreen extends StatefulWidget {
  const DuoGameLobbyScreen({super.key});

  @override
  State<DuoGameLobbyScreen> createState() => _DuoGameLobbyScreenState();
}

class _DuoGameLobbyScreenState extends State<DuoGameLobbyScreen> {
  bool _vsBot = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Duo Strike Arena',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner giới thiệu game
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bolt_rounded, color: Colors.amber, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'ĐẤU TỐC ĐỘ 1V1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'So tài phản xạ từ vựng tiếng Anh trong thời gian thực. Ai nhanh tay và chuẩn xác hơn sẽ giành chiến thắng!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Chọn chế độ chơi
            const Text(
              'Chọn chế độ thi đấu',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            // Chế độ 1: 1v1 Split Screen
            _buildModeCard(
              title: '1v1 Cùng Thiết Bị (Split Screen)',
              description: 'Hai người cùng chơi trên 1 màn hình. Thích hợp demo trực tiếp với thầy cô và bạn bè!',
              icon: Icons.people_alt_rounded,
              isSelected: !_vsBot,
              onTap: () => setState(() => _vsBot = false),
            ),
            const SizedBox(height: 12),

            // Chế độ 2: Đấu với Bot AI
            _buildModeCard(
              title: 'Luyện tập với Bot AI',
              description: 'Luyện phản xạ một mình. Bot AI sẽ tự động trả lời với tốc độ ngẫu nhiên.',
              icon: Icons.smart_toy_rounded,
              isSelected: _vsBot,
              onTap: () => setState(() => _vsBot = true),
            ),
            const SizedBox(height: 24),

            // Bảng tóm tắt luật chơi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.rule_rounded, color: Color(0xFF4F46E5), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Luật thi đấu & Tính điểm',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildRuleRow('⏱️ Tốc độ:', 'Mỗi câu hỏi chỉ có 3.5 giây đếm ngược.'),
                  _buildRuleRow('🔥 Strike Mode:', 'Đạt chuỗi đúng ≥ 3 sẽ kích hoạt nhân điểm (10 x Strike).'),
                  _buildRuleRow('🔒 Hình phạt:', 'Bấm sai sẽ mất toàn bộ chuỗi Strike và bị khóa nút 1 giây.'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Nút Bắt đầu trận đấu
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DuoBattleScreen(vsBot: _vsBot),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Bắt Đầu Trận Đấu',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.indigo.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.grey.shade200,
          width: isSelected ? 1.6 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4F46E5)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected
                      ? const Color(0xFF4F46E5)
                      : Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRuleRow(String label, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              content,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

