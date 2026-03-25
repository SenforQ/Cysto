class MagicVideoHistoryEntry {
  MagicVideoHistoryEntry({
    required this.taskId,
    required this.prompt,
    required this.firstFrameImageUrl,
    required this.state,
    this.resultVideoUrl,
    this.progress,
    this.failMsg,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  final String taskId;
  final String prompt;
  final String firstFrameImageUrl;
  final String state;
  final String? resultVideoUrl;
  final int? progress;
  final String? failMsg;
  final int createdAtMs;
  final int updatedAtMs;

  bool get isTerminal {
    return state == 'success' ||
        state == 'fail' ||
        state == 'timeout' ||
        state == 'error';
  }

  MagicVideoHistoryEntry copyWith({
    String? taskId,
    String? prompt,
    String? firstFrameImageUrl,
    String? state,
    String? resultVideoUrl,
    int? progress,
    String? failMsg,
    int? createdAtMs,
    int? updatedAtMs,
    bool clearResultVideoUrl = false,
    bool clearProgress = false,
    bool clearFailMsg = false,
  }) {
    return MagicVideoHistoryEntry(
      taskId: taskId ?? this.taskId,
      prompt: prompt ?? this.prompt,
      firstFrameImageUrl: firstFrameImageUrl ?? this.firstFrameImageUrl,
      state: state ?? this.state,
      resultVideoUrl: clearResultVideoUrl
          ? null
          : (resultVideoUrl ?? this.resultVideoUrl),
      progress: clearProgress ? null : (progress ?? this.progress),
      failMsg: clearFailMsg ? null : (failMsg ?? this.failMsg),
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'prompt': prompt,
        'firstFrameImageUrl': firstFrameImageUrl,
        'state': state,
        'resultVideoUrl': resultVideoUrl,
        'progress': progress,
        'failMsg': failMsg,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
      };

  factory MagicVideoHistoryEntry.fromJson(Map<String, dynamic> json) {
    return MagicVideoHistoryEntry(
      taskId: json['taskId'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      firstFrameImageUrl: json['firstFrameImageUrl'] as String? ?? '',
      state: json['state'] as String? ?? 'waiting',
      resultVideoUrl: json['resultVideoUrl'] as String?,
      progress: json['progress'] as int?,
      failMsg: json['failMsg'] as String?,
      createdAtMs: json['createdAtMs'] as int? ?? 0,
      updatedAtMs: json['updatedAtMs'] as int? ?? 0,
    );
  }
}
