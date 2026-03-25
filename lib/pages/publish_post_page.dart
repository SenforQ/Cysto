import 'dart:io';

import 'package:flutter/material.dart';
import '../widgets/bubble_background.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_post.dart';
import '../services/user_posts_service.dart';
import '../widgets/location_picker_sheet.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

class PublishPostPage extends StatefulWidget {
  const PublishPostPage({super.key});

  @override
  State<PublishPostPage> createState() => _PublishPostPageState();
}

class _PublishPostPageState extends State<PublishPostPage> {
  final _textController = TextEditingController();
  final _locationController = TextEditingController();
  final List<String> _imagePaths = [];

  @override
  void dispose() {
    _textController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const LocationPickerSheet(),
    );
    if (result != null && mounted) {
      setState(() => _locationController.text = result);
    }
  }

  Future<void> _pickImage() async {
    if (_imagePaths.length >= 9) return;
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null || !mounted) return;
    try {
      final savedPath = await UserPostsService.copyImageToAppDir(xFile.path);
      if (mounted) setState(() => _imagePaths.add(savedPath));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() => _imagePaths.removeAt(index));
  }

  void _showImagePreview(String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenFileImageViewer(imagePath: path),
      ),
    );
  }

  Future<void> _publish() async {
    if (_imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }
    try {
      final post = UserPost(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        text: _textController.text.trim(),
        imagePaths: List.from(_imagePaths),
        ipAddress: _locationController.text.trim(),
        publishTime: DateTime.now(),
      );
      UserPostsService.addPost(post);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Publish failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBubbleBackgroundColor,
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          TextButton(
            onPressed: _imagePaths.isEmpty ? null : _publish,
            child: const Text(
              'Publish',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add images (max 9)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                const crossCount = 3;
                final cellSize = (constraints.maxWidth - 16) / crossCount;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...List.generate(
                      _imagePaths.length,
                      (i) => SizedBox(
                        width: cellSize,
                        height: cellSize,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            GestureDetector(
                              onTap: () => _showImagePreview(_imagePaths[i]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_imagePaths[i]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(i),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_imagePaths.length < 9)
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: cellSize,
                          height: cellSize,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: _kThemeColor),
                const SizedBox(width: 6),
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _openLocationPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 22, color: _kThemeColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _locationController.text.isEmpty
                            ? 'Tap to select location'
                            : _locationController.text,
                        style: TextStyle(
                          fontSize: 16,
                          color: _locationController.text.isEmpty
                              ? Colors.grey.shade600
                              : Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenFileImageViewer extends StatelessWidget {
  const _FullScreenFileImageViewer({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    size: 80,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
