import 'dart:convert';

import 'package:http/http.dart' as http;

class ZhipuChatService {
  static const String _endpoint =
      'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  static const String _model = 'glm-4-flash';

  static const String _apiKey = String.fromEnvironment(
    'ZHIPU_API_KEY',
    defaultValue:
        '7c7da0992839409aa6b29cb56e3a7452.III9yUXMpUTIuNJh',
  );

  static List<Map<String, String>> messagesForApi(
    List<Map<String, String>> messages,
  ) {
    final filtered = messages
        .where(
          (m) => m['role'] == 'user' || m['role'] == 'assistant',
        )
        .map(
          (m) => {
            'role': m['role']!,
            'content': m['content'] ?? '',
          },
        )
        .toList();
    while (filtered.isNotEmpty && filtered.first['role'] == 'assistant') {
      filtered.removeAt(0);
    }
    return filtered;
  }

  static Future<String> completeChat({
    required String systemPrompt,
    required List<Map<String, String>> conversation,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('ZHIPU_API_KEY is not configured');
    }
    final body = <String, dynamic>{
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...conversation,
      ],
    };

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    Map<String, dynamic> decoded;
    try {
      final raw = jsonDecode(response.body);
      if (raw is! Map<String, dynamic>) {
        throw Exception('Invalid API response');
      }
      decoded = raw;
    } catch (e) {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
      rethrow;
    }

    if (decoded['error'] != null) {
      final err = decoded['error'];
      if (err is Map && err['message'] != null) {
        throw Exception(err['message'].toString());
      }
      throw Exception(err.toString());
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) {
      throw Exception('No choices in API response');
    }
    final first = choices.first;
    if (first is! Map<String, dynamic>) {
      throw Exception('Invalid choice format');
    }
    final message = first['message'];
    if (message is! Map<String, dynamic>) {
      throw Exception('No message in choice');
    }
    final rawContent = message['content'];
    final text = _stringifyAssistantContent(rawContent);
    if (text.isEmpty) {
      throw Exception('Empty assistant content');
    }
    return text;
  }

  static String _stringifyAssistantContent(dynamic raw) {
    if (raw is String) return raw;
    if (raw is List) {
      final parts = <String>[];
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          final t = e['text'];
          if (t is String) parts.add(t);
        } else if (e is String) {
          parts.add(e);
        }
      }
      return parts.join();
    }
    return '';
  }
}
