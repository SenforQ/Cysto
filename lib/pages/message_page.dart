import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/custom_chatbot.dart';
import '../models/generated_image_item.dart'
    show GeneratedImageEntrySource, GeneratedImageItem;
import '../services/chat_history_service.dart';
import '../services/custom_chatbot_service.dart';
import '../widgets/character_image_display.dart';
import 'character_ai_chat_page.dart';
import 'custom_chatbot_chat_page.dart';

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

GeneratedImageItem? _characterItemFromMeta(Map<String, String>? meta) {
  if (meta == null) return null;
  final raw = meta['characterItemJson'];
  if (raw != null && raw.isNotEmpty) {
    try {
      return GeneratedImageItem.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {}
  }
  final url = meta['avatarUrl'] ?? '';
  if (url.isEmpty) return null;
  return GeneratedImageItem(
    url: url,
    characterName: meta['name'] ?? 'Character',
    entrySource: GeneratedImageEntrySource.aiStudio,
  );
}

class _SessionEntry {
  const _SessionEntry._({
    required this.botId,
    required this.isCharacter,
    this.chatbot,
    this.characterItem,
  });

  factory _SessionEntry.custom(CustomChatbot c) =>
      _SessionEntry._(botId: c.id, isCharacter: false, chatbot: c);

  factory _SessionEntry.character(String botId, GeneratedImageItem item) =>
      _SessionEntry._(
        botId: botId,
        isCharacter: true,
        characterItem: item,
      );

  final String botId;
  final bool isCharacter;
  final CustomChatbot? chatbot;
  final GeneratedImageItem? characterItem;

  String get displayName {
    if (isCharacter) {
      final n = characterItem!.characterName.trim();
      return n.isNotEmpty ? n : 'Character';
    }
    return chatbot!.name;
  }
}

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  List<_SessionEntry> _sessions = [];
  final Map<String, DateTime> _lastMessageTimes = {};
  bool _isLoading = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedBotIds = {};

  @override
  void initState() {
    super.initState();
    _loadSessions();
    CustomChatbotService.chatbotsNotifier.addListener(_onChatbotsChanged);
    ChatHistoryService.historyUpdated.addListener(_onHistoryUpdated);
  }

  @override
  void dispose() {
    CustomChatbotService.chatbotsNotifier.removeListener(_onChatbotsChanged);
    ChatHistoryService.historyUpdated.removeListener(_onHistoryUpdated);
    super.dispose();
  }

  void _onChatbotsChanged() => _loadSessions();
  void _onHistoryUpdated() => _loadSessions();

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final chatbots = await CustomChatbotService.getAll();
    final chatbotById = {for (final c in chatbots) c.id: c};
    final allSessionIds = await ChatHistoryService.getAllSessionBotIds();
    final sessions = <_SessionEntry>[];
    final times = <String, DateTime>{};

    for (final id in allSessionIds) {
      final custom = chatbotById[id];
      if (custom != null) {
        final t = await ChatHistoryService.getLastMessageTime(id);
        if (t != null) times[id] = t;
        sessions.add(_SessionEntry.custom(custom));
        continue;
      }
      final meta = await ChatHistoryService.getSessionMeta(id);
      final isCharacter =
          id.startsWith('zhipu_char_') || (meta?['location'] == 'Character');
      if (!isCharacter) continue;
      final item = _characterItemFromMeta(meta);
      if (item == null) continue;
      final t = await ChatHistoryService.getLastMessageTime(id);
      if (t != null) times[id] = t;
      sessions.add(_SessionEntry.character(id, item));
    }

    sessions.sort((a, b) {
      DateTime fallback(_SessionEntry s) {
        if (!s.isCharacter) return s.chatbot!.createdAt;
        return DateTime.fromMillisecondsSinceEpoch(0);
      }

      final ta = times[a.botId] ?? fallback(a);
      final tb = times[b.botId] ?? fallback(b);
      return tb.compareTo(ta);
    });

    if (mounted) {
      setState(() {
        _sessions = sessions;
        _lastMessageTimes.clear();
        _lastMessageTimes.addAll(times);
        _isLoading = false;
      });
    }
  }

  void _openChat(_SessionEntry entry) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedBotIds.contains(entry.botId)) {
          _selectedBotIds.remove(entry.botId);
        } else {
          _selectedBotIds.add(entry.botId);
        }
      });
      return;
    }
    if (entry.isCharacter) {
      Navigator.of(context)
          .push<void>(
        MaterialPageRoute<void>(
          builder: (ctx) => CharacterAiChatPage(item: entry.characterItem!),
        ),
      )
          .then((_) => _loadSessions());
    } else {
      Navigator.of(context)
          .push<void>(
        MaterialPageRoute<void>(
          builder: (ctx) => CustomChatbotChatPage(chatbot: entry.chatbot!),
        ),
      )
          .then((_) => _loadSessions());
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) _selectedBotIds.clear();
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedBotIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Chats'),
        content: Text(
          'Delete ${_selectedBotIds.length} selected chat(s)? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    for (final botId in _selectedBotIds) {
      await ChatHistoryService.deleteHistory(botId);
    }
    if (mounted) {
      setState(() {
        _isSelectionMode = false;
        _selectedBotIds.clear();
      });
      _loadSessions();
    }
  }

  Future<String> _getLastPreview(String botId) async {
    final preview = await ChatHistoryService.getLastMessagePreview(botId);
    return preview;
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

  Widget _buildSessionAvatar(_SessionEntry entry, double size) {
    if (entry.isCharacter) {
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: CharacterImageDisplay(
            imageRef: entry.characterItem!.url,
            fit: BoxFit.cover,
            width: size,
            height: size,
          ),
        ),
      );
    }
    return _buildAvatar(entry.chatbot!.avatarUrl, size);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = 66 + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSelectionMode ? Icons.close : Icons.delete_outline,
              color: Colors.black87,
            ),
            onPressed: _toggleSelectionMode,
          ),
          if (_isSelectionMode && _selectedBotIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteSelected,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kThemeColor))
          : RefreshIndicator(
              onRefresh: _loadSessions,
              color: _kThemeColor,
              child: _sessions.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 200,
                        child: const Center(
                          child: Text(
                            'No chats yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Recent chats',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _sessions.length,
                            itemBuilder: (context, index) {
                              final session = _sessions[index];
                              final isSelected =
                                  _selectedBotIds.contains(session.botId);
                              return GestureDetector(
                                onTap: () => _openChat(session),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          CircleAvatar(
                                            radius: 28,
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            child: _buildSessionAvatar(
                                              session,
                                              56,
                                            ),
                                          ),
                                          if (_isSelectionMode)
                                            Positioned(
                                              right: -4,
                                              top: -4,
                                              child: Container(
                                                width: 22,
                                                height: 22,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? _kThemeColor
                                                      : Colors.white,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? _kThemeColor
                                                        : Colors.grey,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: isSelected
                                                    ? const Icon(
                                                        Icons.check,
                                                        size: 14,
                                                        color: Colors.white,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        width: 56,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              session.displayName,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                            if (_lastMessageTimes[session.botId] !=
                                                null) ...[
                                              const SizedBox(height: 1),
                                              Text(
                                                _formatChatTime(
                                                  _lastMessageTimes[
                                                      session.botId],
                                                ),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            'Chat list',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ..._sessions.map(
                          (session) => Column(
                            children: [
                              _SessionListItem(
                                session: session,
                                onTap: () => _openChat(session),
                                buildSessionAvatar: _buildSessionAvatar,
                                getLastPreview: _getLastPreview,
                                lastMessageTime:
                                    _lastMessageTimes[session.botId],
                                isSelectionMode: _isSelectionMode,
                                isSelected:
                                    _selectedBotIds.contains(session.botId),
                              ),
                              Divider(
                                height: 1,
                                color: Colors.grey.shade200,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }
}

class _SessionListItem extends StatelessWidget {
  const _SessionListItem({
    required this.session,
    required this.onTap,
    required this.buildSessionAvatar,
    required this.getLastPreview,
    this.lastMessageTime,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  final _SessionEntry session;
  final VoidCallback onTap;
  final Widget Function(_SessionEntry, double) buildSessionAvatar;
  final Future<String> Function(String) getLastPreview;
  final DateTime? lastMessageTime;
  final bool isSelectionMode;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getLastPreview(session.botId),
      builder: (context, snapshot) {
        final preview = snapshot.data ?? '';

        return Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (_) => onTap(),
                          activeColor: _kThemeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade200,
                    child: buildSessionAvatar(session, 48),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                session.displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (session.isCharacter)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _kThemeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Character',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _kThemeColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (preview.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            preview,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (lastMessageTime != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        _formatChatTime(lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
