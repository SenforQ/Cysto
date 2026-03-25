import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

const String _cystoKEApiBase = 'https://api.kie.ai';
const String _uploadBase = 'https://kieai.redpandaai.co';

const String cystoKEMagicApiKey = String.fromEnvironment(
  'CYSTOKE_MAGIC_API_KEY',
  defaultValue: 'ad203d20131debd16b9336f035bc691e',
);

class CystoKESoraTaskStatus {
  CystoKESoraTaskStatus({
    required this.state,
    this.resultUrls,
    this.failMsg,
    this.progress,
  });

  final String state;
  final List<String>? resultUrls;
  final String? failMsg;
  final int? progress;
}

class CystoKEMagicVideoService {
  static Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer $cystoKEMagicApiKey',
        'Content-Type': 'application/json',
      };

  static String _dataUriForPngOrJpeg(Uint8List bytes) {
    final isPng = bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    final mime = isPng ? 'image/png' : 'image/jpeg';
    final b64 = base64Encode(bytes);
    return 'data:$mime;base64,$b64';
  }

  static Future<String?> uploadBase64Image(
    Uint8List imageBytes, {
    String fileName = 'magic-image.jpg',
  }) async {
    final uri = Uri.parse('$_uploadBase/api/file-base64-upload');
    final body = jsonEncode({
      'base64Data': _dataUriForPngOrJpeg(imageBytes),
      'uploadPath': 'images/magic',
      'fileName': fileName,
    });
    final response = await http.post(uri, headers: _authHeaders, body: body);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Upload: invalid response');
    }
    if (decoded['code'] != 200) {
      throw Exception(decoded['msg']?.toString() ?? 'Upload failed');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Upload: missing data');
    }
    final url = data['downloadUrl'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Upload: no downloadUrl');
    }
    return url;
  }

  static Future<String?> createSoraImageToVideoTask({
    required String prompt,
    required List<String> imageUrls,
    String aspectRatio = 'landscape',
    String nFrames = '10',
    bool removeWatermark = true,
    String uploadMethod = 's3',
    List<String>? characterIdList,
  }) async {
    final input = <String, dynamic>{
      'prompt': prompt,
      'image_urls': imageUrls,
      'aspect_ratio': aspectRatio,
      'n_frames': nFrames,
      'remove_watermark': removeWatermark,
      'upload_method': uploadMethod,
    };
    if (characterIdList != null && characterIdList.isNotEmpty) {
      input['character_id_list'] = characterIdList;
    }

    final body = <String, dynamic>{
      'model': 'sora-2-image-to-video',
      'input': input,
    };

    final response = await http.post(
      Uri.parse('$_cystoKEApiBase/api/v1/jobs/createTask'),
      headers: _authHeaders,
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('createTask: invalid JSON');
    }
    if (decoded['code'] != 200) {
      throw Exception(decoded['msg']?.toString() ?? 'createTask failed');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      return null;
    }
    return data['taskId'] as String?;
  }

  static Future<CystoKESoraTaskStatus> getRecordInfo(String taskId) async {
    final uri = Uri.parse('$_cystoKEApiBase/api/v1/jobs/recordInfo').replace(
      queryParameters: {'taskId': taskId},
    );
    final response = await http.get(uri, headers: _authHeaders);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('recordInfo: invalid JSON');
    }
    if (decoded['code'] != 200) {
      throw Exception(decoded['msg']?.toString() ?? 'recordInfo failed');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('recordInfo: missing data');
    }
    final state = data['state'] as String? ?? '';
    List<String>? urls;
    final resultJson = data['resultJson'] as String?;
    if (resultJson != null && resultJson.isNotEmpty) {
      try {
        final r = jsonDecode(resultJson) as Map<String, dynamic>;
        final raw = r['resultUrls'];
        if (raw is List) {
          urls = raw.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }
    final progress = data['progress'];
    final failRaw = data['failMsg'] as String?;
    final failMsg =
        failRaw != null && failRaw.trim().isNotEmpty ? failRaw : null;
    return CystoKESoraTaskStatus(
      state: state,
      resultUrls: urls,
      failMsg: failMsg,
      progress: progress is int ? progress : int.tryParse('$progress'),
    );
  }

  static Future<String?> pollUntilVideoUrl(
    String taskId, {
    void Function(String state, int? progress)? onUpdate,
    int maxAttempts = 200,
    Duration interval = const Duration(seconds: 3),
  }) async {
    for (var i = 0; i < maxAttempts; i++) {
      await Future<void>.delayed(interval);
      final status = await getRecordInfo(taskId);
      onUpdate?.call(status.state, status.progress);
      if (status.state == 'success' &&
          status.resultUrls != null &&
          status.resultUrls!.isNotEmpty) {
        return status.resultUrls!.first;
      }
      if (status.state == 'fail') {
        throw Exception(status.failMsg ?? 'Video generation failed');
      }
    }
    return null;
  }
}
