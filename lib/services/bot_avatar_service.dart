import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BotAvatarService {
  static String _key(String botId) => 'bot_custom_avatar_$botId';

  static Future<String?> getCustomAvatarPath(String botId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key(botId));
  }

  static Future<String> saveCustomAvatar(String botId, String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final botDir = Directory(path.join(appDir.path, 'bot_avatars'));
    if (!await botDir.exists()) await botDir.create(recursive: true);
    final destPath = path.join(botDir.path, '${botId}_${DateTime.now().millisecondsSinceEpoch}.png');
    await File(sourcePath).copy(destPath);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(botId), destPath);
    return destPath;
  }

  static Future<File?> getCustomAvatarFile(String botId) async {
    final p = await getCustomAvatarPath(botId);
    if (p == null) return null;
    final f = File(p);
    return f.existsSync() ? f : null;
  }
}
