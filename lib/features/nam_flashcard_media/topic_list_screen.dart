import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/topic_model.dart';
import '../../core/mock_data/initial_data.dart';
import '../quan_dashboard_topics/topic_manager_service.dart';
import 'flashcard_study_screen.dart';

/// Màn hình danh sách chủ đề học tập (Member 2):
/// - Hiển thị toàn bộ các chủ đề (Mặc định + Tự tạo)
/// - Miễn phí 100%, vào học trực tiếp không cần mua hay thanh toán
/// - Tích hợp đầy đủ dữ liệu đa phương tiện (Image, Audio, Video)
class TopicListScreen extends StatelessWidget {
  const TopicListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Chủ Đề Flashcard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<TopicManagerProvider>(
        builder: (context, topicProvider, child) {
          final topics = topicProvider.topics;

          if (topics.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: topics.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final topic = topics[index];
              final cardCount = InitialData.sampleFlashcards
                  .where((c) => c.topicId == topic.id)
                  .length;

              return _buildTopicCard(context, topic, cardCount);
            },
          );
        },
      ),
    );
  }

  Widget _buildTopicCard(
      BuildContext context, TopicModel topic, int cardCount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: topic.isCustom
              ? Colors.purple.shade100
              : Colors.indigo.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Vào học ngay lập tức - 100% Free
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FlashcardStudyScreen(topic: topic),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon đại diện
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (topic.isCustom
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFF4F46E5))
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(topic.iconName),
                    color: topic.isCustom
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF4F46E5),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                // Thông tin chủ đề
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              topic.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildBadge(topic),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topic.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.collections_bookmark_outlined,
                              size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            cardCount > 0
                                ? '$cardCount thẻ từ vựng'
                                : 'Bộ từ đang cập nhật',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Bắt đầu học →',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(TopicModel topic) {
    if (topic.isCustom) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.purple.shade100),
        ),
        child: const Text(
          'Tự tạo',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C3AED),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Miễn phí',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF059669),
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'business_center':
        return Icons.business_center_rounded;
      case 'flight_takeoff':
        return Icons.flight_takeoff_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      case 'sports_basketball':
        return Icons.sports_basketball_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }
}

