import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalCharacterImageStore {
  static const String prefix = 'local_character:';

  static bool isLocalStored(String url) => url.startsWith(prefix);

  static Future<String> importFromXFile(XFile xFile) async {
    final base = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(base.path, 'created_characters'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final ext = p.extension(xFile.path);
    final safeExt = ext.isNotEmpty ? ext : '.jpg';
    final filename = '${DateTime.now().millisecondsSinceEpoch}$safeExt';
    final destPath = p.join(folder.path, filename);
    await File(xFile.path).copy(destPath);
    final relative = p.join('created_characters', filename);
    final normalized = relative.replaceAll(r'\', '/');
    return '$prefix$normalized';
  }

  static Future<File?> fileForUrl(String url) async {
    if (!isLocalStored(url)) return null;
    final rel = url.substring(prefix.length);
    final base = await getApplicationDocumentsDirectory();
    final path = p.join(base.path, rel);
    final file = File(path);
    if (await file.exists()) return file;
    return null;
  }
}
