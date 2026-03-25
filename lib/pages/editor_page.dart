import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../services/user_preferences.dart';
import '../services/user_stats_service.dart';
import '../widgets/bubble_background.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final _nicknameController = TextEditingController();
  final _signatureController = TextEditingController();
  String? _avatarRelativePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    UserStatsService.notifier.addListener(_onStatsChanged);
  }

  @override
  void dispose() {
    UserStatsService.notifier.removeListener(_onStatsChanged);
    _nicknameController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  void _onStatsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    final nickname = await UserPreferences.getNickname();
    final signature = await UserPreferences.getSignature();
    final avatarPath = await UserPreferences.getAvatarPath();
    if (mounted) {
      _nicknameController.text = nickname;
      _signatureController.text = signature;
      setState(() {
        _avatarRelativePath = avatarPath;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final image = await picker.pickImage(source: source);
    if (image == null || !mounted) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.png';
    final destFile = File(path.join(appDir.path, fileName));
    await File(image.path).copy(destFile.path);

    await UserPreferences.setAvatarPath(fileName);

    if (mounted) {
      setState(() => _avatarRelativePath = fileName);
    }
  }

  Future<File?> _getAvatarFile() async {
    if (_avatarRelativePath == null) return null;
    final appDir = await getApplicationDocumentsDirectory();
    final filePath = path.join(appDir.path, _avatarRelativePath!);
    final f = File(filePath);
    return f.existsSync() ? f : null;
  }

  Future<void> _save() async {
    await UserPreferences.setNickname(_nicknameController.text.trim());
    await UserPreferences.setSignature(_signatureController.text.trim());
    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: kBubbleBackgroundColor,
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const Center(child: CircularProgressIndicator(color: _kThemeColor)),
      );
    }

    return Scaffold(
      backgroundColor: kBubbleBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipOval(
                      child: FutureBuilder<File?>(
                        future: _getAvatarFile(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.file(
                              snapshot.data!,
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                            );
                          }
                          return Image.asset(
                            UserPreferences.defaultUserAvatar,
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => SizedBox(
                              width: 76,
                              height: 76,
                              child: Icon(
                                Icons.person,
                                size: 38,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _kThemeColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nickname',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: 'Enter nickname',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Signature',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _signatureController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter signature',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem('Following', UserStatsService.followingCount),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: _kThemeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
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
}
