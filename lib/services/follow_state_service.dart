import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Follow state for Discover bots so detail and profile screens stay aligned.
/// Listeners receive (botId, followersDelta) so the Discover feed can update follower counts.
/// Persisted locally; kept in sync with Profile following count.
class FollowStateService {
  static const _keyFollowing = 'follow_state_ids';
  static final Map<String, bool> _following = {};
  static final List<void Function(String botId, int followersDelta)> _listeners = [];
  static bool _initialized = false;

  static bool isFollowing(String botId) => _following[botId] ?? false;

  static int get followingCount =>
      _following.values.where((v) => v).length;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyFollowing);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        for (final id in list) {
          if (id is String) _following[id] = true;
        }
      } catch (_) {}
    }
  }

  static Future<void> _save() async {
    final ids = _following.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFollowing, jsonEncode(ids));
  }

  static void setFollowing(String botId, bool value) {
    final wasFollowing = _following[botId] ?? false;
    _following[botId] = value;
    final delta = (value ? 1 : 0) - (wasFollowing ? 1 : 0);
    _save();
    for (final cb in _listeners) {
      cb(botId, delta);
    }
  }

  static void addListener(void Function(String botId, int followersDelta) cb) => _listeners.add(cb);
  static void removeListener(void Function(String botId, int followersDelta) cb) => _listeners.remove(cb);
}
