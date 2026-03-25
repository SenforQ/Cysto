class CustomChatbot {
  final String id;
  final String avatarUrl;
  final String name;
  final String type;
  final List<String> presetQuestions;
  final DateTime createdAt;

  static const Map<String, String> _typeToEnglish = {
    '\u5b66\u4e60\u7c7b': 'Study',
    '\u8fd0\u52a8\u7c7b': 'Sports',
    '\u52a8\u6f2b\u7c7b': 'Anime',
    '\u6e38\u620f\u7c7b': 'Games',
    '\u97f3\u4e50\u7c7b': 'Music',
    '\u7f8e\u98df\u7c7b': 'Food',
    '\u65c5\u884c\u7c7b': 'Travel',
    '\u79d1\u6280\u7c7b': 'Tech',
    '\u5a31\u4e50\u7c7b': 'Entertainment',
    '\u60c5\u611f\u7c7b': 'Emotions',
  };

  static const Map<String, String> _presetQuestionToEnglish = {
    '\u4eca\u5929\u6709\u4ec0\u4e48\u6709\u8da3\u7684\u4e8b?': 'Anything interesting today?',
    '\u5468\u672b\u6709\u4ec0\u4e48\u8ba1\u5212?': 'What are the plans for the weekend?',
    '\u4f60\u6709\u4ec0\u4e48\u7231\u597d?': 'What are your hobbies?',
    '\u80fd\u548c\u6211\u804a\u804a\u5929\u5417?': 'Can you chat with me?',
    '\u63a8\u8350\u4e00\u672c\u4e66': 'Recommend a book',
    '\u6700\u8fd1\u5728\u5b66\u4ec0\u4e48?': 'What are you learning lately?',
    '\u6709\u4ec0\u4e48\u5b66\u4e60\u5efa\u8bae?': 'Any study tips?',
    '\u5982\u4f55\u63d0\u9ad8\u5b66\u4e60\u6548\u7387?': 'How to improve learning efficiency?',
    '\u6709\u4ec0\u4e48\u8fd0\u52a8\u63a8\u8350?': 'Any sports recommendations?',
    '\u63a8\u8350\u4e00\u90e8\u52a8\u6f2b': 'Recommend an anime',
    '\u6709\u4ec0\u4e48\u52a8\u6f2b\u63a8\u8350?': 'Any anime recommendations?',
    '\u4f60\u559c\u6b22\u4ec0\u4e48\u7c7b\u578b\u7684\u52a8\u6f2b?': 'What type of anime do you like?',
    '\u6709\u4ec0\u4e48\u6e38\u620f\u63a8\u8350?': 'Any game recommendations?',
    '\u4f60\u559c\u6b22\u4ec0\u4e48\u6e38\u620f?': 'What games do you like?',
    '\u6709\u4ec0\u4e48\u97f3\u4e50\u63a8\u8350?': 'Any music recommendations?',
    '\u4f60\u559c\u6b22\u4ec0\u4e48\u7c7b\u578b\u7684\u97f3\u4e50?': 'What type of music do you like?',
    '\u6709\u4ec0\u4e48\u7f8e\u98df\u63a8\u8350?': 'Any food recommendations?',
    '\u4f60\u559c\u6b22\u5403\u4ec0\u4e48?': 'What do you like to eat?',
    '\u6709\u4ec0\u4e48\u65c5\u884c\u63a8\u8350?': 'Any travel recommendations?',
    '\u4f60\u559c\u6b22\u53bb\u54ea\u91cc\u65c5\u884c?': 'Where do you like to travel?',
    '\u6700\u8fd1\u6709\u4ec0\u4e48\u79d1\u6280\u65b0\u95fb?': 'Any tech news lately?',
    '\u6709\u4ec0\u4e48\u79d1\u6280\u4ea7\u54c1\u63a8\u8350?': 'Any tech product recommendations?',
    '\u6709\u4ec0\u4e48\u5a31\u4e50\u63a8\u8350?': 'Any entertainment recommendations?',
    '\u5982\u4f55\u6539\u5584\u5fc3\u60c5?': 'How to improve my mood?',
  };

  String get displayType => _typeToEnglish[type] ?? type;

  List<String> get displayPresetQuestions => presetQuestions
      .map((q) => _presetQuestionToEnglish[q] ?? q)
      .toList();

  const CustomChatbot({
    required this.id,
    required this.avatarUrl,
    required this.name,
    required this.type,
    this.presetQuestions = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'avatarUrl': avatarUrl,
        'name': name,
        'type': type,
        'presetQuestions': presetQuestions,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CustomChatbot.fromJson(Map<String, dynamic> json) => CustomChatbot(
        id: json['id'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String? ?? '',
        name: json['name'] as String? ?? '',
        type: json['type'] as String? ?? '',
        presetQuestions: (json['presetQuestions'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
