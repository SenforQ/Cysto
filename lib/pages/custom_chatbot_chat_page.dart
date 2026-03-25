import 'package:flutter/material.dart';
import '../models/custom_chatbot.dart';
import '../services/chat_history_service.dart';
import '../services/gemini_chat_service.dart';
import '../services/user_preferences.dart';
import '../widgets/bubble_background.dart';

const Color _kThemeColor = Color(0xFF00C5E8);

String _formatChatTime(DateTime? dt) {
  if (dt == null) return '';
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'Just now';
}

class CustomChatbotChatPage extends StatefulWidget {
  const CustomChatbotChatPage({super.key, required this.chatbot});

  final CustomChatbot chatbot;

  @override
  State<CustomChatbotChatPage> createState() => _CustomChatbotChatPageState();
}

class _CustomChatbotChatPageState extends State<CustomChatbotChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  static const String _userAvatar = UserPreferences.defaultUserAvatar;

  Future<void> _loadHistory() async {
    final history = await ChatHistoryService.loadHistory(widget.chatbot.id);
    if (!mounted) return;
    final lastTime =
        await ChatHistoryService.getLastMessageTime(widget.chatbot.id);
    setState(() {
      _messages.addAll(history);
      if (history.isNotEmpty &&
          _messages.last['timestamp'] == null &&
          lastTime != null) {
        _messages.last['timestamp'] = lastTime.toIso8601String();
      }
    });
    _scrollToBottom();
  }

  Future<void> _saveHistory() async {
    await ChatHistoryService.saveHistory(widget.chatbot.id, _messages);
    await ChatHistoryService.saveSessionMeta(
      widget.chatbot.id,
      name: widget.chatbot.name,
      avatarUrl: widget.chatbot.avatarUrl,
      location: widget.chatbot.type,
      lastMessageTime: DateTime.now(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadHistory().then((_) {
      if (!mounted) return;
      if (_messages.isEmpty) {
        final greeting = 'Hi! I\'m ${widget.chatbot.name}. What would you like to chat about?';
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': greeting,
            'timestamp': DateTime.now().toIso8601String(),
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
      _messages.add({
        'role': 'user',
        'content': text,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _isLoading = true;
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
                _messages.add({
                  'role': 'assistant',
                  'content': delta,
                  'timestamp': DateTime.now().toIso8601String(),
                });
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
            'timestamp': DateTime.now().toIso8601String(),
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

  bool get _shouldShowPresetQuestions {
    final hasUserMessage = _messages.any((m) => m['role'] == 'user');
    return !hasUserMessage && !_isLoading;
  }

  @override
  Widget build(BuildContext context) {
    final presetQuestions = widget.chatbot.displayPresetQuestions;

    return Scaffold(
      backgroundColor: kBubbleBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: _buildAvatar(widget.chatbot.avatarUrl, 32),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.chatbot.name,
                  style: const TextStyle(fontSize: 16),
                ),
                if (widget.chatbot.type.isNotEmpty)
                  Text(
                    widget.chatbot.displayType,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length +
                  (_isLoading ? 1 : 0) +
                  (_shouldShowPresetQuestions ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length + (_isLoading ? 1 : 0)) {
                  if (index == _messages.length) {
                    return _buildLoadingBubble();
                  }
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  final isLast =
                      index == _messages.length - 1 && !_isLoading;
                  final ts = msg['timestamp'] != null
                      ? DateTime.tryParse(msg['timestamp']!)
                      : null;
                  return _buildMessageBubble(
                    msg['content'] ?? '',
                    isUser: isUser,
                    showTime: isLast,
                    time: ts,
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: presetQuestions.map((q) {
                      return ActionChip(
                        label: Text(q),
                        onPressed: () => _onPresetQuestionTap(q),
                        backgroundColor: _kThemeColor.withOpacity(0.15),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      );
                    }).toList(),
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

  Widget _buildMessageBubble(String content,
      {required bool isUser, bool showTime = false, DateTime? time}) {
    final timeStr = showTime && time != null ? _formatChatTime(time) : '';
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.78;
    final bubble = IntrinsicWidth(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade200,
                  child: _buildAvatar(widget.chatbot.avatarUrl, 32),
                ),
                const SizedBox(width: 8),
              ],
              if (isUser) ...[
                bubble,
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade200,
                  child: _buildAvatar(_userAvatar, 32),
                ),
              ] else
                bubble,
            ],
          ),
          if (timeStr.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                timeStr,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
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
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
