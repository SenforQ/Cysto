import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiChatService {
  static const String _baseUrl = 'https://api.kie.ai/gemini-3.1-pro/v1';
  static const String _apiKey = 'a8f1d134d5811bdb4cb938fae8517fe2';

  static Stream<String> chatStream({
    required List<Map<String, dynamic>> messages,
    bool stream = true,
  }) async* {
    final request = {
      'model': 'gemini-3.1-pro',
      'messages': messages,
      'stream': stream,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(request),
    );

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode} ${response.body}');
    }

    final lines = response.body.split('\n');
    for (final line in lines) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6);
        if (data == '[DONE]') break;
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final choices = json['choices'] as List?;
          if (choices != null && choices.isNotEmpty) {
            final delta = choices[0]['delta'] as Map<String, dynamic>?;
            if (delta != null) {
              final content = delta['content'] as String?;
              if (content != null && content.isNotEmpty) {
                yield content;
              }
            }
          }
        } catch (_) {}
      }
    }
  }

  static Future<String?> sendMessage({
    required List<Map<String, String>> messages,
    required void Function(String delta) onChunk,
  }) async {
    final apiMessages = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content': 'Always respond in English.',
      },
      ...messages.map((m) {
        final role = m['role']!;
        final content = m['content'] ?? '';
        return {
          'role': role,
          'content': role == 'user'
              ? [{'type': 'text', 'text': content}]
              : content,
        };
      }),
    ];

    String? fullReply;
    await for (final chunk in chatStream(
      messages: apiMessages,
      stream: true,
    )) {
      onChunk(chunk);
      fullReply = (fullReply ?? '') + chunk;
    }
    return fullReply;
  }
}
