import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const _keyNickname = 'user_nickname';
  static const _keySignature = 'user_signature';
  static const _keyAvatarPath = 'user_avatar_path';
  static const _keyFollowingCount = 'user_following_count';
  static const _keyFollowersCount = 'user_followers_count';
  static const _keyFavoritesCount = 'user_favorites_count';
  static const _defaultNickname = 'Cysto';
  static const String defaultUserAvatar = 'assets/userdefault.png';

  static Future<String> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNickname) ?? _defaultNickname;
  }

  static Future<void> setNickname(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNickname, value);
  }

  static Future<String> getSignature() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySignature) ?? '';
  }

  static Future<void> setSignature(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySignature, value);
  }

  static Future<String?> getAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAvatarPath);
  }

  static Future<void> setAvatarPath(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_keyAvatarPath);
    } else {
      await prefs.setString(_keyAvatarPath, value);
    }
  }

  static Future<int> getFollowingCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyFollowingCount) ?? 0;
  }

  static Future<void> setFollowingCount(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFollowingCount, value);
  }

  static Future<int> getFollowersCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyFollowersCount) ?? 0;
  }

  static Future<void> setFollowersCount(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFollowersCount, value);
  }

  static Future<int> getFavoritesCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyFavoritesCount) ?? 0;
  }

  static Future<void> setFavoritesCount(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFavoritesCount, value);
  }
}
