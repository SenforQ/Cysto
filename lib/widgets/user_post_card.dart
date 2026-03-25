import 'dart:io';

import 'package:flutter/material.dart';

import '../models/user_post.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

class UserPostCard extends StatelessWidget {
  const UserPostCard({
    super.key,
    required this.post,
    this.onImageTap,
    this.onAvatarTap,
    this.onDelete,
    this.onLikeChanged,
    this.onFavoriteChanged,
    this.onCommentTap,
  });

  final UserPost post;
  final VoidCallback? onImageTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onLikeChanged;
  final ValueChanged<bool>? onFavoriteChanged;
  final VoidCallback? onCommentTap;

  Widget _buildAvatar(String url, double size) {
    if (url.startsWith('assets/')) {
      return ClipOval(
        child: Image.asset(
          url,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => Icon(
            Icons.person,
            color: Colors.grey.shade600,
            size: size * 0.6,
          ),
        ),
      );
    }
    return Icon(Icons.person, color: Colors.grey, size: size * 0.6);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 15;
    const crossCount = 3;
    final cellSize = (cardWidth - 24 - 12) / crossCount;

    return Center(
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  onAvatarTap != null
                      ? GestureDetector(
                          onTap: onAvatarTap,
                          behavior: HitTestBehavior.opaque,
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.grey.shade200,
                            child: _buildAvatar(post.authorAvatarUrl, 44),
                          ),
                        )
                      : CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey.shade200,
                          child: _buildAvatar(post.authorAvatarUrl, 44),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (post.ipAddress.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            post.ipAddress,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 22,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (post.text.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  post.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (post.imagePaths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: GestureDetector(
                  onTap: onImageTap,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossCount,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1,
                      children: post.imagePaths.take(9).map((path) {
                        return Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onLikeChanged != null
                        ? () => onLikeChanged!(!post.isLiked)
                        : null,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 22,
                          color: post.isLiked ? Colors.red : Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: onCommentTap,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 22, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${post.comments}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onFavoriteChanged != null
                        ? () => onFavoriteChanged!(!post.isFavorited)
                        : null,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.isFavorited ? Icons.bookmark : Icons.bookmark_border,
                          size: 22,
                          color: post.isFavorited ? _kThemeColor : Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
