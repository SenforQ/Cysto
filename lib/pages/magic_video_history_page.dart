import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../models/magic_video_history_entry.dart';
import '../services/magic_video_history_service.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

String _magicVideoExtFromUrl(String ref) {
  var s = ref.trim().toLowerCase();
  final q = s.indexOf('?');
  if (q >= 0) s = s.substring(0, q);
  if (s.endsWith('.mov')) return 'mov';
  if (s.endsWith('.webm')) return 'webm';
  if (s.endsWith('.m4v')) return 'm4v';
  if (s.endsWith('.avi')) return 'avi';
  if (s.endsWith('.mp4')) return 'mp4';
  return 'mp4';
}

class MagicVideoHistoryPage extends StatefulWidget {
  const MagicVideoHistoryPage({super.key});

  @override
  State<MagicVideoHistoryPage> createState() => _MagicVideoHistoryPageState();
}

class _MagicVideoHistoryPageState extends State<MagicVideoHistoryPage> {
  List<MagicVideoHistoryEntry> _entries = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    MagicVideoHistoryService.revision.addListener(_onRevision);
    _reload();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) => _sync());
  }

  @override
  void dispose() {
    _timer?.cancel();
    MagicVideoHistoryService.revision.removeListener(_onRevision);
    super.dispose();
  }

  void _onRevision() => _reload();

  Future<void> _reload() async {
    final list = await MagicVideoHistoryService.getEntries();
    if (mounted) setState(() => _entries = list);
  }

  Future<void> _sync() async {
    await MagicVideoHistoryService.syncPendingWithServer();
  }

  String _stateLabel(String state) {
    switch (state) {
      case 'submitted':
        return 'Submitted';
      case 'waiting':
        return 'Waiting';
      case 'queuing':
        return 'In queue';
      case 'generating':
        return 'Generating';
      case 'success':
        return 'Done';
      case 'fail':
        return 'Failed';
      case 'timeout':
        return 'Timed out';
      case 'error':
        return 'Error';
      default:
        return state.isEmpty ? 'Processing' : state;
    }
  }

  Color _stateColor(String state) {
    switch (state) {
      case 'success':
        return Colors.green.shade700;
      case 'fail':
      case 'timeout':
      case 'error':
        return Colors.red.shade700;
      default:
        return _kThemeColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Magic generation history',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: RefreshIndicator(
        color: _kThemeColor,
        onRefresh: () async {
          await _sync();
          await _reload();
        },
        child: _entries.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Center(
                      child: Text(
                        'No generations yet.\n'
                        'Submitted jobs appear here; you can check progress while they run.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final e = _entries[index];
                  return _HistoryCard(
                    entry: e,
                    stateLabel: _stateLabel(e.state),
                    stateColor: _stateColor(e.state),
                    onPlay: e.resultVideoUrl != null &&
                            e.resultVideoUrl!.isNotEmpty
                        ? () {
                            Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => MagicVideoPlaybackPage(
                                  videoUrl: e.resultVideoUrl!,
                                  title: e.prompt,
                                ),
                              ),
                            );
                          }
                        : null,
                  );
                },
              ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.entry,
    required this.stateLabel,
    required this.stateColor,
    this.onPlay,
  });

  final MagicVideoHistoryEntry entry;
  final String stateLabel;
  final Color stateColor;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final thumb = entry.firstFrameImageUrl;
    return Material(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPlay,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: thumb.startsWith('http')
                      ? Image.network(
                          thumb,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.prompt,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: stateColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stateLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: stateColor,
                            ),
                          ),
                        ),
                        if (entry.progress != null &&
                            !entry.isTerminal)
                          Text(
                            '${entry.progress}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        if (onPlay != null)
                          Text(
                            'Tap to play',
                            style: TextStyle(
                              fontSize: 12,
                              color: _kThemeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    if (entry.failMsg != null &&
                        entry.failMsg!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        entry.failMsg!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade700,
                          height: 1.3,
                        ),
                      ),
                    ],
                    if (!entry.isTerminal) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: entry.progress != null
                            ? entry.progress! / 100.0
                            : null,
                        color: _kThemeColor,
                        backgroundColor: Colors.grey.shade200,
                        minHeight: 3,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MagicVideoPlaybackPage extends StatefulWidget {
  const MagicVideoPlaybackPage({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  final String videoUrl;
  final String title;

  @override
  State<MagicVideoPlaybackPage> createState() => _MagicVideoPlaybackPageState();
}

class _MagicVideoPlaybackPageState extends State<MagicVideoPlaybackPage> {
  VideoPlayerController? _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final c = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await c.initialize();
    await c.setLooping(true);
    await c.play();
    if (mounted) setState(() => _controller = c);
  }

  Future<void> _saveVideoToAlbum() async {
    if (!mounted || _controller == null || !_controller!.value.isInitialized) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final url = widget.videoUrl;
    try {
      if (!await Gal.hasAccess(toAlbum: true)) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Photo library access is required to save the video.'),
            ),
          );
          return;
        }
      }
      setState(() => _saving = true);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        if (mounted) {
          setState(() => _saving = false);
          messenger.showSnackBar(
            SnackBar(
              content: Text('Download failed (${response.statusCode})'),
            ),
          );
        }
        return;
      }
      final ext = _magicVideoExtFromUrl(url);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/magic_video_${DateTime.now().millisecondsSinceEpoch}.$ext',
      );
      await file.writeAsBytes(response.bodyBytes);
      await Gal.putVideo(file.path);
      if (await file.exists()) {
        await file.delete();
      }
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(
          const SnackBar(content: Text('Video saved to Photos')),
        );
      }
    } on GalException catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Save failed: ${e.platformException.message ?? e.type.message}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(SnackBar(content: Text('Save failed: $e')));
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
    final ready = _controller != null && _controller!.value.isInitialized;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (!ready)
            const Center(
              child: CircularProgressIndicator(color: _kThemeColor),
            )
          else
            GestureDetector(
              onTap: () {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
                setState(() {});
              },
              child: ColoredBox(
                color: Colors.black,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4, right: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 3,
                        shadowColor: Colors.black38,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(),
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.black87,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.25,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (ready)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: FloatingActionButton(
                        onPressed: _saving ? null : _saveVideoToAlbum,
                        backgroundColor: _kThemeColor,
                        child: _saving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                              ),
                      ),
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
