import 'package:flutter/foundation.dart';
import 'follow_state_service.dart';
import 'user_posts_service.dart';
import 'user_preferences.dart';

/// User stats shared by Profile and Discover.
/// Following from FollowStateService, favorites from UserPostsService, followers from UserPreferences.
class UserStatsService {
  static final ValueNotifier<UserStats> _notifier =
      ValueNotifier(UserStats(0, 0, 0));
  static bool _initialized = false;

  static ValueListenable<UserStats> get notifier => _notifier;

  static int get followingCount => _notifier.value.followingCount;
  static int get followersCount => _notifier.value.followersCount;
  static int get favoritesCount => _notifier.value.favoritesCount;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await refresh();
    FollowStateService.addListener(_onFollowChanged);
    UserPostsService.notifier.addListener(_onPostsChanged);
  }

  static void dispose() {
    FollowStateService.removeListener(_onFollowChanged);
    UserPostsService.notifier.removeListener(_onPostsChanged);
  }

  static void _onFollowChanged(String botId, int delta) {
    refresh();
  }

  static void _onPostsChanged() {
    refresh();
  }

  static UserStats get stats => _notifier.value;

  static Future<void> refresh() async {
    final following = FollowStateService.followingCount;
    final followers = await UserPreferences.getFollowersCount();
    final favorites =
        UserPostsService.posts.where((p) => p.isFavorited).length;
    _notifier.value = UserStats(following, followers, favorites);
  }
}

class UserStats {
  final int followingCount;
  final int followersCount;
  final int favoritesCount;

  UserStats(this.followingCount, this.followersCount, this.favoritesCount);
}
