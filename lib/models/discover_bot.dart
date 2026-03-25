import 'discover_comment.dart';

enum DiscoverContentType { image, video }

enum BotGender { male, female, unknown }

class DiscoverBot {
  final String id;
  final String avatarUrl;
  final String name;
  final String location;
  final DiscoverContentType contentType;
  final String contentUrl;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isFavorited;
  final DateTime publishTime;
  final String ipLocation;
  final List<DiscoverComment> commentList;
  final int followingCount;
  final int followersCount;
  final int totalLikesCount;
  final int collectionsCount;
  final BotGender gender;
  final String bio;
  final List<String> galleryImages;
  final List<String> galleryVideos;

  const DiscoverBot({
    required this.id,
    required this.avatarUrl,
    required this.name,
    required this.location,
    required this.contentType,
    required this.contentUrl,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.isFavorited = false,
    required this.publishTime,
    required this.ipLocation,
    this.commentList = const [],
    this.followingCount = 0,
    this.followersCount = 0,
    this.totalLikesCount = 0,
    this.collectionsCount = 0,
    this.gender = BotGender.unknown,
    this.bio = '',
    this.galleryImages = const [],
    this.galleryVideos = const [],
  });

  DiscoverBot copyWith({
    int? likes,
    int? comments,
    bool? isLiked,
    bool? isFavorited,
    int? followingCount,
    int? followersCount,
    int? totalLikesCount,
    int? collectionsCount,
    String? bio,
    List<String>? galleryImages,
    List<String>? galleryVideos,
  }) {
    return DiscoverBot(
      id: id,
      avatarUrl: avatarUrl,
      name: name,
      location: location,
      contentType: contentType,
      contentUrl: contentUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isFavorited: isFavorited ?? this.isFavorited,
      publishTime: publishTime,
      ipLocation: ipLocation,
      commentList: commentList,
      followingCount: followingCount ?? this.followingCount,
      followersCount: followersCount ?? this.followersCount,
      totalLikesCount: totalLikesCount ?? this.totalLikesCount,
      collectionsCount: collectionsCount ?? this.collectionsCount,
      gender: gender,
      bio: bio ?? this.bio,
      galleryImages: galleryImages ?? this.galleryImages,
      galleryVideos: galleryVideos ?? this.galleryVideos,
    );
  }
}
