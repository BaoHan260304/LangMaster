import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

/// Widget quản lý và hiển thị đa phương tiện cho Flashcard:
/// - Hình ảnh minh họa (Image) với bộ nhớ đệm CachedNetworkImage
/// - Âm thanh phát âm chuẩn (Audio) với AudioPlayer
/// - Video ngữ cảnh thực tế (Video) với VideoPlayerController
/// Xử lý đầy đủ: Loading states, Error fallback, mounted check và dispose()
class MultiMediaCardContent extends StatefulWidget {
  final String? imageUrl;
  final String? audioUrl;
  final String? videoUrl;

  const MultiMediaCardContent({
    super.key,
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
  });

  @override
  State<MultiMediaCardContent> createState() => _MultiMediaCardContentState();
}

class _MultiMediaCardContentState extends State<MultiMediaCardContent> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  VideoPlayerController? _videoController;

  bool _isAudioPlaying = false;
  bool _isAudioLoading = false;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;

  @override
  void initState() {
    super.initState();
    _initVideoIfNeeded();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _isAudioPlaying = false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant MultiMediaCardContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _videoController?.dispose();
      _videoController = null;
      _isVideoInitialized = false;
      _isVideoError = false;
      _initVideoIfNeeded();
    }
  }

  void _initVideoIfNeeded() {
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
              _isVideoError = false;
            });
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _isVideoError = true;
              _isVideoInitialized = false;
            });
          }
        });
    }
  }

  Future<void> _toggleAudio() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) return;

    if (_isAudioPlaying) {
      await _audioPlayer.stop();
      if (mounted) setState(() => _isAudioPlaying = false);
      return;
    }

    setState(() => _isAudioLoading = true);
    try {
      await _audioPlayer.play(UrlSource(widget.audioUrl!));
      if (mounted) {
        setState(() {
          _isAudioPlaying = true;
          _isAudioLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
          _isAudioPlaying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi phát âm thanh: $e'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;
    final hasAudio = widget.audioUrl != null && widget.audioUrl!.isNotEmpty;
    final hasVideo = widget.videoUrl != null && widget.videoUrl!.isNotEmpty;

    if (!hasImage && !hasAudio && !hasVideo) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. HIỂN THỊ HÌNH ẢNH MINH HỌA
        if (hasImage) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl!,
              height: 155,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 155,
                color: Colors.grey.shade100,
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 140,
                color: Colors.grey.shade100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined,
                        size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 6),
                    Text(
                      'Không thể tải ảnh minh họa',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // 2. NÚT PHÁT ÂM THANH MẪU
        if (hasAudio) ...[
          OutlinedButton.icon(
            onPressed: _isAudioLoading ? null : _toggleAudio,
            icon: _isAudioLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isAudioPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                    color: const Color(0xFF4F46E5),
                    size: 20,
                  ),
            label: Text(
              _isAudioLoading
                  ? 'Đang tải Audio...'
                  : (_isAudioPlaying ? 'Dừng phát' : 'Nghe phát âm bản ngữ'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4F46E5),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
              side: BorderSide(color: Colors.indigo.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.indigo.shade50.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // 3. HIỂN THỊ VIDEO NGỮ CẢNH
        if (hasVideo) ...[
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: _isVideoError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam_off_outlined,
                            size: 36, color: Colors.white54),
                        const SizedBox(height: 6),
                        Text(
                          'Không tải được video ngữ cảnh',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : _isVideoInitialized && _videoController != null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                          ),
                          Container(
                            color: _videoController!.value.isPlaying
                                ? Colors.transparent
                                : Colors.black38,
                          ),
                          IconButton(
                            iconSize: 46,
                            icon: Icon(
                              _videoController!.value.isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_fill_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            onPressed: () {
                              setState(() {
                                if (_videoController!.value.isPlaying) {
                                  _videoController!.pause();
                                } else {
                                  _videoController!.play();
                                }
                              });
                            },
                          ),
                        ],
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Đang tải video ngữ cảnh...',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ],
    );
  }
}

