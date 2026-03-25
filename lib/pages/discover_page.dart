import 'package:flutter/material.dart';
import '../models/discover_bot.dart';
import '../services/block_mute_service.dart';
import '../services/discover_bot_engagement_service.dart';
import '../services/discover_bot_service.dart';
import '../services/user_posts_service.dart';
import '../widgets/discover_card.dart';
import '../widgets/user_post_card.dart';
import 'discover_detail_page.dart';
import 'profile_page.dart';
import 'user_post_detail_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List<DiscoverBot> _bots = [];

  @override
  void initState() {
    super.initState();
    BlockMuteService.refreshNotifier.addListener(_onRefresh);
    DiscoverBotService.botsNotifier.addListener(_onBotsChanged);
    UserPostsService.notifier.addListener(_onUserPostsChanged);
    _onBotsChanged();
  }

  @override
  void dispose() {
    BlockMuteService.refreshNotifier.removeListener(_onRefresh);
    DiscoverBotService.botsNotifier.removeListener(_onBotsChanged);
    UserPostsService.notifier.removeListener(_onUserPostsChanged);
    super.dispose();
  }

  void _onUserPostsChanged() {
    if (mounted) setState(() {});
  }

  void _onBotsChanged() {
    if (!mounted) return;
    setState(() => _bots = List.from(DiscoverBotService.bots));
  }

  void _onRefresh() {
    DiscoverBotService.refresh();
  }

  Future<void> _onDetail(DiscoverBot bot) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => DiscoverDetailPage(bot: bot),
      ),
    );
    if (!mounted) return;
    await DiscoverBotService.refresh();
    await UserPostsService.reloadFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: const Text(
          'Discover',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(
          top: 8,
          bottom: 66 + MediaQuery.of(context).padding.bottom,
        ),
        itemCount: UserPostsService.posts.length + _bots.length,
        itemBuilder: (context, index) {
          final userPosts = UserPostsService.posts;
          if (index < userPosts.length) {
            final post = userPosts[index];
            return UserPostCard(
              post: post,
              onAvatarTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => const ProfilePage(),
                  ),
                );
              },
              onImageTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => UserPostDetailPage(post: post),
                ),
              ),
              onLikeChanged: (liked) {
                final updated = post.copyWith(
                  isLiked: liked,
                  likes: post.likes + (liked ? 1 : -1),
                );
                UserPostsService.updatePost(updated);
                _onUserPostsChanged();
              },
              onFavoriteChanged: (favorited) {
                final updated = post.copyWith(
                  isFavorited: favorited,
                  favoriteCount: post.favoriteCount + (favorited ? 1 : -1),
                );
                UserPostsService.updatePost(updated);
                _onUserPostsChanged();
              },
              onCommentTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => UserPostDetailPage(post: post),
                ),
              ),
              onDelete: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Post'),
                    content: const Text('Are you sure you want to delete this post?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  UserPostsService.removePost(post.id);
                  _onUserPostsChanged();
                }
              },
            );
          }
          final bot = _bots[index - userPosts.length];
          return DiscoverCard(
            bot: bot,
            onDetailTap: () => _onDetail(bot),
            onCommentTap: () => _onDetail(bot),
            onNeedRefresh: _onRefresh,
            onLikeChanged: (liked) async {
              final i = _bots.indexWhere((b) => b.id == bot.id);
              if (i < 0) return;
              final b = _bots[i];
              final delta = liked ? 1 : -1;
              final newTotal = (b.totalLikesCount + delta).clamp(0, 2000000000);
              final updated = b.copyWith(
                isLiked: liked,
                totalLikesCount: newTotal,
                likes: newTotal,
              );
              if (!mounted) return;
              setState(() {
                _bots = List.from(_bots)..[i] = updated;
              });
              await DiscoverBotEngagementService.saveForBot(updated);
            },
            onFavoriteChanged: (favorited) async {
              final i = _bots.indexWhere((b) => b.id == bot.id);
              if (i < 0) return;
              final b = _bots[i];
              final delta = favorited ? 1 : -1;
              final newCol = (b.collectionsCount + delta).clamp(0, 2000000000);
              final updated = b.copyWith(
                isFavorited: favorited,
                collectionsCount: newCol,
              );
              if (!mounted) return;
              setState(() {
                _bots = List.from(_bots)..[i] = updated;
              });
              await DiscoverBotEngagementService.saveForBot(updated);
            },
          );
        },
      ),
    );
  }
}
