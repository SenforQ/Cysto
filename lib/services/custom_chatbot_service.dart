import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_chatbot.dart';
import 'chat_history_service.dart';

class CustomChatbotService {
  static const String _key = 'custom_chatbots';
  static final ValueNotifier<List<CustomChatbot>> chatbotsNotifier = ValueNotifier([]);

  static Future<void> init() async {
    final list = await getAll();
    chatbotsNotifier.value = list;
  }

  static Future<List<CustomChatbot>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => CustomChatbot.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> add(CustomChatbot chatbot) async {
    final list = await getAll();
    list.insert(0, chatbot);
    await _save(list);
    chatbotsNotifier.value = List.from(list);
  }

  static Future<void> deleteById(String id) async {
    final list = await getAll();
    list.removeWhere((c) => c.id == id);
    await _save(list);
    await ChatHistoryService.deleteHistory(id);
    chatbotsNotifier.value = List.from(list);
  }

  static Future<void> deleteByIds(Set<String> ids) async {
    final list = await getAll();
    list.removeWhere((c) => ids.contains(c.id));
    await _save(list);
    for (final id in ids) {
      await ChatHistoryService.deleteHistory(id);
    }
    chatbotsNotifier.value = List.from(list);
  }

  static Future<void> _save(List<CustomChatbot> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }
}
