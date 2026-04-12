import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_theme.dart';
import '../services/api_service.dart';
import 'message_screen.dart';

class FriendProfileScreen extends StatefulWidget {
  final Map<String, dynamic> friend;
  const FriendProfileScreen({super.key, required this.friend});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  late Map<String, dynamic> _friend;
  bool _editing = false;
  bool _saving = false;
  late TextEditingController _noteCtrl;
  List<String> _selectedStrengths = [];
  List<Map<String, dynamic>> _allStrengths = [];

  final List<String> _defaultStrengths = [
    'Creativity', 'Curiosity', 'Kindness', 'Leadership', 'Bravery',
    'Honesty', 'Perseverance', 'Teamwork', 'Empathy', 'Humor',
    'Patience', 'Gratitude', 'Love of Learning', 'Fairness', 'Forgiveness',
    'Zest', 'Hope', 'Prudence', 'Self-Regulation', 'Spirituality',
  ];

  @override
  void initState() {
    super.initState();
    _friend = Map<String, dynamic>.from(widget.friend);
    _selectedStrengths = List<String>.from(_friend['strengths'] ?? []);
    _noteCtrl = TextEditingController(text: _friend['note'] ?? '');
    _loadStrengths();
  }

  Future<void> _loadStrengths() async {
    try {
      _allStrengths = await ApiService.getStrengths();
    } catch (_) {
      _allStrengths = _defaultStrengths.map((s) => {'name': s, 'selected': false}).toList();
    }
    setState(() {});
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updated = await ApiService.updateFriend(_friend['id'], {
        ..._friend,
        'note': _noteCtrl.text.trim(),
        'strengths': _selectedStrengths,
      });
      setState(() {
        _friend = updated;
        _editing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated! 🌸')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save')),
      );
    }
    setState(() => _saving = false);
  }

  void _toggleStrength(String name) {
    setState(() {
      if (_selectedStrengths.contains(name)) {
        _selectedStrengths.remove(name);
      } else {
        _selectedStrengths.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strengthNames = _allStrengths.isNotEmpty
        ? _allStrengths.map((s) => s['name'] as String).toList()
        : _defaultStrengths;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.cream,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.deepGreen),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(_editing ? Icons.close_rounded : Icons.edit_rounded, color: AppTheme.deepGreen),
                onPressed: () => setState(() => _editing = !_editing),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.blush.withOpacity(0.3),
                      AppTheme.cream,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.blush.withOpacity(0.3),
                        border: Border.all(color: AppTheme.blush, width: 3),
                      ),
                      child: Center(child: Text(_friend['emoji'] ?? '🌱',
                          style: const TextStyle(fontSize: 44))),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _friend['name'] ?? '',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.deepGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MessageScreen(friend: _friend)),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: Text('Send a Message', style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 28),

                  // Notes section
                  _SectionHeader(title: 'Notes', icon: '📝'),
                  const SizedBox(height: 10),
                  _editing
                      ? TextField(
                          controller: _noteCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(hintText: 'Add notes about this friend...'),
                        )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            _friend['note']?.isEmpty ?? true ? 'No notes yet' : _friend['note'],
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: _friend['note']?.isEmpty ?? true ? Colors.grey[400] : const Color(0xFF3A3028),
                              fontStyle: _friend['note']?.isEmpty ?? true ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        ),

                  const SizedBox(height: 28),

                  // Strengths section
                  _SectionHeader(title: "${_friend['name']?.split(' ')[0]}'s Strengths", icon: '✨'),
                  const SizedBox(height: 10),

                  if (_editing) ...[
                    Text('Tap to toggle strengths', style: GoogleFonts.lato(fontSize: 12, color: AppTheme.sage)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: strengthNames.map((name) {
                        final selected = _selectedStrengths.contains(name);
                        return GestureDetector(
                          onTap: () => _toggleStrength(name),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.deepGreen : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected ? AppTheme.deepGreen : AppTheme.sage.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              name,
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : AppTheme.deepGreen,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ] else ...[
                    _selectedStrengths.isEmpty
                        ? Text('No strengths added yet',
                            style: GoogleFonts.lato(color: Colors.grey[400], fontStyle: FontStyle.italic))
                        : Wrap(
                            spacing: 8, runSpacing: 8,
                            children: _selectedStrengths.map((s) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.lavender.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.lavender.withOpacity(0.5)),
                              ),
                              child: Text(s, style: GoogleFonts.lato(
                                fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.deepGreen,
                              )),
                            )).toList(),
                          ),
                  ],

                  if (_editing) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save_rounded),
                        label: const Text('Save Profile'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title, icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.playfairDisplay(
          fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.deepGreen,
        )),
      ],
    );
  }
}
