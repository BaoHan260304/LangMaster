import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'topic_manager_service.dart';

/// Hộp thoại tạo chủ đề học tập cá nhân (Member 1 - Leader):
/// Cho phép người dùng nhập tên chủ đề, mô tả và chọn icon biểu trưng
class AddCustomTopicDialog extends StatefulWidget {
  const AddCustomTopicDialog({super.key});

  @override
  State<AddCustomTopicDialog> createState() => _AddCustomTopicDialogState();
}

class _AddCustomTopicDialogState extends State<AddCustomTopicDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedIcon = 'school';

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'school', 'icon': Icons.school_rounded, 'label': 'Học thuật'},
    {'name': 'chat', 'icon': Icons.chat_bubble_outline_rounded, 'label': 'Giao tiếp'},
    {'name': 'business_center', 'icon': Icons.business_center_rounded, 'label': 'Công việc'},
    {'name': 'flight_takeoff', 'icon': Icons.flight_takeoff_rounded, 'label': 'Du lịch'},
    {'name': 'code', 'icon': Icons.code_rounded, 'label': 'Công nghệ'},
    {'name': 'restaurant', 'icon': Icons.restaurant_rounded, 'label': 'Ẩm thực'},
    {'name': 'favorite', 'icon': Icons.favorite_rounded, 'label': 'Đời sống'},
    {'name': 'sports_basketball', 'icon': Icons.sports_basketball_rounded, 'label': 'Thể thao'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final desc = _descController.text.trim();

      final provider =
          Provider.of<TopicManagerProvider>(context, listen: false);
      provider.addCustomTopic(
        title: title,
        description: desc,
        iconName: _selectedIcon,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tạo thành công chủ đề "$title"!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Row(
        children: [
          Icon(Icons.add_circle_outline_rounded, color: Color(0xFF4F46E5)),
          SizedBox(width: 8),
          Text(
            'Tạo Chủ Đề Mới',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tên chủ đề:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Ví dụ: Từ vựng Toeic 600+',
                  hintStyle:
                      TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập tên chủ đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              const Text(
                'Mô tả ngắn gọn:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Mục tiêu học và ghi nhớ các từ này...',
                  hintStyle:
                      TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập mô tả';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text(
                'Chọn Icon đại diện:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableIcons.map((item) {
                  final isSelected = _selectedIcon == item['name'];
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      setState(() => _selectedIcon = item['name'] as String);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.indigo.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF4F46E5)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 16,
                            color: isSelected
                                ? const Color(0xFF4F46E5)
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF4F46E5)
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Tạo ngay'),
        ),
      ],
    );
  }
}

