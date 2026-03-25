import 'package:flutter/material.dart';
import '../models/discover_bot.dart';
import '../widgets/bubble_background.dart';
import '../services/chat_history_service.dart';
import '../services/gemini_chat_service.dart';
import '../services/user_preferences.dart';
import 'chat_bot_detail_page.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.bot,
    this.initialGreeting,
    this.tags,
    this.styleDescription,
  });

  final DiscoverBot bot;
  final String? initialGreeting;
  final List<String>? tags;
  final String? styleDescription;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _hasSentMessage = false;
  static const String _userAvatar = UserPreferences.defaultUserAvatar;
  static const List<String> _presetQuestions = [
    'Tell me your story',
    'What kind of vibe do you like?',
    'Recommend a topic for me',
  ];

  Future<void> _loadHistory() async {
    final history = await ChatHistoryService.loadHistory(widget.bot.id);
    if (!mounted) return;
    setState(() {
      _messages.addAll(history);
      _hasSentMessage = _messages.any((m) => m['role'] == 'user');
    });
    _scrollToBottom();
  }

  Future<void> _saveHistory() async {
    await ChatHistoryService.saveHistory(widget.bot.id, _messages);
    if (_messages.isNotEmpty) {
      await ChatHistoryService.saveSessionMeta(
        widget.bot.id,
        name: widget.bot.name,
        avatarUrl: widget.bot.avatarUrl,
        location: widget.bot.location,
      );
    }
  }

  void _openBotDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatBotDetailPage(
          bot: widget.bot,
          tags: widget.tags ?? [],
          styleDescription: widget.styleDescription,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadHistory().then((_) {
      if (!mounted) return;
      if (_messages.isEmpty &&
          widget.initialGreeting != null &&
          widget.initialGreeting!.isNotEmpty) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': widget.initialGreeting!,
          });
        });
        _saveHistory();
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    _controller.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
      _hasSentMessage = true;
    });
    _scrollToBottom();

    try {
      final reply = await GeminiChatService.sendMessage(
        messages: _messages,
        onChunk: (delta) {
          if (mounted) {
            setState(() {
              if (_messages.isNotEmpty &&
                  _messages.last['role'] == 'assistant') {
                _messages.last['content'] =
                    (_messages.last['content'] ?? '') + delta;
              } else {
                _messages.add({'role': 'assistant', 'content': delta});
              }
            });
            _scrollToBottom();
          }
        },
      );
      if (mounted && reply != null && reply.isNotEmpty) {
        setState(() {
          final last = _messages.lastWhere(
            (m) => m['role'] == 'assistant',
            orElse: () => {},
          );
          if (last.isNotEmpty) {
            last['content'] = (last['content'] ?? '') + reply;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Sorry, something went wrong: $e',
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _saveHistory();
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
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

  void _onPresetQuestionTap(String question) {
    if (question.isEmpty || _isLoading) return;
    _controller.text = question;
    _controller.selection = TextSelection.collapsed(offset: question.length);
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBubbleBackgroundColor,
      appBar: AppBar(
        title: GestureDetector(
          onTap: _openBotDetail,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                child: _buildAvatar(widget.bot.avatarUrl, 32),
              ),
              const SizedBox(width: 10),
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.bot.name,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  widget.bot.location,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length +
                  (_isLoading ? 1 : 0) +
                  _presetQuestions.length,
              itemBuilder: (context, index) {
                if (index < _messages.length + (_isLoading ? 1 : 0)) {
                  if (index == _messages.length) {
                    return _buildLoadingBubble();
                  }
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  return _buildMessageBubble(
                    msg['content'] ?? '',
                    isUser: isUser,
                  );
                }
                final qIndex = index - _messages.length - (_isLoading ? 1 : 0);
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: 8,
                    top: qIndex == 0 ? 8 : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ActionChip(
                        label: Text(_presetQuestions[qIndex]),
                        onPressed: () =>
                            _onPresetQuestionTap(_presetQuestions[qIndex]),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask a question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                    minLines: 1,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: _kThemeColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String content, {required bool isUser}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: _buildAvatar(widget.bot.avatarUrl, 32),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? _kThemeColor : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: Text(
                content,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: _buildAvatar(_userAvatar, 32),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _kThemeColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Thinking...',
              style: TextStyle(color: const Color(0xFF616161)),
            ),
          ],
        ),
      ),
    );
  }
}
