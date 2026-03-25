import 'dart:io';

import 'package:flutter/material.dart';
import '../widgets/bubble_background.dart';
import 'package:image_picker/image_picker.dart';
import '../models/discover_bot.dart';
import '../services/bot_avatar_service.dart';
import '../services/discover_bot_service.dart';
import '../services/follow_state_service.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

class BotProfilePage extends StatefulWidget {
  const BotProfilePage({super.key, required this.bot});

  final DiscoverBot bot;

  @override
  State<BotProfilePage> createState() => _BotProfilePageState();
}

class _BotProfilePageState extends State<BotProfilePage> {
  late DiscoverBot _bot;
  bool _isFollowing = false;
  String? _customAvatarPath;

  @override
  void initState() {
    super.initState();
    _bot = DiscoverBotService.mergeWithLatest(widget.bot);
    _isFollowing = FollowStateService.isFollowing(widget.bot.id);
    _loadCustomAvatar();
    FollowStateService.addListener(_onFollowStateChanged);
  }

  @override
  void dispose() {
    FollowStateService.removeListener(_onFollowStateChanged);
    super.dispose();
  }

  void _onFollowStateChanged(String botId, int followersDelta) {
    if (botId != widget.bot.id) return;
    if (mounted) {
      setState(() {
        _isFollowing = FollowStateService.isFollowing(widget.bot.id);
      });
    }
  }

  Future<void> _loadCustomAvatar() async {
    final p = await BotAvatarService.getCustomAvatarPath(_bot.id);
    if (mounted) setState(() => _customAvatarPath = p);
  }

  void _onFollowTap() {
    setState(() {
      final willFollow = !_isFollowing;
      _isFollowing = willFollow;
      FollowStateService.setFollowing(widget.bot.id, willFollow);
      _bot = _bot.copyWith(
        followingCount: (willFollow ? _bot.followingCount + 1 : _bot.followingCount - 1).clamp(0, 999999),
        followersCount: (willFollow ? _bot.followersCount + 1 : _bot.followersCount - 1).clamp(0, 999999),
      );
    });
  }

  void _popWithResult() {
    Navigator.of(context).pop(_bot);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _popWithResult();
      },
      child: Scaffold(
        backgroundColor: kBubbleBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: _popWithResult,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickAvatarImage,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: _buildAvatarDisplay(100),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _kThemeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _bot.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_formatIpLocation(_bot.ipLocation).isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'IP: ${_formatIpLocation(_bot.ipLocation)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              _genderText(_bot.gender),
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF616161),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem('Followers', _bot.followersCount),
                const SizedBox(width: 32),
                _buildStatItem('Likes', _bot.totalLikesCount),
                const SizedBox(width: 32),
                _buildStatItem('Collections', _bot.collectionsCount),
              ],
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _onFollowTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: _isFollowing
                        ? Colors.grey.shade300
                        : _kThemeColor,
                    foregroundColor: _isFollowing
                        ? Colors.grey.shade600
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    _isFollowing ? 'Following' : 'Follow',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  String _formatIpLocation(String ipLocation) {
    if (ipLocation.isEmpty) return '';
    final parts = ipLocation.split(' · ');
    return parts.length > 1 ? parts.last.trim() : ipLocation;
  }

  Future<void> _pickAvatarImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image == null || !mounted) return;
    try {
      await BotAvatarService.saveCustomAvatar(_bot.id, image.path);
      if (mounted) await _loadCustomAvatar();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update avatar')),
        );
      }
    }
  }

  Widget _buildAvatarDisplay(double size) {
    if (_customAvatarPath != null) {
      final file = File(_customAvatarPath!);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(
            file,
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
    }
    return _buildAvatar(_bot.avatarUrl, size);
  }

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

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          _formatCount(count),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatCount(int n) {
    if (n >= 10000) {
      return '${(n / 10000).toStringAsFixed(1)}w';
    }
    return n.toString();
  }
}
