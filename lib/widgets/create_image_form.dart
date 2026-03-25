import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/generated_images_service.dart';
import '../services/kie_ai_service.dart';
import '../services/wallet_service.dart';
import 'create_image_compliance_dialog.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

const List<String> _personalityPresets = [
  'Cheerful and energetic, loves adventure',
  'Calm and mysterious, with a gentle smile',
  'Bold and confident, never gives up',
  'Shy but kind-hearted, cares for friends',
  'Cool and aloof, hides warmth inside',
  'Playful and mischievous, loves pranks',
  'Serious and dedicated, strives for excellence',
  'Optimistic dreamer, believes in magic',
  'Quiet and observant, notices small details',
  'Passionate and fiery, fights for justice',
];

const List<String> _descriptionPresets = [
  'A young anime character with flowing hair and bright eyes, standing in cherry blossom petals',
  'Cute anime girl with twin tails, wearing a school uniform, smiling warmly',
  'Cool anime boy with spiky hair, wearing a jacket, confident pose',
  'Fantasy anime character with magical aura, elegant and graceful',
  'Cyberpunk style anime character with neon accents, futuristic outfit',
  'Gentle anime character in soft pastel colors, peaceful expression',
  'Action anime hero with dynamic pose, wind blowing through hair',
  'Romantic anime character in moonlight, dreamy atmosphere',
  'Mysterious anime figure in dark clothing, intriguing expression',
  'Adventure-seeking anime character with backpack, ready for journey',
];

const List<String> _styleTags = [
  'Moe', 'Action', 'Healing', 'Fantasy', 'School', 'Mecha', 'Ancient',
];

const String _kDefaultHeroBannerAsset = 'assets/create_image_hero_banner.png';

class _MaleCharacterPreset {
  const _MaleCharacterPreset({
    required this.name,
    required this.personality,
    required this.styleDescription,
    required this.avatarAsset,
    required this.tagIndices,
  });

  final String name;
  final String personality;
  final String styleDescription;
  final String avatarAsset;
  final List<int> tagIndices;
}

const _MaleCharacterPreset _malePresetLeo = _MaleCharacterPreset(
  name: 'Leo Hanami',
  personality:
      'Cheerful track club captain with a sunny attitude; loyal to teammates and quick to encourage others.',
  styleDescription:
      'Anime male teenager with warm-toned hair, athletic build, school sports jacket, bright stadium afternoon light, energetic friendly smile, clean linework.',
  avatarAsset: 'assets/create_preset_male_01.png',
  tagIndices: [4, 1],
);

const _MaleCharacterPreset _malePresetKael = _MaleCharacterPreset(
  name: 'Kael Voss',
  personality:
      'Calm analyst who speaks softly and notices every detail; reserved in public but deeply dependable.',
  styleDescription:
      'Anime young man with short silver hair and ice-blue eyes, black fitted top, cool neutral studio background, composed subtle smile, polished shading.',
  avatarAsset: 'assets/create_preset_male_02.png',
  tagIndices: [2, 3],
);

const _MaleCharacterPreset _malePresetRen = _MaleCharacterPreset(
  name: 'Ren Sato',
  personality:
      'Passionate street performer with big emotions; creative, expressive, and a little dramatic in the best way.',
  styleDescription:
      'Anime male with styled dark hair, layered casual streetwear, urban dusk with soft neon bokeh, soulful eyes, dynamic but grounded pose.',
  avatarAsset: 'assets/create_preset_male_03.png',
  tagIndices: [0, 2],
);

const _MaleCharacterPreset _malePresetDarius = _MaleCharacterPreset(
  name: 'Darius Cole',
  personality:
      'Stoic protector with quiet strength; few words, unshakable focus, and a surprisingly gentle sense of duty.',
  styleDescription:
      'Anime male with sharp features, tactical leather-accent outfit, dramatic rim light, intense focused gaze, cinematic contrast.',
  avatarAsset: 'assets/create_preset_male_04.png',
  tagIndices: [1, 6],
);

class CreateImageForm extends StatefulWidget {
  const CreateImageForm({
    super.key,
    this.bannerImagePath,
    this.onGenerated,
  });

  final String? bannerImagePath;
  final VoidCallback? onGenerated;

  @override
  State<CreateImageForm> createState() => _CreateImageFormState();
}

class _CreateImageFormState extends State<CreateImageForm> {
  final _titleController = TextEditingController();
  final _personalityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _random = Random();

  final List<bool> _selectedTags = List.filled(7, false);
  String _gender = 'male';

  bool _isGenerating = false;
  String? _generatedImageUrl;

  @override
  void dispose() {
    _titleController.dispose();
    _personalityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _randomPersonality() {
    _personalityController.text =
        _personalityPresets[_random.nextInt(_personalityPresets.length)];
  }

  void _randomDescription() {
    _descriptionController.text =
        _descriptionPresets[_random.nextInt(_descriptionPresets.length)];
  }

  void _applyMalePreset(_MaleCharacterPreset preset) {
    setState(() {
      _titleController.text = preset.name;
      _personalityController.text = preset.personality;
      _descriptionController.text = preset.styleDescription;
      _gender = 'male';
      for (var i = 0; i < _selectedTags.length; i++) {
        _selectedTags[i] = false;
      }
      for (final i in preset.tagIndices) {
        if (i >= 0 && i < _selectedTags.length) {
          _selectedTags[i] = true;
        }
      }
    });
  }

  Future<void> _pasteDescription() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _descriptionController.text = data.text!;
    }
  }

  String _buildPrompt() {
    final parts = <String>[];

    parts.add(_gender == 'male'
        ? 'Anime style, male character, boy'
        : 'Anime style, female character, girl');

    if (_personalityController.text.trim().isNotEmpty) {
      parts.add('Personality: ${_personalityController.text.trim()}');
    }

    final selected = <String>[];
    for (int i = 0; i < _styleTags.length; i++) {
      if (_selectedTags[i]) selected.add(_styleTags[i]);
    }
    if (selected.isNotEmpty) {
      parts.add('Style: ${selected.join(", ")}');
    }

    if (_descriptionController.text.trim().isNotEmpty) {
      parts.add(_descriptionController.text.trim());
    }

    return parts.join('. ');
  }

  Future<void> _generateImage() async {
    final prompt = _buildPrompt();
    if (prompt.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in character personality or description'),
        ),
      );
      return;
    }

    final accepted = await showCreateImageComplianceDialog(context);
    if (!accepted || !mounted) return;

    await WalletService.load();
    if (!mounted) return;
    if (WalletService.coinNotifier.value < WalletService.costCreateImageCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Not enough coins: creating an image costs '
            '${WalletService.costCreateImageCoins} Coins. You have '
            '${WalletService.coinNotifier.value}. Open Profile → Wallet to top up.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedImageUrl = null;
    });

    try {
      final taskId = await KieAiService.createImageTask(prompt: prompt);
      if (taskId == null) {
        throw Exception('Failed to create task');
      }

      String? imageUrl;
      for (int i = 0; i < 60; i++) {
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        imageUrl = await KieAiService.getTaskResult(taskId);
        if (imageUrl != null) break;
      }

      if (mounted) {
        setState(() {
          _isGenerating = false;
          _generatedImageUrl = imageUrl;
        });
        if (imageUrl != null) {
          final tags = <String>[];
          for (int i = 0; i < _styleTags.length; i++) {
            if (_selectedTags[i]) tags.add(_styleTags[i]);
          }
          await GeneratedImagesService.addImageWithMetadata(
            url: imageUrl,
            tags: tags,
            gender: _gender,
            characterName: _titleController.text.trim(),
            personality: _personalityController.text.trim(),
            styleDescription: _descriptionController.text.trim(),
          );
          await WalletService.trySpendCoins(WalletService.costCreateImageCoins);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image generated successfully')),
          );
          widget.onGenerated?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Generation timed out')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width - 20;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImageArea(context, imageWidth),
        const SizedBox(height: 16),
        _buildMalePresetSection(),
        const SizedBox(height: 24),
        _buildTextField(
          label: 'Character Name',
          controller: _titleController,
          hint: 'Enter character name',
        ),
        const SizedBox(height: 20),
        _buildFieldWithRandom(
          label: 'Character Personality',
          controller: _personalityController,
          hint: 'Describe character personality',
          onRandom: _randomPersonality,
        ),
        const SizedBox(height: 20),
        const Text(
          'Popular Anime Style Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (i) {
            return FilterChip(
              label: Text(_styleTags[i]),
              selected: _selectedTags[i],
              onSelected: (v) => setState(() => _selectedTags[i] = v),
              selectedColor: _kThemeColor.withOpacity(0.3),
              checkmarkColor: _kThemeColor,
            );
          }),
        ),
        const SizedBox(height: 20),
        const Text(
          'Anime Character Gender',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Male'),
                value: 'male',
                groupValue: _gender,
                onChanged: (v) => setState(() => _gender = v!),
                activeColor: _kThemeColor,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Female'),
                value: 'female',
                groupValue: _gender,
                onChanged: (v) => setState(() => _gender = v!),
                activeColor: _kThemeColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildFieldWithRandomAndPaste(
          label: 'Character Details',
          controller: _descriptionController,
          hint: 'Describe the anime character you want to create',
          onRandom: _randomDescription,
          onPaste: _pasteDescription,
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: _isGenerating ? null : _generateImage,
          style: FilledButton.styleFrom(
            backgroundColor: _kThemeColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: _isGenerating
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Generate Image'),
        ),
      ],
    );
  }

  Widget _buildImageArea(BuildContext context, double imageWidth) {
    if (_isGenerating) {
      return Center(
        child: SizedBox(
          width: imageWidth,
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _kThemeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kThemeColor.withOpacity(0.3)),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: _kThemeColor),
                  SizedBox(height: 16),
                  Text('Generating...', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (_generatedImageUrl != null) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: imageWidth,
            height: 200,
            child: Image.network(
              _generatedImageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) =>
                  progress == null
                      ? child
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(color: _kThemeColor),
                          ),
                        ),
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
          ),
        ),
      );
    }
    final bannerPath = widget.bannerImagePath ?? _kDefaultHeroBannerAsset;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: imageWidth,
          height: 210,
          child: Image.asset(
            bannerPath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(imageWidth),
          ),
        ),
      ),
    );
  }

  Widget _buildMalePresetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Male character quick picks',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap a portrait to fill name, personality, style tags, and details.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _malePresetCard(_malePresetLeo)),
            const SizedBox(width: 8),
            Expanded(child: _malePresetCard(_malePresetKael)),
            const SizedBox(width: 8),
            Expanded(child: _malePresetCard(_malePresetRen)),
            const SizedBox(width: 8),
            Expanded(child: _malePresetCard(_malePresetDarius)),
          ],
        ),
      ],
    );
  }

  Widget _malePresetCard(_MaleCharacterPreset preset) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _applyMalePreset(preset),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kThemeColor.withOpacity(0.25)),
            color: Colors.grey.shade50,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(11)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(
                    preset.avatarAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.person, size: 28),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(
                  preset.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(double width) {
    return Container(
      width: width,
      height: 210,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, size: 64, color: Color(0xFF616161)),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldWithRandom({
    required String label,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onRandom,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                softWrap: true,
              ),
            ),
            TextButton.icon(
              onPressed: onRandom,
              icon: const Icon(Icons.shuffle, size: 18),
              label: const Text('Random'),
              style: TextButton.styleFrom(foregroundColor: _kThemeColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldWithRandomAndPaste({
    required String label,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onRandom,
    required VoidCallback onPaste,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                softWrap: true,
              ),
            ),
            TextButton.icon(
              onPressed: onRandom,
              icon: const Icon(Icons.shuffle, size: 18),
              label: const Text('Random'),
              style: TextButton.styleFrom(
                foregroundColor: _kThemeColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            TextButton.icon(
              onPressed: onPaste,
              icon: const Icon(Icons.content_paste, size: 18),
              label: const Text('Paste'),
              style: TextButton.styleFrom(
                foregroundColor: _kThemeColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
