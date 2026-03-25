import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/discover_bot.dart';

class BlockMuteService {
  static const String _keyBlocked = 'discover_blocked_ids';
  static const String _keyMuted = 'discover_muted_ids';
  static final ValueNotifier<int> refreshNotifier = ValueNotifier(0);

  static Future<Set<String>> getBlockedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyBlocked);
    return list != null ? list.toSet() : {};
  }

  static Future<Set<String>> getMutedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyMuted);
    return list != null ? list.toSet() : {};
  }

  static Future<void> addBlocked(String botId) async {
    final prefs = await SharedPreferences.getInstance();
    final set = await getBlockedIds();
    set.add(botId);
    await prefs.setStringList(_keyBlocked, set.toList());
    refreshNotifier.value++;
  }

  static Future<void> addMuted(String botId) async {
    final prefs = await SharedPreferences.getInstance();
    final set = await getMutedIds();
    set.add(botId);
    await prefs.setStringList(_keyMuted, set.toList());
    refreshNotifier.value++;
  }

  static Future<List<DiscoverBot>> filterBots(List<DiscoverBot> bots) async {
    final blocked = await getBlockedIds();
    final muted = await getMutedIds();
    final exclude = blocked.union(muted);
    return bots.where((b) => !exclude.contains(b.id)).toList();
  }
}
