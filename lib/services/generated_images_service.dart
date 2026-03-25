import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/generated_image_item.dart'
    show GeneratedImageEntrySource, GeneratedImageItem;

class GeneratedImagesService {
  static const String _key = 'generated_images';
  static const String _keyLegacy = 'generated_image_urls';
  static final ValueNotifier<int> imageCountNotifier = ValueNotifier(0);

  static Future<void> addImage(GeneratedImageItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getItems();
    list.insert(0, item);
    await _saveItems(prefs, list);
    imageCountNotifier.value++;
  }

  static Future<void> addImageWithMetadata({
    required String url,
    required List<String> tags,
    required String gender,
    String characterName = '',
    String personality = '',
    String styleDescription = '',
    String entrySource = GeneratedImageEntrySource.aiStudio,
  }) async {
    await addImage(GeneratedImageItem(
      url: url,
      tags: tags,
      gender: gender,
      characterName: characterName,
      personality: personality,
      styleDescription: styleDescription,
      entrySource: entrySource,
    ));
  }

  static Future<void> _saveItems(SharedPreferences prefs, List<GeneratedImageItem> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await prefs.setStringList(_key, jsonList.map((e) => jsonEncode(e)).toList());
  }

  static Future<List<GeneratedImageItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key);
    if (jsonList != null && jsonList.isNotEmpty) {
      return jsonList.map((s) {
        try {
          final m = jsonDecode(s) as Map<String, dynamic>;
          return GeneratedImageItem.fromJson(m);
        } catch (_) {
          return GeneratedImageItem.fromJson({'url': s});
        }
      }).toList();
    }
    final legacyUrls = prefs.getStringList(_keyLegacy);
    if (legacyUrls != null && legacyUrls.isNotEmpty) {
      final items = legacyUrls.map((url) => GeneratedImageItem(url: url, tags: [], gender: '')).toList();
      await prefs.remove(_keyLegacy);
      await _saveItems(prefs, items);
      return items;
    }
    return [];
  }

  static Future<List<String>> getImages() async {
    final items = await getItems();
    return items.map((e) => e.url).toList();
  }
}
