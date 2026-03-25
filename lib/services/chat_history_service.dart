import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistoryService {
  static String _key(String botId) => 'chat_history_$botId';

  static Future<List<Map<String, String>>> loadHistory(String botId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key(botId));
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => (e as Map<String, dynamic>).map(
                (k, v) => MapEntry(k, (v ?? '').toString()),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static final ValueNotifier<void> historyUpdated = ValueNotifier(null);

  static Future<void> saveHistory(String botId, List<Map<String, String>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(botId), jsonEncode(messages));
    historyUpdated.value = Object();
  }

  static Future<DateTime?> getLastMessageTime(String botId) async {
    final meta = await getSessionMeta(botId);
    if (meta == null) return null;
    final ts = meta['lastMessageTime'];
    if (ts == null || ts.isEmpty) return null;
    return DateTime.tryParse(ts);
  }

  static Future<List<String>> getAllSessionBotIds() async {
    final prefs = await SharedPreferences.getInstance();
    const prefix = 'chat_history_';
    return prefs.getKeys()
        .where((k) => k.startsWith(prefix))
        .map((k) => k.substring(prefix.length))
        .toList();
  }

  static Future<String> getLastMessagePreview(String botId) async {
    final history = await loadHistory(botId);
    if (history.isEmpty) return '';
    final last = history.last;
    final content = last['content'] ?? '';
    return content.length > 30 ? '${content.substring(0, 30)}...' : content;
  }

  static Future<void> deleteHistory(String botId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(botId));
    await prefs.remove(_sessionMetaKey(botId));
    historyUpdated.value = Object();
  }

  static String _sessionMetaKey(String botId) => 'chat_session_meta_$botId';

  static Future<void> saveSessionMeta(
    String botId, {
    required String name,
    required String avatarUrl,
    String location = '',
    DateTime? lastMessageTime,
    String? characterItemJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getSessionMeta(botId);
    final meta = <String, String>{
      'id': botId,
      'name': name,
      'avatarUrl': avatarUrl,
      'location': location,
      ...?existing,
    };
    if (lastMessageTime != null) {
      meta['lastMessageTime'] = lastMessageTime.toIso8601String();
    }
    if (characterItemJson != null && characterItemJson.isNotEmpty) {
      meta['characterItemJson'] = characterItemJson;
    }
    await prefs.setString(_sessionMetaKey(botId), jsonEncode(meta));
  }

  static Future<Map<String, String>?> getSessionMeta(String botId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_sessionMetaKey(botId));
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, (v ?? '').toString()));
    } catch (_) {
      return null;
    }
  }
}
