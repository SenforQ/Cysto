import 'package:flutter/material.dart';
import '../widgets/bubble_background.dart';
import '../widgets/character_image_display.dart';

import '../models/generated_image_item.dart';
import 'character_ai_chat_page.dart';
import 'full_screen_image_page.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

class ImageDetailPage extends StatelessWidget {
  const ImageDetailPage({
    super.key,
    required this.item,
    this.botId,
  });

  final GeneratedImageItem item;
  final String? botId;

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width - 20;
    return Scaffold(
      backgroundColor: kBubbleBackgroundColor,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                  if (item.characterName.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      item.characterName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FullScreenImagePage(imageUrl: item.url),
                    fullscreenDialog: true,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: imageWidth,
                    height: _kImageHeight,
                    child: CharacterImageDisplay(
                      imageRef: item.url,
                      fit: BoxFit.cover,
                      width: imageWidth,
                      height: _kImageHeight,
                    ),
                  ),
                ),
              ),
            ),
            _buildContentSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.characterName.isNotEmpty) ...[
            _buildSectionLabel('Character'),
            const SizedBox(height: 6),
            Text(
              item.characterName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (item.personality.isNotEmpty) ...[
            _buildSectionLabel('Personality'),
            const SizedBox(height: 6),
            Text(
              item.personality,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (item.tags.isNotEmpty) ...[
            _buildSectionLabel('Style Tags'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.tags.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kThemeColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    t,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
          if (item.gender.isNotEmpty) ...[
            _buildSectionLabel('Gender'),
            const SizedBox(height: 6),
            Text(
              item.gender == 'male' ? 'Male' : 'Female',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF616161),
              ),
            ),
            const SizedBox(height: 20),
          ],
          _buildSectionLabel('Background'),
          const SizedBox(height: 6),
          Text(
            item.styleDescription.isNotEmpty
                ? item.styleDescription
                : 'This character has not prepared a description yet.',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: item.styleDescription.isNotEmpty
                  ? const Color(0xFF424242)
                  : const Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CharacterAiChatPage(item: item),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat with character'),
              style: FilledButton.styleFrom(
                backgroundColor: _kThemeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF757575),
      ),
    );
  }

  static const double _kImageHeight = 320;
}
