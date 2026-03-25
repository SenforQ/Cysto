class DiscoverComment {
  final String avatarUrl;
  final String username;
  final String content;
  final String ipLocation;
  final DateTime? createdAt;

  const DiscoverComment({
    required this.avatarUrl,
    required this.username,
    required this.content,
    this.ipLocation = '',
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'avatarUrl': avatarUrl,
        'username': username,
        'content': content,
        'ipLocation': ipLocation,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory DiscoverComment.fromJson(Map<String, dynamic> json) =>
      DiscoverComment(
        avatarUrl: json['avatarUrl'] as String? ?? '',
        username: json['username'] as String? ?? '',
        content: json['content'] as String? ?? '',
        ipLocation: json['ipLocation'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
}
