import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../pages/discover_fullscreen_video_page.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

class DiscoverVideoContent extends StatefulWidget {
  const DiscoverVideoContent({
    super.key,
    required this.videoUrl,
    this.onTap,
    this.allowFullscreen = false,
  });

  final String videoUrl;
  final VoidCallback? onTap;
  final bool allowFullscreen;

  @override
  State<DiscoverVideoContent> createState() => _DiscoverVideoContentState();
}

class _DiscoverVideoContentState extends State<DiscoverVideoContent> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final isAsset = widget.videoUrl.startsWith('assets/');
      if (isAsset) {
        _controller = VideoPlayerController.asset(widget.videoUrl);
      } else {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
      }
      await _controller!.initialize();
      await _controller!.setLooping(false);
      await _controller!.pause();
      await _controller!.seekTo(Duration.zero);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _hasError
            ? _buildErrorPlaceholder()
            : _isLoading
                ? _buildLoadingPlaceholder()
                : _buildVideoPlayer(),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _kThemeColor, strokeWidth: 2),
            SizedBox(height: 12),
            Text('Loading...', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(Icons.videocam_off, size: 48, color: Colors.grey.shade500),
      ),
    );
  }

  Future<void> _openFullscreen() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final pos = _controller!.value.position;
    final playing = _controller!.value.isPlaying;
    await _controller!.pause();
    if (!mounted) return;
    final back = await Navigator.of(context).push<Duration?>(
      MaterialPageRoute<Duration?>(
        fullscreenDialog: true,
        builder: (_) => DiscoverFullscreenVideoPage(
          videoUrl: widget.videoUrl,
          initialPosition: pos,
          startPlaying: playing,
        ),
      ),
    );
    if (!mounted || _controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (back != null) {
      await _controller!.seekTo(back);
    }
    setState(() {});
  }

  static const double _kPlayOverlaySize = 44;
  static const double _kPlayIconSize = 22;

  Widget _buildVideoPlayer() {
    void togglePlay() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
      setState(() {});
    }

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: togglePlay,
            child: _controller!.value.isPlaying
                ? const SizedBox.expand()
                : Center(
                    child: SizedBox(
                      width: _kPlayOverlaySize,
                      height: _kPlayOverlaySize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: _kPlayIconSize,
                          applyTextScaling: false,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        if (widget.allowFullscreen)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black.withValues(alpha: 0.45),
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                tooltip: 'Fullscreen',
                onPressed: _openFullscreen,
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller!,
            builder: (_, value, __) {
              final duration = value.duration;
              final position = value.position;
              final remaining = duration - position;
              final remainingRatio = duration.inMilliseconds > 0
                  ? remaining.inMilliseconds / duration.inMilliseconds
                  : 1.0;
              final remainingStr =
                  '-${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: remainingRatio,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              _kThemeColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      remainingStr,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
