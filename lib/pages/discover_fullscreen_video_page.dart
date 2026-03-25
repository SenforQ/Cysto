import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

String _videoExtFromPathOrUrl(String ref) {
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

class DiscoverFullscreenVideoPage extends StatefulWidget {
  const DiscoverFullscreenVideoPage({
    super.key,
    required this.videoUrl,
    this.initialPosition,
    this.startPlaying = false,
  });

  final String videoUrl;
  final Duration? initialPosition;
  final bool startPlaying;

  @override
  State<DiscoverFullscreenVideoPage> createState() =>
      _DiscoverFullscreenVideoPageState();
}

class _DiscoverFullscreenVideoPageState
    extends State<DiscoverFullscreenVideoPage> {
  VideoPlayerController? _controller;
  bool _loading = true;
  bool _error = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky));
    unawaited(SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]));
    _init();
  }

  Future<void> _init() async {
    try {
      final isAsset = widget.videoUrl.startsWith('assets/');
      _controller = isAsset
          ? VideoPlayerController.asset(widget.videoUrl)
          : VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller!.initialize();
      await _controller!.setLooping(false);
      if (widget.initialPosition != null &&
          widget.initialPosition! > Duration.zero) {
        await _controller!.seekTo(widget.initialPosition!);
      }
      if (widget.startPlaying) {
        await _controller!.play();
      }
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  Future<void> _restoreSystemUi() async {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _exitWithPosition() async {
    final pos = _controller?.value.isInitialized == true
        ? _controller!.value.position
        : null;
    await _restoreSystemUi();
    if (mounted) Navigator.of(context).pop<Duration?>(pos);
  }

  Future<void> _saveVideoToAlbum() async {
    if (!mounted || _loading || _error || _controller == null) return;
    final messenger = ScaffoldMessenger.of(context);
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
      final ref = widget.videoUrl;
      final dir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ext = _videoExtFromPathOrUrl(ref);
      final file = File('${dir.path}/discover_video_$ts.$ext');
      if (ref.startsWith('assets/')) {
        final data = await rootBundle.load(ref);
        await file.writeAsBytes(data.buffer.asUint8List());
      } else {
        final response = await http.get(Uri.parse(ref));
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
        await file.writeAsBytes(response.bodyBytes);
      }
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
    unawaited(_restoreSystemUi());
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_exitWithPosition());
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_loading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white70),
              )
            else if (_error || _controller == null)
              const Center(
                child:
                    Icon(Icons.error_outline, color: Colors.white54, size: 48),
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
                  child: SizedBox.expand(
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
                ),
              ),
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 3,
                        shadowColor: Colors.black38,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => unawaited(_exitWithPosition()),
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
                    ),
                  ),
                  const Spacer(),
                  if (!_loading && !_error && _controller != null)
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
      ),
    );
  }
}
