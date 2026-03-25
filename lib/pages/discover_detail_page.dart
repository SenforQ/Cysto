import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import '../models/discover_bot.dart';
import '../services/block_mute_service.dart';
import '../services/discover_bot_service.dart';
import '../widgets/bubble_background.dart';
import '../widgets/discover_video_content.dart';
import 'bot_profile_page.dart';
import 'report_page.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

class DiscoverDetailPage extends StatefulWidget {
  const DiscoverDetailPage({
    super.key,
    required this.bot,
  });

  final DiscoverBot bot;

  @override
  State<DiscoverDetailPage> createState() => _DiscoverDetailPageState();
}

class _DiscoverDetailPageState extends State<DiscoverDetailPage> {
  late DiscoverBot _currentBot;

  @override
  void initState() {
    super.initState();
    _currentBot = widget.bot;
  }

  Future<void> _showFullScreenImage(String contentUrl, bool isAsset) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => _FullScreenImageView(
          contentUrl: contentUrl,
          isAsset: isAsset,
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Widget _buildAvatar(String avatarUrl, double size) {
    if (avatarUrl.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => Icon(
            Icons.person,
            color: Colors.grey.shade600,
            size: size * 0.6,
          ),
        ),
      );
    }
    if (avatarUrl.startsWith('assets/')) {
      return ClipOval(
        child: Image.asset(
          avatarUrl,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => Icon(
            Icons.person,
            color: Colors.grey.shade600,
            size: size * 0.6,
          ),
        ),
      );
    }
    return Icon(Icons.person, color: Colors.grey, size: size * 0.6);
  }

  void _showMoreActionSheet() {
    final merged = DiscoverBotService.mergeWithLatest(_currentBot);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        message: Text(
          merged.name,
          style: const TextStyle(
            fontSize: 13,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => ReportPage(bot: merged),
                ),
              );
            },
            child: const Text('Report'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              final nav = Navigator.of(context);
              await BlockMuteService.addBlocked(merged.id);
              if (!context.mounted) return;
              nav.popUntil((r) => r.isFirst);
            },
            child: const Text('Block'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              final nav = Navigator.of(context);
              await BlockMuteService.addMuted(merged.id);
              if (!context.mounted) return;
              nav.popUntil((r) => r.isFirst);
            },
            child: const Text('Mute'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _openBotProfile() {
    Navigator.of(context).push<DiscoverBot>(
      MaterialPageRoute(
        builder: (ctx) => BotProfilePage(
          bot: DiscoverBotService.mergeWithLatest(_currentBot),
        ),
      ),
    ).then((updatedBot) {
      if (mounted && updatedBot != null) {
        setState(() => _currentBot = updatedBot);
      }
    });
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, int value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(DiscoverBot bot) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _openBotProfile,
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey.shade200,
                  child: _buildAvatar(bot.avatarUrl, 72),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bot.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (bot.bio.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        bot.bio,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(Icons.schedule_outlined, 'Posted ${_formatTime(bot.publishTime)}'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _miniStat('Following', bot.followingCount),
              Container(
                width: 1,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: Colors.grey.shade200,
              ),
              _miniStat('Followers', bot.followersCount),
              Container(
                width: 1,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: Colors.grey.shade200,
              ),
              _miniStat('Likes', bot.totalLikesCount),
              Container(
                width: 1,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: Colors.grey.shade200,
              ),
              _miniStat('Collections', bot.collectionsCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<String> paths) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: paths.length,
      itemBuilder: (context, i) {
        final path = paths[i];
        return GestureDetector(
          onTap: () => _showFullScreenImage(path, true),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              path,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade500),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bot = _currentBot;

    return Scaffold(
      backgroundColor: kBubbleBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 8,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    bot.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.error_outline,
                    color: Colors.grey.shade800,
                    size: 26,
                  ),
                  onPressed: _showMoreActionSheet,
                  tooltip: 'More',
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _buildProfileCard(bot),
                  ),
                  if (bot.galleryImages.isNotEmpty) ...[
                    _sectionTitle('Photos'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildPhotoGrid(bot.galleryImages),
                    ),
                  ],
                  if (bot.galleryVideos.isNotEmpty) ...[
                    _sectionTitle('Videos'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          for (int i = 0; i < bot.galleryVideos.length; i++) ...[
                            DiscoverVideoContent(
                              key: ValueKey<String>('${bot.id}_vid_$i'),
                              videoUrl: bot.galleryVideos[i],
                              onTap: () {},
                            ),
                            if (i < bot.galleryVideos.length - 1) const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  ],
                  SizedBox(
                    height: 24 + MediaQuery.of(context).padding.bottom,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _FullScreenImageView extends StatelessWidget {
  const _FullScreenImageView({
    required this.contentUrl,
    required this.isAsset,
  });

  final String contentUrl;
  final bool isAsset;

  Future<Uint8List?> _getImageBytes() async {
    if (isAsset) {
      final data = await rootBundle.load(contentUrl);
      return data.buffer.asUint8List();
    } else {
      final response = await http.get(Uri.parse(contentUrl));
      if (response.statusCode == 200) return response.bodyBytes;
      return null;
    }
  }

  Future<void> _saveToGallery(BuildContext context) async {
    try {
      final bytes = await _getImageBytes();
      if (bytes == null || bytes.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get image')),
          );
        }
        return;
      }
      await Gal.putImageBytes(bytes);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to album')),
        );
      }
    } on GalException catch (e) {
      if (context.mounted) {
        final msg = e.platformException.message ?? e.type.name;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $msg')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: isAsset
                    ? Image.asset(
                        contentUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: 64,
                        ),
                      )
                    : Image.network(
                        contentUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) =>
                            progress == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator(
                                      color: _kThemeColor,
                                    ),
                                  ),
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: 64,
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: Material(
              color: _kThemeColor,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: () => _saveToGallery(context),
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.download, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Download',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
