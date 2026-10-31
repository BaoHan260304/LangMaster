import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../muoi_dictionary_algo/recommendation_algo.dart';
import 'topic_manager_service.dart';
import 'add_custom_topic_dialog.dart';

/// Màn hình Dashboard Tổng quan & Phân tích Học tập (Member 1 - Leader):
/// - Thống kê chuỗi ngày học tập (Daily Streak 🔥)
/// - Quản lý Mục tiêu học từ vựng mỗi ngày (Daily Goal)
/// - Bảng số liệu: Tổng từ, Đã thuộc, Cần ôn luyện
/// - Quản lý các bộ từ vựng cá nhân tự tạo (Custom Topics)
class LearningDashboardScreen extends StatelessWidget {
  const LearningDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Tổng Quan Tiến Độ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer2<TopicManagerProvider, MistakeAlgorithmProvider>(
        builder: (context, topicProvider, algoProvider, child) {
          final customTopics = topicProvider.customTopics;
          final topMistakesCount = algoProvider.getTop10MistakeWords().length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. BANNER CHUỖI HỌC TẬP (STREAK)
                _buildStreakCard(topicProvider),
                const SizedBox(height: 14),

                // 2. MỤC TIÊU HỌC HÀNG NGÀY (DAILY GOAL)
                _buildDailyGoalCard(context, topicProvider),
                const SizedBox(height: 14),

                // 3. LƯỚI 4 CHỈ SỐ THỐNG KÊ TỔNG THỂ
                _buildMetricsGrid(topicProvider, topMistakesCount),
                const SizedBox(height: 20),

                // 4. DANH SÁCH BỘ TỪ TỰ TẠO (CUSTOM TOPICS)
                _buildCustomTopicsSection(context, customTopics),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Thẻ hiển thị Chuỗi ngày học (Daily Streak)
  Widget _buildStreakCard(TopicManagerProvider provider) {
    final streak = provider.studyStreakDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFFFBBF24),
              size: 36,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak Ngày Học Liên Tục!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  streak > 1
                      ? 'Phong độ rất tốt! Hãy tiếp tục duy trì thói quen học tập hôm nay.'
                      : 'Bắt đầu ngày học đầu tiên để kích hoạt chuỗi Streak rực rỡ.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Thẻ Mục tiêu học tập hôm nay
  Widget _buildDailyGoalCard(
      BuildContext context, TopicManagerProvider provider) {
    final studied = provider.wordsStudiedToday;
    final goal = provider.dailyGoal;
    final progress = provider.dailyProgress;
    final isDone = studied >= goal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isDone
                        ? Icons.check_circle_rounded
                        : Icons.track_changes_rounded,
                    color: isDone
                        ? const Color(0xFF10B981)
                        : const Color(0xFF4F46E5),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Mục tiêu hôm nay',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDone ? Colors.green.shade50 : Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$studied / $goal từ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDone
                        ? const Color(0xFF10B981)
                        : const Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Thanh tiến trình
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? const Color(0xFF10B981) : const Color(0xFF4F46E5),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),

          // Chọn mục tiêu nhanh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chọn chỉ tiêu:',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Row(
                children: [5, 10, 15, 20].map((val) {
                  final isSelected = goal == val;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => provider.setDailyGoal(val),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4F46E5)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$val',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Lưới 4 chỉ số thống kê
  Widget _buildMetricsGrid(
      TopicManagerProvider topicProvider, int mistakeCount) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricItem(
          title: 'Tổng chủ đề',
          value: '${topicProvider.topics.length}',
          subtitle: '${topicProvider.customTopics.length} bộ tự tạo',
          icon: Icons.folder_special_outlined,
          color: const Color(0xFF4F46E5),
          bgColor: Colors.indigo.shade50,
        ),
        _buildMetricItem(
          title: 'Từ đã thuộc',
          value: '${topicProvider.masteredWordsCount}',
          subtitle: 'Ghi nhớ vững chắc',
          icon: Icons.verified_rounded,
          color: const Color(0xFF10B981),
          bgColor: Colors.green.shade50,
        ),
        _buildMetricItem(
          title: 'Từ cần ôn luyện',
          value: '$mistakeCount',
          subtitle: 'Trong danh sách sai',
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFEF4444),
          bgColor: Colors.red.shade50,
        ),
        _buildMetricItem(
          title: 'Đã học hôm nay',
          value: '${topicProvider.wordsStudiedToday}',
          subtitle: 'Lượt tương tác',
          icon: Icons.menu_book_rounded,
          color: const Color(0xFFF59E0B),
          bgColor: Colors.amber.shade50,
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Phần danh sách Chủ đề tự tạo (Custom Topics)
  Widget _buildCustomTopicsSection(
      BuildContext context, List<dynamic> customTopics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bookmark_add_outlined,
                      color: Color(0xFF4F46E5), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Bộ từ vựng cá nhân',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle,
                    color: Color(0xFF4F46E5), size: 26),
                tooltip: 'Thêm chủ đề mới',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const AddCustomTopicDialog(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (customTopics.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.note_add_outlined,
                      size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  const Text(
                    'Chưa có bộ từ vựng cá nhân nào',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tạo bộ từ riêng của bạn để dễ dàng theo dõi và học tập chuyên biệt.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const AddCustomTopicDialog(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tạo bộ từ ngay'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: customTopics.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final topic = customTopics[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.indigo.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.school,
                            size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              topic.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Tự tạo',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

