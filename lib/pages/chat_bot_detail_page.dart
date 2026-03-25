import 'dart:io';

import 'package:flutter/material.dart';
import '../widgets/bubble_background.dart';
import '../models/discover_bot.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

class ChatBotDetailPage extends StatelessWidget {
  const ChatBotDetailPage({
    super.key,
    required this.bot,
    this.tags = const [],
    this.styleDescription,
  });

  final DiscoverBot bot;
  final List<String> tags;
  final String? styleDescription;

  Widget _buildAvatar(String avatarUrl, double size) {
    if (avatarUrl.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
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
    if (avatarUrl.startsWith('assets/')) {
      return ClipOval(
        child: Image.asset(
          avatarUrl,
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

  String _genderText(BotGender g) {
    switch (g) {
      case BotGender.male:
        return 'Male';
      case BotGender.female:
        return 'Female';
      case BotGender.unknown:
        return 'Unknown';
    }
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desc = styleDescription?.trim().isNotEmpty == true
        ? styleDescription!
        : 'This character has not prepared a description yet.';

    return Scaffold(
      backgroundColor: kBubbleBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        leadingWidth: 56,
        title: Row(
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: _buildAvatar(bot.avatarUrl, 36),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                bot.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Character Name'),
            const SizedBox(height: 6),
            Text(
              bot.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionLabel('Style Tags'),
            const SizedBox(height: 8),
            tags.isEmpty
                ? Text(
                    'None',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _kThemeColor.withValues(alpha: 0.25),
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
            _buildSectionLabel('Gender'),
            const SizedBox(height: 6),
            Text(
              _genderText(bot.gender),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF616161),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionLabel('Style Description'),
            const SizedBox(height: 6),
            Text(
              desc,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: desc == 'This character has not prepared a description yet.'
                    ? Colors.grey.shade600
                    : const Color(0xFF424242),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
