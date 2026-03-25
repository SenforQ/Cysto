import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/generated_image_item.dart'
    show GeneratedImageEntrySource, GeneratedImageItem;
import '../services/generated_images_service.dart';
import '../widgets/bubble_background.dart';
import '../widgets/character_image_display.dart';
import 'image_detail_page.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

bool _isNetworkVideoUrl(String url) {
  final t = url.trim();
  if (!t.startsWith('http://') && !t.startsWith('https://')) return false;
  String path;
  try {
    path = Uri.parse(t).path.toLowerCase();
  } catch (_) {
    return false;
  }
  return path.endsWith('.mp4') ||
      path.endsWith('.mov') ||
      path.endsWith('.webm') ||
      path.endsWith('.m4v') ||
      path.endsWith('.avi');
}

String _videoFileExtension(String url) {
  try {
    final path = Uri.parse(url.trim()).path.toLowerCase();
    if (path.endsWith('.mov')) return 'mov';
    if (path.endsWith('.webm')) return 'webm';
    if (path.endsWith('.m4v')) return 'm4v';
    if (path.endsWith('.avi')) return 'avi';
  } catch (_) {}
  return 'mp4';
}

class GeneratedImageHistoryPage extends StatefulWidget {
  const GeneratedImageHistoryPage({super.key});

  @override
  State<GeneratedImageHistoryPage> createState() =>
      _GeneratedImageHistoryPageState();
}

class _GeneratedImageHistoryPageState extends State<GeneratedImageHistoryPage> {
  List<GeneratedImageItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    GeneratedImagesService.imageCountNotifier.addListener(_onCountChanged);
  }

  @override
  void dispose() {
    GeneratedImagesService.imageCountNotifier.removeListener(_onCountChanged);
    super.dispose();
  }

  void _onCountChanged() => _load();

  Future<void> _saveVideoToAlbum(BuildContext context, String url) async {
    if (!context.mounted) return;
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
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        messenger.showSnackBar(
          SnackBar(content: Text('Download failed (${response.statusCode})')),
        );
        return;
      }
      final ext = _videoFileExtension(url);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/cysto_video_${DateTime.now().millisecondsSinceEpoch}.$ext',
      );
      await file.writeAsBytes(response.bodyBytes);
      await Gal.putVideo(file.path);
      if (await file.exists()) {
        await file.delete();
      }
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Video saved to Photos')),
        );
      }
    } on GalException catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Save failed: ${e.platformException.message ?? e.type.message}',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    }
  }

  Future<void> _load() async {
    final list = await GeneratedImagesService.getItems();
    final onlyAiStudio = list
        .where((e) => e.entrySource == GeneratedImageEntrySource.aiStudio)
        .toList();
    if (mounted) {
      setState(() {
        _items = onlyAiStudio;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBubbleBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'AI image history',
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
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _kThemeColor))
            : _items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'No AI-generated images yet',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'Only images created on the Create page are listed here. '
                                  'Characters added manually on Home or chatbots are not included.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final height = 160.0 + (index % 3) * 40.0;
                            final isVideo = _isNetworkVideoUrl(item.url);
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ImageDetailPage(item: item),
                                  ),
                                );
                              },
                              child: _HistoryTile(
                                item: item,
                                height: height,
                                isVideo: isVideo,
                                onDownloadVideo: isVideo
                                    ? () => _saveVideoToAlbum(context, item.url)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.item,
    required this.height,
    required this.isVideo,
    this.onDownloadVideo,
  });

  final GeneratedImageItem item;
  final double height;
  final bool isVideo;
  final VoidCallback? onDownloadVideo;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CharacterImageDisplay(
              imageRef: item.url,
              fit: BoxFit.cover,
            ),
            if (isVideo)
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.videocam_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (onDownloadVideo != null)
              Positioned(
                top: 6,
                right: 6,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    tooltip: 'Save video to Photos',
                    onPressed: onDownloadVideo,
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: item.tags.take(2).map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _kThemeColor.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              t,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    if (item.characterName.isNotEmpty) ...[
                      if (item.tags.isNotEmpty) const SizedBox(height: 4),
                      Text(
                        item.characterName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
