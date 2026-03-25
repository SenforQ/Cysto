import 'dart:convert';
import 'package:http/http.dart' as http;

class CystoKEAiService {
  static const String _baseUrl = 'https://api.kie.ai';
  static const String _apiKey = 'a8f1d134d5811bdb4cb938fae8517fe2';

  static Future<String?> createImageTask({
    required String prompt,
    List<String>? imageInput,
    String aspectRatio = 'auto',
    String resolution = '1K',
    String outputFormat = 'jpg',
  }) async {
    final body = {
      'model': 'nano-banana-2',
      'input': {
        'prompt': prompt,
        if (imageInput != null && imageInput.isNotEmpty) 'image_input': imageInput,
        'aspect_ratio': aspectRatio,
        'resolution': resolution,
        'output_format': outputFormat,
      },
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/jobs/createTask'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 200 && data['data'] != null) {
        return data['data']['taskId'] as String?;
      }
    }
    return null;
  }

  static Future<String?> getTaskResult(String taskId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/jobs/recordInfo?taskId=$taskId'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 200 && data['data'] != null) {
        final taskData = data['data'];
        final state = taskData['state'] as String?;
        if (state == 'success') {
          final resultJson = taskData['resultJson'] as String?;
          if (resultJson != null) {
            final result = jsonDecode(resultJson);
            final urls = result['resultUrls'] as List?;
            if (urls != null && urls.isNotEmpty) {
              return urls.first as String;
            }
          }
        } else if (state == 'fail') {
          throw Exception(taskData['failMsg'] ?? 'Generation failed');
        }
      }
    }
    return null;
  }
}
