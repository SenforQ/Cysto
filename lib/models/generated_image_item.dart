import '../services/local_character_image_store.dart';

abstract final class GeneratedImageEntrySource {
  static const String aiStudio = 'ai_studio';
  static const String manualCharacter = 'manual_character';
}

class GeneratedImageItem {
  final String url;
  final List<String> tags;
  final String gender;
  final String characterName;
  final String personality;
  final String styleDescription;

  final String entrySource;

  GeneratedImageItem({
    required this.url,
    this.tags = const [],
    this.gender = '',
    this.characterName = '',
    this.personality = '',
    this.styleDescription = '',
    this.entrySource = GeneratedImageEntrySource.aiStudio,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'tags': tags,
        'gender': gender,
        'characterName': characterName,
        'personality': personality,
        'styleDescription': styleDescription,
        'entrySource': entrySource,
      };

  factory GeneratedImageItem.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String? ?? '';
    final stored = json['entrySource'] as String?;
    final entrySource = stored ??
        (LocalCharacterImageStore.isLocalStored(url)
            ? GeneratedImageEntrySource.manualCharacter
            : GeneratedImageEntrySource.aiStudio);
    return GeneratedImageItem(
      url: url,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      gender: json['gender'] as String? ?? '',
      characterName: json['characterName'] as String? ?? '',
      personality: json['personality'] as String? ?? '',
      styleDescription: json['styleDescription'] as String? ?? '',
      entrySource: entrySource,
    );
  }
}
