import 'package:flutter/foundation.dart';

import '../data/discover_data.dart';
import '../models/discover_bot.dart';
import 'block_mute_service.dart';
import 'discover_bot_engagement_service.dart';
import 'discover_comment_service.dart';
import 'follow_state_service.dart';

/// Central source for Discover bot data so follower, like, and favorite counts stay in sync.
class DiscoverBotService {
  static final ValueNotifier<List<DiscoverBot>> _botsNotifier =
      ValueNotifier<List<DiscoverBot>>([]);

  static ValueListenable<List<DiscoverBot>> get botsNotifier => _botsNotifier;

  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    final initial = discoverBots.map((b) {
      if (FollowStateService.isFollowing(b.id)) {
        return b.copyWith(followersCount: b.followersCount + 1);
      }
      return b;
    }).toList();
    _botsNotifier.value = initial;
    FollowStateService.addListener(_onFollowStateChanged);
    _refreshBots();
  }

  static void dispose() {
    FollowStateService.removeListener(_onFollowStateChanged);
  }

  static void _onFollowStateChanged(String botId, int followersDelta) {
    _refreshBots();
  }

  static Future<void> _refreshBots() async {
    final filtered = await BlockMuteService.filterBots(List.from(discoverBots));
    final engagementRoot = await DiscoverBotEngagementService.loadPersisted();
    final enriched = await Future.wait(
      filtered.map((b) async {
        final commentCount =
            (await DiscoverCommentService.loadComments(b.id)).length;
        var x = DiscoverBotEngagementService.apply(
          b.copyWith(comments: commentCount),
          engagementRoot,
        );
        if (FollowStateService.isFollowing(b.id)) {
          x = x.copyWith(followersCount: b.followersCount + 1);
        }
        return x;
      }),
    );
    _botsNotifier.value = enriched;
  }

  /// Current bot list for the UI (block/mute filtered; follower counts include follow state).
  static List<DiscoverBot> get bots => _botsNotifier.value;

  /// Look up a bot by id with counts aligned to the Discover list.
  static DiscoverBot? getBotById(String id) {
    for (final b in _botsNotifier.value) {
      if (b.id == id) return b;
    }
    DiscoverBot? base;
    for (final b in discoverBots) {
      if (b.id == id) {
        base = b;
        break;
      }
    }
    if (base == null) return null;
    if (FollowStateService.isFollowing(id)) {
      return base.copyWith(followersCount: base.followersCount + 1);
    }
    return base;
  }

  /// Merge [bot]'s like/favorite flags with latest follower and aggregate counts from this service.
  static DiscoverBot mergeWithLatest(DiscoverBot bot) {
    final latest = getBotById(bot.id);
    if (latest == null) return bot;
    return latest.copyWith(
      likes: bot.likes,
      totalLikesCount: bot.totalLikesCount,
      collectionsCount: bot.collectionsCount,
      isLiked: bot.isLiked,
      isFavorited: bot.isFavorited,
    );
  }

  /// Reload bots (e.g. after returning from block/mute flows).
  static Future<void> refresh() => _refreshBots();
}
