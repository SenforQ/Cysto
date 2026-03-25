import 'package:flutter/material.dart';
import '../models/custom_chatbot.dart';
import '../models/generated_image_item.dart';
import '../services/custom_chatbot_service.dart';
import '../services/generated_images_service.dart';
import '../widgets/bubble_background.dart';
import '../widgets/character_image_display.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

const List<String> _presetTypes = [
  'Study',
  'Sports',
  'Anime',
  'Games',
  'Music',
  'Food',
  'Travel',
  'Tech',
  'Entertainment',
  'Emotions',
];

const Map<String, List<String>> _typeToQuestions = {
  'Study': [
    'Recommend a book',
    'What are you learning lately?',
    'Any study tips?',
    'How to improve learning efficiency?',
    'Can you chat with me?',
  ],
  'Sports': [
    'Any sports recommendations?',
    'Anything interesting today?',
    'What are your hobbies?',
    'Any plans for the weekend?',
    'Can you chat with me?',
  ],
  'Anime': [
    'Recommend an anime',
    'Any anime recommendations?',
    'What type of anime do you like?',
    'Can you chat with me?',
    'Anything interesting today?',
  ],
  'Games': [
    'Any game recommendations?',
    'What games do you like?',
    'Any plans for the weekend?',
    'Can you chat with me?',
    'Anything interesting today?',
  ],
  'Music': [
    'Any music recommendations?',
    'What type of music do you like?',
    'Can you chat with me?',
    'Anything interesting today?',
    'What are your hobbies?',
  ],
  'Food': [
    'Any food recommendations?',
    'What do you like to eat?',
    'Can you chat with me?',
    'Anything interesting today?',
    'Any plans for the weekend?',
  ],
  'Travel': [
    'Any travel recommendations?',
    'Any plans for the weekend?',
    'Where do you like to travel?',
    'Can you chat with me?',
    'Anything interesting today?',
  ],
  'Tech': [
    'Any tech news lately?',
    'Any tech product recommendations?',
    'Can you chat with me?',
    'Anything interesting today?',
    'What are your hobbies?',
  ],
  'Entertainment': [
    'Any entertainment recommendations?',
    'Any plans for the weekend?',
    'Can you chat with me?',
    'Anything interesting today?',
    'What are your hobbies?',
  ],
  'Emotions': [
    'How to improve my mood?',
    'Can you chat with me?',
    'Anything interesting today?',
    'What are your hobbies?',
    'Any plans for the weekend?',
  ],
};

const List<String> _defaultQuestions = [
  'Anything interesting today?',
  'Can you chat with me?',
  'What are your hobbies?',
];

class CreateChatbotPage extends StatefulWidget {
  const CreateChatbotPage({super.key});

  @override
  State<CreateChatbotPage> createState() => _CreateChatbotPageState();
}

class _CreateChatbotPageState extends State<CreateChatbotPage> {
  GeneratedImageItem? _selectedImage;
  final Set<String> _selectedQuestions = {};
  final TextEditingController _typeController = TextEditingController();
  List<GeneratedImageItem> _galleryItems = [];

  List<String> get _currentQuestions {
    final type = _typeController.text.trim();
    if (type.isEmpty) return _defaultQuestions;
    return _typeToQuestions[type] ?? _defaultQuestions;
  }

  @override
  void initState() {
    super.initState();
    _loadGalleryItems();
  }

  @override
  void dispose() {
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _loadGalleryItems() async {
    final allItems = await GeneratedImagesService.getItems();
    final chatbots = await CustomChatbotService.getAll();
    final usedUrls = chatbots.map((c) => c.avatarUrl).toSet();
    final unused = allItems.where((item) => !usedUrls.contains(item.url)).toList();
    if (mounted) setState(() => _galleryItems = unused);
  }

  void _toggleQuestion(String question) {
    setState(() {
      if (_selectedQuestions.contains(question)) {
        _selectedQuestions.remove(question);
      } else {
        _selectedQuestions.add(question);
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }
    final name = _selectedImage!.characterName.isNotEmpty
        ? _selectedImage!.characterName
        : 'Character';
    final type = _typeController.text.trim();
    if (type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter chatbot type')),
      );
      return;
    }
    final questions = _selectedQuestions.toList();
    final chatbot = CustomChatbot(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      avatarUrl: _selectedImage!.url,
      name: name,
      type: type,
      presetQuestions: questions,
      createdAt: DateTime.now(),
    );
    await CustomChatbotService.add(chatbot);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chatbot created successfully')),
      );
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildImageThumb(String url, bool isSelected) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CharacterImageDisplay(
            imageRef: url,
            fit: BoxFit.cover,
            width: 80,
            height: 80,
          ),
        ),
        if (isSelected)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: _kThemeColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBubbleBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Chatbot',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select cover & avatar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (_galleryItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Please go to the home page to create an image first~',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _galleryItems.asMap().entries.map((entry) {
                  final item = entry.value;
                  final isSelected = _selectedImage?.url == item.url;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedImage = item),
                    child: _buildImageThumb(item.url, isSelected),
                  );
                }).toList(),
              ),
            const SizedBox(height: 28),
            const Text(
              'Chatbot type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(
                hintText: 'e.g. Study, Sports, Anime',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetTypes.map((t) {
                final isSelected = _typeController.text.trim() == t;
                return FilterChip(
                  label: Text(t),
                  selected: isSelected,
                  onSelected: (_) => setState(() {
                    _typeController.text = t;
                    _selectedQuestions.clear();
                  }),
                  selectedColor: _kThemeColor.withOpacity(0.3),
                  checkmarkColor: _kThemeColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Preset questions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select questions (multiple)',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentQuestions.map((question) {
                final isSelected = _selectedQuestions.contains(question);
                return FilterChip(
                  label: Text(question),
                  selected: isSelected,
                  onSelected: (_) => _toggleQuestion(question),
                  selectedColor: _kThemeColor.withOpacity(0.3),
                  checkmarkColor: _kThemeColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: _kThemeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
