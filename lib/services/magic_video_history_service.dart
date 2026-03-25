import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/magic_video_history_entry.dart';
import 'cystoke_magic_video_service.dart';

class MagicVideoHistoryService {
  static const String _key = 'magic_video_history_v1';
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static Future<List<MagicVideoHistoryEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key);
    if (raw == null || raw.isEmpty) return [];
    final out = <MagicVideoHistoryEntry>[];
    for (final s in raw) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        out.add(MagicVideoHistoryEntry.fromJson(m));
      } catch (_) {}
    }
    out.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    return out;
  }

  static Future<void> _save(List<MagicVideoHistoryEntry> list) async {
    list.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        list.map((e) => jsonEncode(e.toJson())).toList(growable: false);
    await prefs.setStringList(_key, encoded);
    revision.value++;
  }

  static Future<void> upsertEntry(MagicVideoHistoryEntry entry) async {
    final list = await getEntries();
    list.removeWhere((e) => e.taskId == entry.taskId);
    list.add(entry);
    await _save(list);
  }

  static Future<void> updateByTaskId(
    String taskId, {
    String? state,
    int? progress,
    bool replaceProgress = false,
    String? resultVideoUrl,
    bool replaceResultVideoUrl = false,
    String? failMsg,
    bool replaceFailMsg = false,
    bool clearProgress = false,
    bool clearFailMsg = false,
  }) async {
    final list = await getEntries();
    final i = list.indexWhere((e) => e.taskId == taskId);
    if (i < 0) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final e = list[i];
    list[i] = MagicVideoHistoryEntry(
      taskId: e.taskId,
      prompt: e.prompt,
      firstFrameImageUrl: e.firstFrameImageUrl,
      state: state ?? e.state,
      resultVideoUrl: replaceResultVideoUrl
          ? resultVideoUrl
          : e.resultVideoUrl,
      progress: clearProgress
          ? null
          : (replaceProgress ? progress : e.progress),
      failMsg: clearFailMsg
          ? null
          : (replaceFailMsg ? failMsg : e.failMsg),
      createdAtMs: e.createdAtMs,
      updatedAtMs: now,
    );
    await _save(list);
  }

  static bool _terminal(String state) {
    return state == 'success' ||
        state == 'fail' ||
        state == 'timeout' ||
        state == 'error';
  }

  static Future<void> syncPendingWithServer() async {
    final list = await getEntries();
    var changed = false;
    final now = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      if (_terminal(e.state)) continue;
      try {
        final s = await CystoKEMagicVideoService.getRecordInfo(e.taskId);
        final video = s.resultUrls != null && s.resultUrls!.isNotEmpty
            ? s.resultUrls!.first
            : null;
        list[i] = MagicVideoHistoryEntry(
          taskId: e.taskId,
          prompt: e.prompt,
          firstFrameImageUrl: e.firstFrameImageUrl,
          state: s.state.isNotEmpty ? s.state : e.state,
          resultVideoUrl: video ?? e.resultVideoUrl,
          progress: s.progress ?? e.progress,
          failMsg: s.failMsg ?? e.failMsg,
          createdAtMs: e.createdAtMs,
          updatedAtMs: now,
        );
        changed = true;
      } catch (_) {}
    }
    if (changed) await _save(list);
  }
}
