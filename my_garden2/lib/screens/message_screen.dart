import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_theme.dart';
import '../services/api_service.dart';

class MessageScreen extends StatefulWidget {
  final Map<String, dynamic> friend;
  const MessageScreen({super.key, required this.friend});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final msgs = await ApiService.getMessages(widget.friend['id'] ?? '');
      setState(() => _messages = msgs);
      _scrollToBottom();
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _send() async {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text.trim();
    _controller.clear();
    setState(() => _sending = true);
    try {
      await ApiService.sendMessage(widget.friend['id'] ?? '', text);
      await Future.delayed(const Duration(milliseconds: 600));
      await _load();
    } catch (_) {}
    setState(() => _sending = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso);
      final h = d.hour.toString().padLeft(2, '0');
      final m = d.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.friend['emoji'] ?? '🌱', style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(widget.friend['name'] ?? 'Friend'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, i) {
                          final msg = _messages[i];
                          final fromMe = msg['from_me'] == true;
                          return _MessageBubble(
                            text: msg['content'] ?? '',
                            fromMe: fromMe,
                            time: _formatTime(msg['timestamp']),
                            friendEmoji: widget.friend['emoji'] ?? '🌱',
                            index: i,
                          );
                        },
                      ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            decoration: BoxDecoration(
              color: AppTheme.cream,
              border: Border(top: BorderSide(color: AppTheme.sage.withOpacity(0.2))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Send a kind message...',
                      hintStyle: GoogleFonts.lato(color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _send(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sending ? null : _send,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: _sending ? AppTheme.sage : AppTheme.deepGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepGreen.withOpacity(0.3),
                          blurRadius: 10, offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _sending
                        ? const Center(child: SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.friend['emoji'] ?? '🌱', style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text('Say hello to ${widget.friend['name']?.split(' ')[0]}!',
            style: GoogleFonts.playfairDisplay(fontSize: 18, color: AppTheme.deepGreen)),
          const SizedBox(height: 8),
          Text('Be the first to reach out 💚',
            style: GoogleFonts.lato(color: AppTheme.sage)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text, time, friendEmoji;
  final bool fromMe;
  final int index;

  const _MessageBubble({
    required this.text, required this.fromMe, required this.time,
    required this.friendEmoji, required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!fromMe) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppTheme.blush.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(friendEmoji, style: const TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: fromMe ? AppTheme.deepGreen : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: fromMe ? const Radius.circular(18) : const Radius.circular(4),
                      bottomRight: fromMe ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8, offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color: fromMe ? Colors.white : const Color(0xFF3A3028),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(time, style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[400])),
            ],
          ),
          if (fromMe) const SizedBox(width: 4),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 30)).slideY(begin: 0.1);
  }
}
