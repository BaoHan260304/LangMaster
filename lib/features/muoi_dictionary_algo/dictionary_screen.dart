import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/mock_data/initial_data.dart';
import '../../core/models/flashcard_model.dart';
import '../quan_dashboard_topics/topic_manager_service.dart';
import 'recommendation_algo.dart';
import 'top_mistakes_screen.dart';

/// Màn hình Tra từ điển, Kiểm tra Gõ & Phát âm (Member 3):
/// - Tra cứu từ vựng tức thì với SearchBar
/// - Phát âm mẫu với FlutterTts
/// - Kiểm tra gõ đúng chính tả (Typing Check)
/// - Kiểm tra đọc phát âm với Speech-to-Text (Pronunciation Check)
/// - Tự động kích hoạt Popup nhắc lại từ sai sau mỗi 5 lượt tương tác
class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;

  List<FlashcardModel> _allWords = [];
  List<FlashcardModel> _filteredWords = [];

  bool _isSpeechAvailable = false;
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _allWords = List.from(InitialData.sampleFlashcards);
    _filteredWords = List.from(_allWords);

    _speech = stt.SpeechToText();
    _initTts();
    _initSpeech();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _initSpeech() async {
    try {
      _isSpeechAvailable = await _speech.initialize(
        onError: (val) {
          if (mounted) setState(() => _isListening = false);
        },
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
    } catch (e) {
      debugPrint('Speech init error: $e');
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredWords = List.from(_allWords);
      } else {
        final q = query.toLowerCase().trim();
        _filteredWords = _allWords.where((w) {
          return w.word.toLowerCase().contains(q) ||
              w.meaning.toLowerCase().contains(q) ||
              w.phonetic.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  Future<void> _speakWord(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  void _checkReminderPopup() {
    final algo = Provider.of<MistakeAlgorithmProvider>(context, listen: false);
    final reminderWord = algo.getScheduledReminderWord();
    if (reminderWord != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.alarm_on_rounded, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text('Nhắc nhở ôn tập!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hệ thống phát hiện từ vựng bạn có điểm cảnh báo cao nhất:',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminderWord.word,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reminderWord.meaning,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                algo.dismissReminder();
                Navigator.pop(ctx);
              },
              child: const Text('Bỏ qua'),
            ),
            ElevatedButton(
              onPressed: () {
                algo.dismissReminder();
                Navigator.pop(ctx);
                _showTypingTestDialog(
                  FlashcardModel(
                    id: 'reminder',
                    topicId: '',
                    word: reminderWord.word,
                    phonetic: '',
                    meaning: reminderWord.meaning,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Luyện tập ngay'),
            ),
          ],
        ),
      );
    }
  }

  void _showTypingTestDialog(FlashcardModel card) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.keyboard_outlined, color: Color(0xFF4F46E5)),
            SizedBox(width: 8),
            Text('Kiểm tra gõ từ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hãy gõ lại từ tiếng Anh cho nghĩa sau:',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                card.meaning,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nhập từ tiếng Anh...',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final input = controller.text.trim();
              final isCorrect =
                  input.toLowerCase() == card.word.toLowerCase();

              final algo = Provider.of<MistakeAlgorithmProvider>(context,
                  listen: false);
              algo.recordAttempt(
                word: card.word,
                meaning: card.meaning,
                isCorrect: isCorrect,
                isPronunciationTest: false,
              );

              // Cập nhật thống kê học tập hàng ngày
              Provider.of<TopicManagerProvider>(context, listen: false)
                  .recordWordStudied(isMastered: isCorrect);

              Navigator.pop(dialogCtx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isCorrect
                        ? 'Chính xác 100%! Gõ rất chuẩn.'
                        : 'Sai rồi! Từ đúng là: "${card.word}"',
                  ),
                  backgroundColor: isCorrect
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );

              _checkReminderPopup();
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
      ),
    );
  }

  void _showPronunciationTestDialog(FlashcardModel card) {
    _lastWords = '';
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.mic_none_rounded, color: Color(0xFF10B981)),
                  SizedBox(width: 8),
                  Text('Luyện phát âm',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Đọc to từ vựng sau:',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.word,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    card.phonetic,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.indigo.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nút ghi âm đọc
                  GestureDetector(
                    onTap: () async {
                      if (!_isSpeechAvailable) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tính năng nhận diện giọng nói chưa sẵn sàng hoặc không được hỗ trợ trên môi trường này'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      if (!_isListening) {
                        setDialogState(() => _isListening = true);
                        await _speech.listen(
                          onResult: (result) {
                            setDialogState(() {
                              _lastWords = result.recognizedWords;
                            });
                          },
                        );
                      } else {
                        await _speech.stop();
                        setDialogState(() => _isListening = false);
                      }
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? Colors.red.shade500
                            : const Color(0xFF4F46E5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? Colors.red : Colors.indigo)
                                .withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isListening
                        ? 'Đang lắng nghe... Hãy đọc to!'
                        : 'Bấm micro để bắt đầu nói',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isListening
                          ? Colors.red.shade600
                          : Colors.grey.shade600,
                    ),
                  ),
                  if (_lastWords.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Máy nghe thấy: "$_lastWords"',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _speech.stop();
                    Navigator.pop(dialogCtx);
                  },
                  child: const Text('Đóng'),
                ),
                ElevatedButton(
                  onPressed: _lastWords.isEmpty
                      ? null
                      : () {
                          _speech.stop();
                          final spoken = _lastWords.trim().toLowerCase();
                          final target = card.word.trim().toLowerCase();
                          final isCorrect =
                              spoken == target || spoken.contains(target);

                          final algo = Provider.of<MistakeAlgorithmProvider>(
                              context,
                              listen: false);
                          algo.recordAttempt(
                            word: card.word,
                            meaning: card.meaning,
                            isCorrect: isCorrect,
                            isPronunciationTest: true,
                          );

                          // Cập nhật thống kê học tập hàng ngày
                          Provider.of<TopicManagerProvider>(context,
                                  listen: false)
                              .recordWordStudied(isMastered: isCorrect);

                          Navigator.pop(dialogCtx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isCorrect
                                    ? 'Tuyệt vời! Phát âm của bạn rất chuẩn xác.'
                                    : 'Phát âm chưa khớp với "$target". Máy nhận diện là "$spoken"',
                              ),
                              backgroundColor: isCorrect
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          _checkReminderPopup();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Chấm điểm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Từ Điển & Luyện Tập',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: Color(0xFF4F46E5)),
            tooltip: 'Xem Top 10 từ sai',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TopMistakesScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Khung tìm kiếm & nút sang Top 10
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Tìm từ vựng tiếng Anh hoặc nghĩa tiếng Việt...',
                    hintStyle:
                        TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TopMistakesScreen()),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.red.shade700, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Xem Top 10 từ sai & Điểm cảnh báo ưu tiên',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right_rounded,
                            size: 16, color: Colors.red.shade700),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Danh sách từ vựng tra cứu
          Expanded(
            child: _filteredWords.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy từ vựng phù hợp',
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredWords.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final card = _filteredWords[index];
                      return _buildWordCard(card);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(FlashcardModel card) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.word,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.phonetic,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.indigo.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              // Nút đọc mẫu TTS
              IconButton(
                icon: const Icon(Icons.volume_up_rounded,
                    color: Color(0xFF4F46E5), size: 22),
                tooltip: 'Nghe phát âm',
                onPressed: () => _speakWord(card.word),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            card.meaning,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // 2 Nút chức năng: Kiểm tra Gõ & Luyện Phát âm
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showTypingTestDialog(card),
                icon: const Icon(Icons.keyboard_alt_outlined, size: 14),
                label: const Text('Test Gõ', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.indigo.shade200),
                  foregroundColor: const Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showPronunciationTestDialog(card),
                icon: const Icon(Icons.mic_rounded, size: 14),
                label: const Text('Test Đọc', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

