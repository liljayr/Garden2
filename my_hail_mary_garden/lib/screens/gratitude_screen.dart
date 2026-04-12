import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_theme.dart';
import '../services/api_service.dart';

class GratitudeScreen extends StatefulWidget {
  const GratitudeScreen({super.key});

  @override
  State<GratitudeScreen> createState() => _GratitudeScreenState();
}

class _GratitudeScreenState extends State<GratitudeScreen> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _entries = [];
  bool _loading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final entries = await ApiService.getGratitude();
      setState(() => _entries = entries);
    } catch (e) {
      _showError('Could not load entries');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await ApiService.addGratitude(_controller.text.trim());
      _controller.clear();
      await _load();
    } catch (e) {
      _showError('Could not save');
    } finally {
      setState(() => _submitting = false);
    }
  }

  Future<void> _delete(String id) async {
    try {
      await ApiService.deleteGratitude(id);
      await _load();
    } catch (e) {
      _showError('Could not delete');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[d.month - 1]} ${d.day}';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gratitude'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Input area
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What are you grateful for today? 🙏',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: AppTheme.deepGreen,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'I am grateful for...',
                    hintStyle: GoogleFonts.lato(color: Colors.grey[400]),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add_rounded),
                    label: const Text('Add Entry'),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),

          // Entries list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${_entries.length} blessings counted',
                  style: GoogleFonts.lato(
                    color: AppTheme.sage, fontSize: 13, fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _entries.length,
                        itemBuilder: (ctx, i) {
                          final e = _entries[_entries.length - 1 - i];
                          return _GratitudeCard(
                            text: e['text'] ?? '',
                            date: _formatDate(e['date']),
                            onDelete: () => _delete(e['id'] ?? ''),
                            index: i,
                          );
                        },
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
          const Text('🌱', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Start your gratitude garden',
            style: GoogleFonts.playfairDisplay(fontSize: 18, color: AppTheme.deepGreen),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first entry above',
            style: GoogleFonts.lato(color: AppTheme.sage),
          ),
        ],
      ),
    );
  }
}

class _GratitudeCard extends StatelessWidget {
  final String text;
  final String date;
  final VoidCallback onDelete;
  final int index;

  const _GratitudeCard({
    required this.text, required this.date,
    required this.onDelete, required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('✨', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: GoogleFonts.lato(fontSize: 15, color: const Color(0xFF3A3028))),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(date, style: GoogleFonts.lato(fontSize: 12, color: AppTheme.sage)),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.grey[400], size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 50)).slideX(begin: 0.1);
  }
}
