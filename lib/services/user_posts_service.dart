import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_post.dart';

class UserPostsService {
  static const String _keyPosts = 'user_posts_json';
  static final List<UserPost> _posts = [];
  static final ValueNotifier<List<UserPost>> notifier = ValueNotifier(_posts);
  static bool _initialized = false;

  static List<UserPost> get posts => List.unmodifiable(_posts);

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _loadFromStorage();
  }

  /// Reload posts from disk (e.g. when returning to Discover).
  static Future<void> reloadFromStorage() async {
    await _loadFromStorage();
  }

  static Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyPosts);
    if (jsonStr == null || jsonStr.isEmpty) return;
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _posts.clear();
      for (final e in list) {
        final post = UserPost.fromJson((e as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, v),
        ));
        _posts.add(post);
      }
      notifier.value = List.from(_posts);
    } catch (_) {}
  }

  static Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _posts.map((p) => p.toJson()).toList();
    await prefs.setString(_keyPosts, jsonEncode(list));
  }

  static void addPost(UserPost post) {
    _posts.insert(0, post);
    notifier.value = List.from(_posts);
    _saveToStorage();
  }

  static void removePost(String postId) {
    _posts.removeWhere((p) => p.id == postId);
    notifier.value = List.from(_posts);
    _saveToStorage();
  }

  static void updatePost(UserPost updated) {
    final i = _posts.indexWhere((p) => p.id == updated.id);
    if (i >= 0) {
      _posts[i] = updated;
      notifier.value = List.from(_posts);
      _saveToStorage();
    }
  }

  static Future<String> copyImageToAppDir(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final userPostsDir = Directory('${dir.path}/user_posts');
    if (!await userPostsDir.exists()) {
      await userPostsDir.create(recursive: true);
    }
    final name = '${DateTime.now().millisecondsSinceEpoch}_${sourcePath.split('/').last}';
    final destFile = File('${userPostsDir.path}/$name');
    await File(sourcePath).copy(destFile.path);
    return destFile.path;
  }
}
