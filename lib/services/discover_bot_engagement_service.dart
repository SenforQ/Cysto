import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/discover_bot.dart';

/// Persists Discover like/favorite state and counts (restored when returning to the feed).
class DiscoverBotEngagementService {
  DiscoverBotEngagementService._();

  static const String _key = 'discover_bot_engagement_v1';

  static Future<Map<String, dynamic>> loadPersisted() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null || s.isEmpty) return {};
    try {
      final decoded = jsonDecode(s);
      if (decoded is! Map) return {};
      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return {};
    }
  }

  static Future<void> _saveRoot(Map<String, dynamic> root) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(root));
  }

  /// Merge [base] with locally saved like/favorite state.
  static DiscoverBot apply(DiscoverBot base, Map<String, dynamic> root) {
    final raw = root[base.id];
    if (raw is! Map) return base;
    final m = Map<String, dynamic>.from(raw);
    final total = m['totalLikesCount'] as int?;
    final likes = m['likes'] as int? ?? total;
    return base.copyWith(
      isLiked: m['isLiked'] as bool? ?? base.isLiked,
      isFavorited: m['isFavorited'] as bool? ?? base.isFavorited,
      totalLikesCount: total ?? base.totalLikesCount,
      collectionsCount: m['collectionsCount'] as int? ?? base.collectionsCount,
      likes: likes ?? base.likes,
    );
  }

  static Future<void> saveForBot(DiscoverBot b) async {
    final root = await loadPersisted();
    root[b.id] = {
      'isLiked': b.isLiked,
      'isFavorited': b.isFavorited,
      'totalLikesCount': b.totalLikesCount,
      'collectionsCount': b.collectionsCount,
      'likes': b.likes,
    };
    await _saveRoot(root);
  }
}
