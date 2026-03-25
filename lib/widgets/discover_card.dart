import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/discover_bot.dart';
import '../services/block_mute_service.dart';
import '../pages/report_page.dart';
import 'discover_video_content.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

class DiscoverCard extends StatefulWidget {
  const DiscoverCard({
    super.key,
    required this.bot,
    required this.onDetailTap,
    this.onCommentTap,
    required this.onLikeChanged,
    required this.onFavoriteChanged,
    required this.onNeedRefresh,
  });

  final DiscoverBot bot;
  final VoidCallback onDetailTap;
  final VoidCallback? onCommentTap;
  final ValueChanged<bool> onLikeChanged;
  final ValueChanged<bool> onFavoriteChanged;
  final VoidCallback onNeedRefresh;

  @override
  State<DiscoverCard> createState() => _DiscoverCardState();
}

class _DiscoverCardState extends State<DiscoverCard> {
  late DiscoverBot _bot;
  PageController? _carouselController;
  int _carouselPage = 0;

  static const String _firstRoleId = '1';

  bool get _isFirstRole => _bot.id == _firstRoleId;

  List<String> _otherRoleImagePaths() {
    if (_bot.galleryImages.isNotEmpty) return List<String>.from(_bot.galleryImages);
    if (_bot.contentType == DiscoverContentType.image &&
        _bot.contentUrl.isNotEmpty) {
      return [_bot.contentUrl];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _bot = widget.bot;
    _ensureCarouselController();
  }

  void _ensureCarouselController() {
    if (_isFirstRole) {
      _carouselController?.dispose();
      _carouselController = null;
      return;
    }
    final paths = _otherRoleImagePaths();
    if (paths.isEmpty) {
      _carouselController?.dispose();
      _carouselController = null;
      return;
    }
    if (_carouselController == null) {
      _carouselController = PageController();
    }
  }

  @override
  void didUpdateWidget(DiscoverCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bot != oldWidget.bot) {
      _bot = widget.bot;
      _carouselPage = 0;
      _ensureCarouselController();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_carouselController?.hasClients ?? false) {
          _carouselController!.jumpToPage(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _carouselController?.dispose();
    super.dispose();
  }

  void _toggleLike() {
    final next = !_bot.isLiked;
    final delta = next ? 1 : -1;
    final newTotal = (_bot.totalLikesCount + delta).clamp(0, 2000000000);
    setState(() => _bot = _bot.copyWith(
      isLiked: next,
      totalLikesCount: newTotal,
      likes: newTotal,
    ));
    widget.onLikeChanged(next);
  }

  void _toggleFavorite() {
    final next = !_bot.isFavorited;
    final delta = next ? 1 : -1;
    final newCol = (_bot.collectionsCount + delta).clamp(0, 2000000000);
    setState(() => _bot = _bot.copyWith(
      isFavorited: next,
      collectionsCount: newCol,
    ));
    widget.onFavoriteChanged(next);
  }

  Widget _buildAvatar(double size) {
    if (_bot.avatarUrl.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          _bot.avatarUrl,
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
    if (_bot.avatarUrl.startsWith('assets/')) {
      return ClipOval(
        child: Image.asset(
          _bot.avatarUrl,
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

  void _showActionSheet() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        message: Text(
          _bot.name,
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
                  builder: (_) => ReportPage(bot: _bot),
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
              await BlockMuteService.addBlocked(_bot.id);
              if (!context.mounted) return;
              nav.popUntil((r) => r.isFirst);
              widget.onNeedRefresh();
            },
            child: const Text('Block'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              final nav = Navigator.of(context);
              await BlockMuteService.addMuted(_bot.id);
              if (!context.mounted) return;
              nav.popUntil((r) => r.isFirst);
              widget.onNeedRefresh();
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

  Widget _buildNetworkOrAssetImage(String url, {BoxFit fit = BoxFit.cover}) {
    final isAsset = url.startsWith('assets/');
    if (isAsset) {
      return Image.asset(
        url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _buildLoadingPlaceholder(),
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildOtherRolesImageCarousel() {
    final paths = _otherRoleImagePaths();
    if (paths.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: _buildPlaceholder(),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onDetailTap,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _carouselController,
                itemCount: paths.length,
                onPageChanged: (i) {
                  if (mounted) setState(() => _carouselPage = i);
                },
                itemBuilder: (context, i) {
                  return _buildNetworkOrAssetImage(paths[i]);
                },
              ),
              if (paths.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(paths.length, (i) {
                      final active = i == _carouselPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstRoleMedia(bool contentIsAsset) {
    if (_bot.contentType == DiscoverContentType.image) {
      return GestureDetector(
        onTap: widget.onDetailTap,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: contentIsAsset
                ? Image.asset(
                    _bot.contentUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : Image.network(
                    _bot.contentUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : _buildLoadingPlaceholder(),
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  ),
          ),
        ),
      );
    }
    return DiscoverVideoContent(
      videoUrl: _bot.contentUrl,
      onTap: widget.onDetailTap,
      allowFullscreen: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentIsAsset = _bot.contentUrl.startsWith('assets/');
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 15;

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onDetailTap,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade200,
                    child: _buildAvatar(44),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _bot.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: _showActionSheet,
                  color: const Color(0xFF616161),
                  iconSize: 24,
                ),
              ],
            ),
          ),
          if (_isFirstRole)
            _buildFirstRoleMedia(contentIsAsset)
          else
            _buildOtherRolesImageCarousel(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _ActionButton(
                  icon: _bot.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _bot.isLiked ? Colors.red : Colors.grey.shade600,
                  onTap: _toggleLike,
                ),
                const SizedBox(width: 20),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  color: Colors.grey.shade600,
                  count: _bot.comments,
                  onTap: widget.onCommentTap ?? widget.onDetailTap,
                ),
                const Spacer(),
                _ActionButton(
                  icon: _bot.isFavorited
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: _bot.isFavorited ? _kThemeColor : Colors.grey.shade600,
                  onTap: _toggleFavorite,
                ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _kThemeColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        color: Colors.grey.shade500,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    this.count,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color),
          if (count != null) ...[
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
