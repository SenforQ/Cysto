import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/discover_comment.dart';

class DiscoverCommentService {
  static const String _keyPrefix = 'discover_comments_';

  static String _key(String botId) => '$_keyPrefix$botId';

  static Future<List<DiscoverComment>> loadComments(String botId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key(botId));
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => DiscoverComment.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveComments(String botId, List<DiscoverComment> comments) async {
    final prefs = await SharedPreferences.getInstance();
    final list = comments.map((c) => c.toJson()).toList();
    await prefs.setString(_key(botId), jsonEncode(list));
  }

  static Future<void> addComment(String botId, DiscoverComment comment) async {
    final list = await loadComments(botId);
    list.add(comment);
    await saveComments(botId, list);
  }
}
