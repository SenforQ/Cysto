import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../data/magic_prompt_presets.dart';
import '../models/generated_image_item.dart';
import '../models/magic_video_history_entry.dart';
import '../services/generated_images_service.dart';
import '../services/kie_magic_video_service.dart';
import '../services/local_character_image_store.dart';
import '../services/magic_video_history_service.dart';
import '../services/wallet_service.dart';
import '../widgets/character_image_display.dart';
import '../widgets/coin_rules_dialog.dart';
import '../widgets/magic_video_compliance_dialog.dart';
import 'magic_video_history_page.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage> {
  final _promptController = TextEditingController();
  final _random = Random();

  List<GeneratedImageItem> _myCharacters = [];
  XFile? _pickedFile;
  Uint8List? _pickedPreviewBytes;
  int? _selectedCharacterIndex;
  String _aspectRatio = 'landscape';
  String _nFrames = '10';

  bool _busy = false;
  String _pollStatus = '';
  int? _pollProgress;
  String? _resultVideoUrl;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _loadMyCharacters();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadMyCharacters() async {
    final list = await GeneratedImagesService.getItems();
    if (mounted) setState(() => _myCharacters = list);
  }

  void refresh() {
    _loadMyCharacters();
  }

  Future<void> _pickFromAlbum() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (x == null || !mounted) return;
    final bytes = await x.readAsBytes();
    setState(() {
      _pickedFile = x;
      _pickedPreviewBytes = bytes;
      _selectedCharacterIndex = null;
    });
  }

  void _selectCharacter(int index) {
    setState(() {
      _selectedCharacterIndex = index;
      _pickedFile = null;
      _pickedPreviewBytes = null;
    });
  }

  GeneratedImageItem? get _selectedCharacter {
    final i = _selectedCharacterIndex;
    if (i == null || i < 0 || i >= _myCharacters.length) return null;
    return _myCharacters[i];
  }

  Future<String?> _resolvePublicImageUrl() async {
    if (_pickedFile != null && _pickedPreviewBytes != null) {
      return KieMagicVideoService.uploadBase64Image(
        _pickedPreviewBytes!,
        fileName:
            'magic_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }
    final item = _selectedCharacter;
    if (item == null) return null;
    final url = item.url;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('assets/')) {
      final data = await rootBundle.load(url);
      return KieMagicVideoService.uploadBase64Image(
        data.buffer.asUint8List(),
        fileName: 'magic_asset_${DateTime.now().millisecondsSinceEpoch}.png',
      );
    }
    if (LocalCharacterImageStore.isLocalStored(url)) {
      final f = await LocalCharacterImageStore.fileForUrl(url);
      if (f == null) return null;
      final bytes = await f.readAsBytes();
      return KieMagicVideoService.uploadBase64Image(
        bytes,
        fileName: 'magic_local_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }
    return null;
  }

  Future<void> _disposeVideo() async {
    await _videoController?.dispose();
    _videoController = null;
  }

  void _fillRandomPrompt() {
    setState(() {
      _promptController.text = randomMagicMotionPrompt(_random);
      _promptController.selection = TextSelection.collapsed(
        offset: _promptController.text.length,
      );
    });
  }

  Future<void> _playResultVideo(String url) async {
    await _disposeVideo();
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    await c.initialize();
    await c.setLooping(true);
    await c.play();
    if (mounted) {
      setState(() => _videoController = c);
    } else {
      await c.dispose();
    }
  }

  Future<void> _generate() async {
    final prompt = _promptController.text.trim();
    if (prompt.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a motion description, or tap Random idea to generate one.',
          ),
        ),
      );
      return;
    }
    if (_pickedFile == null && _selectedCharacter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pick a photo from your library or a character image below.',
          ),
        ),
      );
      return;
    }

    final accepted = await showMagicVideoComplianceDialog(context);
    if (!accepted || !mounted) return;

    await WalletService.load();
    if (!mounted) return;
    if (WalletService.coinNotifier.value < WalletService.costMagicVideoCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Not enough coins: video generation costs '
            '${WalletService.costMagicVideoCoins} Coins. You have '
            '${WalletService.coinNotifier.value}. Open Profile → Wallet to top up.',
          ),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _pollStatus = 'Preparing image…';
      _pollProgress = null;
      _resultVideoUrl = null;
    });
    await _disposeVideo();

    String? taskId;
    try {
      final imageUrl = await _resolvePublicImageUrl();
      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception(
          'Could not get a usable image URL. Try again or use another image.',
        );
      }

      setState(() => _pollStatus = 'Creating image-to-video task…');
      taskId = await KieMagicVideoService.createSoraImageToVideoTask(
        prompt: prompt,
        imageUrls: [imageUrl],
        aspectRatio: _aspectRatio,
        nFrames: _nFrames,
        removeWatermark: true,
        uploadMethod: 's3',
      );
      if (taskId == null || taskId.isEmpty) {
        throw Exception('No taskId returned');
      }

      final tid = taskId;
      final now = DateTime.now().millisecondsSinceEpoch;
      await MagicVideoHistoryService.upsertEntry(
        MagicVideoHistoryEntry(
          taskId: tid,
          prompt: prompt,
          firstFrameImageUrl: imageUrl,
          state: 'submitted',
          createdAtMs: now,
          updatedAtMs: now,
        ),
      );

      final videoUrl = await KieMagicVideoService.pollUntilVideoUrl(
        tid,
        onUpdate: (state, progress) {
          if (mounted) {
            setState(() {
              _pollStatus = state;
              _pollProgress = progress;
            });
          }
          unawaited(
            MagicVideoHistoryService.updateByTaskId(
              tid,
              state: state,
              replaceProgress: true,
              progress: progress,
            ),
          );
        },
      );

      if (!mounted) return;
      if (videoUrl == null || videoUrl.isEmpty) {
        await MagicVideoHistoryService.updateByTaskId(
          tid,
          state: 'timeout',
          replaceFailMsg: true,
          failMsg:
              'Generation timed out. Pull to refresh in Generation history.',
          clearProgress: true,
        );
        throw Exception(
          'Generation timed out. Try again with a better network connection.',
        );
      }
      await MagicVideoHistoryService.updateByTaskId(
        tid,
        state: 'success',
        replaceResultVideoUrl: true,
        resultVideoUrl: videoUrl,
        clearProgress: true,
      );
      await WalletService.trySpendCoins(WalletService.costMagicVideoCoins);
      setState(() {
        _resultVideoUrl = videoUrl;
        _busy = false;
        _pollStatus = 'Done';
      });
      await _playResultVideo(videoUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video generated')),
        );
      }
    } catch (e) {
      if (taskId != null) {
        await MagicVideoHistoryService.updateByTaskId(
          taskId,
          state: 'fail',
          replaceFailMsg: true,
          failMsg: e.toString(),
          clearProgress: true,
        );
      }
      if (mounted) {
        setState(() {
          _busy = false;
          _pollStatus = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: const Text(
          'Magic',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'About coins',
            onPressed: () => showCoinRulesDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Generation history',
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const MagicVideoHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _kThemeColor,
        onRefresh: _loadMyCharacters,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            24 + 66 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Image to video',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color.lerp(_kThemeColor, Colors.black, 0.45)!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Turn your anime-style character art into short motion clips using Kie AI Sora2 image-to-video.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'First frame',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 10),
              AspectRatio(
                aspectRatio: 1,
                child: Material(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _busy ? null : _pickFromAlbum,
                    child: _buildImagePreview(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap above to pick from Photos, or select one of your characters below.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'First-frame images are used only as references for video generation and are processed in the cloud; they are deleted after about 3 days. Read and accept the User Agreement before generating.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'My characters (quick pick)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 96,
                child: _myCharacters.isEmpty
                    ? Center(
                        child: Text(
                          'No saved character images yet. Create or add one from Home.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _myCharacters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final item = _myCharacters[i];
                          final selected = _selectedCharacterIndex == i;
                          return GestureDetector(
                            onTap: _busy ? null : () => _selectCharacter(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 96,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? _kThemeColor
                                      : Colors.grey.shade300,
                                  width: selected ? 2.5 : 1,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: CharacterImageDisplay(
                                imageRef: item.url,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Motion description (prompt)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _busy ? null : _fillRandomPrompt,
                    icon: const Icon(Icons.casino_outlined, size: 18),
                    label: const Text('Random idea'),
                    style: TextButton.styleFrom(foregroundColor: _kThemeColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _promptController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Tap Random idea if empty, or describe motion: hair in the wind, slow blink, smile, gentle camera push-in…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _aspectRatio,
                      decoration: InputDecoration(
                        labelText: 'Aspect ratio',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'landscape',
                          child: Text('Landscape'),
                        ),
                        DropdownMenuItem(
                          value: 'portrait',
                          child: Text('Portrait'),
                        ),
                      ],
                      onChanged: _busy
                          ? null
                          : (v) {
                              if (v != null) setState(() => _aspectRatio = v);
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _nFrames,
                      decoration: InputDecoration(
                        labelText: 'Frames',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '10',
                          child: Text('10 frames'),
                        ),
                        DropdownMenuItem(
                          value: '15',
                          child: Text('15 frames'),
                        ),
                      ],
                      onChanged: _busy
                          ? null
                          : (v) {
                              if (v != null) setState(() => _nFrames = v);
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _generate,
                style: FilledButton.styleFrom(
                  backgroundColor: _kThemeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Generate video'),
              ),
              if (_busy) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _pollProgress != null
                      ? _pollProgress! / 100.0
                      : null,
                  color: _kThemeColor,
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 8),
                Text(
                  _pollStatus.isEmpty ? 'Working…' : _pollStatus,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
              if (_resultVideoUrl != null && _videoController != null) ...[
                const SizedBox(height: 28),
                Text(
                  'Result',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio:
                        _videoController!.value.isInitialized
                            ? _videoController!.value.aspectRatio
                            : 16 / 9,
                    child: ValueListenableBuilder<VideoPlayerValue>(
                      valueListenable: _videoController!,
                      builder: (context, v, __) {
                        return GestureDetector(
                          onTap: () {
                            if (v.isPlaying) {
                              _videoController!.pause();
                            } else {
                              _videoController!.play();
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(_videoController!),
                              if (!v.isPlaying)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_pickedPreviewBytes != null) {
      return Image.memory(
        _pickedPreviewBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (_selectedCharacter != null) {
      return CharacterImageDisplay(
        imageRef: _selectedCharacter!.url,
        fit: BoxFit.cover,
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 48, color: Colors.grey.shade500),
          const SizedBox(height: 8),
          Text(
            'Tap to choose an image',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
