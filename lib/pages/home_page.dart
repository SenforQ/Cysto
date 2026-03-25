import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_image_page.dart';
import 'image_detail_page.dart';
import '../services/generated_images_service.dart';
import '../models/generated_image_item.dart';
import '../widgets/add_my_character_sheet.dart';
import '../widgets/character_image_display.dart';

const Color _kThemeColor = Color(0xFF00C5E8);
const String _kCystoHomeBgmPromptDoneKey = 'cysto_home_bgm_prompt_done_v1';
const String _kCystoHomeBgmUserAgreedKey = 'cysto_home_bgm_user_agreed_v1';
const String _kCystoHomeBgmAssetPath = 'assets/CystoBGMusic.mp3';

final List<GeneratedImageItem> _defaultSampleImages = [
  GeneratedImageItem(
    url: 'assets/example_character_ryo.png',
    tags: ['Cyber', 'Portrait'],
    gender: 'male',
    characterName: 'Ryo',
    personality:
        'Calm, decisive, and quietly witty; he reads situations fast and keeps his cool under neon lights',
    styleDescription:
        'Short neat black hair with a subtle blue sheen, steel-gray eyes, minimalist tech-casual jacket with dark cyan trim, calm half-smile. Neon city bokeh behind him, crisp rim light, polished modern anime portrait.',
  ),
  GeneratedImageItem(
    url: 'assets/example_character_ken.png',
    tags: ['Slice of life', 'Healing'],
    gender: 'male',
    characterName: 'Ken',
    personality:
        'Soft-spoken and patient; he listens without rushing you and answers with warmth and gentle honesty',
    styleDescription:
        'Messy dark brown hair, hazel eyes, kind expression in a cozy oatmeal knit sweater. Warm window light, blurred bookshelves, quiet afternoon mood in a healing slice-of-life anime look.',
  ),
  GeneratedImageItem(
    url: 'assets/example_character_sora.png',
    tags: ['Street', 'Vivid'],
    gender: 'male',
    characterName: 'Sora',
    personality:
        'High-energy and playful; he turns small moments into jokes and pulls you into better vibes by default',
    styleDescription:
        'Tousled golden-blond hair, bright blue eyes, easy grin, casual streetwear hoodie with headphones around his neck. Colorful mural softly blurred behind, punchy colors, lively contemporary anime portrait.',
  ),
];

const Map<String, String> _presetUrlToBotId = {
  'assets/example_character_ryo.png': '1',
  'assets/example_character_ken.png': '1',
  'assets/example_character_sora.png': '2',
};

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  List<GeneratedImageItem> _items = [];
  late final AnimationController _bgmRotateController;
  final AudioPlayer _bgmPlayer = AudioPlayer();
  StreamSubscription<bool>? _bgmPlayingSub;
  bool _bgmPromptDone = false;
  bool _bgmInfraReady = false;

  @override
  void initState() {
    super.initState();
    _bgmRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _loadImages();
    GeneratedImagesService.imageCountNotifier.addListener(_onImageCountChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapHomeBgm());
    });
  }

  @override
  void dispose() {
    GeneratedImagesService.imageCountNotifier.removeListener(_onImageCountChanged);
    _bgmPlayingSub?.cancel();
    _bgmRotateController.dispose();
    unawaited(_bgmPlayer.dispose());
    super.dispose();
  }

  void _onImageCountChanged() => _loadImages();

  Future<void> _loadImages() async {
    final list = await GeneratedImagesService.getItems();
    if (mounted) setState(() => _items = list);
  }

  Future<void> _bootstrapHomeBgm() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(_kCystoHomeBgmPromptDoneKey) ?? false;
    final agreed = prefs.getBool(_kCystoHomeBgmUserAgreedKey) ?? false;
    if (!mounted) {
      return;
    }
    setState(() {
      _bgmPromptDone = done;
    });
    if (agreed && done) {
      try {
        await _prepareBgmPlayer();
        if (mounted) {
          await _bgmPlayer.play();
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Background music could not be played.')),
          );
        }
      }
    }
    if (!mounted) {
      return;
    }
    if (!done) {
      await _showHomeBgmConsentDialog();
    }
  }

  Future<void> _prepareBgmPlayer() async {
    if (_bgmInfraReady) {
      return;
    }
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await _bgmPlayer.setLoopMode(LoopMode.one);
    await _bgmPlayer.setAsset(_kCystoHomeBgmAssetPath);
    _bgmPlayingSub = _bgmPlayer.playingStream.listen((playing) {
      if (!mounted) {
        return;
      }
      if (playing) {
        _bgmRotateController.repeat();
      } else {
        _bgmRotateController.stop();
        _bgmRotateController.reset();
      }
      setState(() {});
    });
    _bgmInfraReady = true;
  }

  Future<void> _toggleHomeBgm() async {
    try {
      await _prepareBgmPlayer();
      if (_bgmPlayer.playing) {
        await _bgmPlayer.pause();
      } else {
        await _bgmPlayer.play();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Background music could not be played.')),
        );
      }
    }
  }

  Future<void> _showHomeBgmConsentDialog() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Immersive background music'),
          content: const Text(
            'For a more immersive experience, we may play background music using background audio. If you agree, playback will start automatically and may continue while the app is in the background. You can pause or resume anytime with the circular button at the bottom right.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await prefs.setBool(_kCystoHomeBgmPromptDoneKey, true);
                await prefs.setBool(_kCystoHomeBgmUserAgreedKey, false);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (mounted) {
                  setState(() {
                    _bgmPromptDone = true;
                  });
                }
              },
              child: const Text('Decline'),
            ),
            FilledButton(
              onPressed: () async {
                await prefs.setBool(_kCystoHomeBgmPromptDoneKey, true);
                await prefs.setBool(_kCystoHomeBgmUserAgreedKey, true);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (mounted) {
                  setState(() {
                    _bgmPromptDone = true;
                  });
                }
                try {
                  await _prepareBgmPlayer();
                  if (mounted) {
                    await _bgmPlayer.play();
                  }
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Background music could not be played.')),
                    );
                  }
                }
              },
              child: const Text('Agree'),
            ),
          ],
        );
      },
    );
  }

  void _openCreateImage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CreateImagePage(),
      ),
    );
    _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.viewPaddingOf(context).bottom;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          RefreshIndicator(
            onRefresh: _loadImages,
            color: _kThemeColor,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create anime characters with AI',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCreateCard(),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Featured characters',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: _buildPresetCard(_defaultSampleImages[0]),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: _buildPresetCard(_defaultSampleImages[1]),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: _buildPresetCard(_defaultSampleImages[2]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My characters',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childCount: _items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final height = 160.0;
                        return GestureDetector(
                          onTap: () async {
                            await showAddMyCharacterSheet(context);
                          },
                          child: _buildAddCharacterCell(height),
                        );
                      }
                      final item = _items[index - 1];
                      final height = 160.0 + ((index - 1) % 3) * 40.0;
                      final botId = _presetUrlToBotId[item.url];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ImageDetailPage(
                                item: item,
                                botId: botId,
                              ),
                            ),
                          );
                        },
                        child: _buildImageCard(item, height),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 24 + 66 + MediaQuery.of(context).padding.bottom + (_bgmPromptDone ? 72 : 0),
                  ),
                ),
              ],
            ),
          ),
          if (_bgmPromptDone)
            Positioned(
              right: 16,
              bottom: 16 + bottomSafe,
              child: Material(
                color: Colors.black,
                shape: const CircleBorder(),
                elevation: 6,
                shadowColor: Colors.black45,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _toggleHomeBgm,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _bgmRotateController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _bgmRotateController.value * 6.283185307179586,
                            child: child,
                          );
                        },
                        child: const Icon(
                          Icons.music_note_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCreateCard() {
    return GestureDetector(
      onTap: _openCreateImage,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 210,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/create_image_hero_anime_bg.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 64,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              ColoredBox(
                color: Colors.black.withOpacity(0.45),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Create Start',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

  Widget _buildAddCharacterCell(double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _kThemeColor.withOpacity(0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kThemeColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_photo_alternate_outlined,
                size: 32,
                color: _kThemeColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add character',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color.lerp(_kThemeColor, Colors.black, 0.35)!,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Upload an image and add name, personality, and background',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.25,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetCard(GeneratedImageItem item) {
    final botId = _presetUrlToBotId[item.url];
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ImageDetailPage(
              item: item,
              botId: botId,
            ),
          ),
        );
      },
      child: _buildImageCard(item, 140),
    );
  }

  Widget _buildImageCard(GeneratedImageItem item, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CharacterImageDisplay(
              imageRef: item.url,
              fit: BoxFit.cover,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: item.tags.take(3).map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _kThemeColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              t,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    if (item.tags.isNotEmpty && (item.characterName.isNotEmpty || item.gender.isNotEmpty))
                      const SizedBox(height: 4),
                    if (item.characterName.isNotEmpty)
                      Text(
                        item.characterName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else if (item.gender.isNotEmpty)
                      Text(
                        item.gender == 'male' ? 'Male' : 'Female',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
