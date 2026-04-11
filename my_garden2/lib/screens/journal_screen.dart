import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_theme.dart';
import '../services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final entries = await ApiService.getJournal();
      setState(() => _entries = entries);
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _openEntry({Map<String, dynamic>? entry}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JournalEntryScreen(entry: entry)),
    ).then((_) => _load());
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Entry?', style: GoogleFonts.playfairDisplay(color: AppTheme.deepGreen)),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.deleteJournal(id);
      _load();
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Journal')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEntry(),
        backgroundColor: AppTheme.deepGreen,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: Text("Today's Entry", style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: _entries.length,
                  itemBuilder: (ctx, i) {
                    final e = _entries[i];
                    return _JournalCard(
                      title: e['title'] ?? 'Untitled',
                      content: e['content'] ?? '',
                      date: _formatDate(e['date']),
                      index: i,
                      onTap: () => _openEntry(entry: e),
                      onDelete: () => _delete(e['id'] ?? ''),
                    );
                  },
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📖', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text('Your story starts here',
            style: GoogleFonts.playfairDisplay(fontSize: 20, color: AppTheme.deepGreen)),
          const SizedBox(height: 8),
          Text('Tap the button below to write today\'s entry',
            style: GoogleFonts.lato(color: AppTheme.sage)),
        ],
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final String title, content, date;
  final int index;
  final VoidCallback onTap, onDelete;

  const _JournalCard({
    required this.title, required this.content, required this.date,
    required this.index, required this.onTap, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.sky.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(date, style: GoogleFonts.lato(fontSize: 11, color: AppTheme.deepGreen, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: Colors.grey[400], size: 20),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.playfairDisplay(
              fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.deepGreen,
            )),
            const SizedBox(height: 6),
            Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(fontSize: 14, color: const Color(0xFF5A4A3A), height: 1.5),
            ),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: index * 60)).slideY(begin: 0.1),
    );
  }
}

class JournalEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? entry;
  const JournalEntryScreen({super.key, this.entry});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?['title'] ?? '');
    _contentController = TextEditingController(text: widget.entry?['content'] ?? '');
  }

  Future<void> _save() async {
    print("USER: ${FirebaseAuth.instance.currentUser}");
    if (_contentController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final title = _titleController.text.trim().isEmpty
          ? 'Entry — ${DateTime.now().day}/${DateTime.now().month}'
          : _titleController.text.trim();
      if (widget.entry != null) {
        await ApiService.updateJournal(widget.entry!['id'], title, _contentController.text.trim());
      } else {
        await ApiService.addJournal(title, _contentController.text.trim());
      }
      Navigator.pop(context);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save entry')),
      );
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry != null ? 'Edit Entry' : 'New Entry'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.deepGreen),
              decoration: InputDecoration(
                hintText: 'Give your entry a title...',
                hintStyle: GoogleFonts.playfairDisplay(fontSize: 22, color: Colors.grey[300]),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: GoogleFonts.lato(fontSize: 16, color: const Color(0xFF3A3028), height: 1.7),
                decoration: InputDecoration(
                  hintText: 'Write about your day...',
                  hintStyle: GoogleFonts.lato(fontSize: 16, color: Colors.grey[300]),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
