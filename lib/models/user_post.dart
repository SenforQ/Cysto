class UserPost {
  final String id;
  final String text;
  final List<String> imagePaths;
  final String ipAddress;
  final DateTime publishTime;
  final String authorName;
  final String authorAvatarUrl;
  final int likes;
  final bool isLiked;
  final int comments;
  final bool isFavorited;
  final int favoriteCount;

  const UserPost({
    required this.id,
    required this.text,
    required this.imagePaths,
    required this.ipAddress,
    required this.publishTime,
    this.authorName = 'Me',
    this.authorAvatarUrl = 'assets/figure_1_female.png',
    this.likes = 0,
    this.isLiked = false,
    this.comments = 0,
    this.isFavorited = false,
    this.favoriteCount = 0,
  });

  UserPost copyWith({
    int? likes,
    bool? isLiked,
    int? comments,
    bool? isFavorited,
    int? favoriteCount,
  }) {
    return UserPost(
      id: id,
      text: text,
      imagePaths: imagePaths,
      ipAddress: ipAddress,
      publishTime: publishTime,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
      isFavorited: isFavorited ?? this.isFavorited,
      favoriteCount: favoriteCount ?? this.favoriteCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'imagePaths': imagePaths,
        'ipAddress': ipAddress,
        'publishTime': publishTime.toIso8601String(),
        'authorName': authorName,
        'authorAvatarUrl': authorAvatarUrl,
        'likes': likes,
        'isLiked': isLiked,
        'comments': comments,
        'isFavorited': isFavorited,
        'favoriteCount': favoriteCount,
      };

  factory UserPost.fromJson(Map<String, dynamic> json) {
    return UserPost(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      imagePaths: (json['imagePaths'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      ipAddress: json['ipAddress'] as String? ?? '',
      publishTime: DateTime.tryParse(json['publishTime'] as String? ?? '') ?? DateTime.now(),
      authorName: json['authorName'] as String? ?? 'Me',
      authorAvatarUrl: json['authorAvatarUrl'] as String? ?? 'assets/figure_1_female.png',
      likes: json['likes'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      comments: json['comments'] as int? ?? 0,
      isFavorited: json['isFavorited'] as bool? ?? false,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
    );
  }
}
