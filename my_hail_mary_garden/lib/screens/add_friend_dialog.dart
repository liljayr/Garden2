// ─────────────────────────────────────────────────────────────────────────────
// Drop-in replacement for whatever add-friend dialog/sheet you currently have
// in friends_screen.dart. Call it like:
//
//   final result = await showDialog<Map<String,dynamic>>(
//     context: context,
//     builder: (_) => const AddFriendDialog(),
//   );
//   if (result != null) await ApiService.addFriend(result);
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_theme.dart';
import '../services/api_service.dart';

class AddFriendDialog extends StatefulWidget {
  const AddFriendDialog({super.key});

  @override
  State<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final _usernameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String _emoji = '🌱';
  bool _checking = false;
  bool _verified = false;   // true once username confirmed to exist
  String? _error;

  final _emojis = ['🌱', '🌻', '🌸', '🌿', '🍀', '🌼', '🦋', '🌈', '⭐', '💚'];

  Future<void> _checkUsername() async {
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty) return;

    setState(() { _checking = true; _error = null; _verified = false; });
    try {
      final exists = await ApiService.userExists(username);
      if (exists) {
        setState(() { _verified = true; });
        // Pre-fill display name if empty
        if (_nameCtrl.text.isEmpty) _nameCtrl.text = username;
      } else {
        setState(() => _error = 'No user found with that username');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
    setState(() => _checking = false);
  }

  void _submit() {
    if (!_verified) {
      setState(() => _error = 'Please verify the username first');
      return;
    }
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a display name');
      return;
    }
    Navigator.pop(context, {
      'username': _usernameCtrl.text.trim(),
      'name': name,
      'emoji': _emoji,
      'note': '',
      'strengths': [],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add a Friend',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepGreen)),
            const SizedBox(height: 20),

            // Username row with verify button
            Text('Their username',
                style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepGreen,
                    letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _usernameCtrl,
                    onChanged: (_) => setState(() { _verified = false; _error = null; }),
                    style: GoogleFonts.lato(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'their_username',
                      hintStyle: GoogleFonts.lato(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: _verified
                                  ? Colors.green
                                  : AppTheme.sage.withOpacity(0.3))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: _verified
                                  ? Colors.green
                                  : AppTheme.sage.withOpacity(0.3))),
                      suffixIcon: _verified
                          ? const Icon(Icons.check_circle_rounded,
                              color: Colors.green, size: 20)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _checking ? null : _checkUsername,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.deepGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _checking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('Check',
                            style: GoogleFonts.lato(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
              ],
            ),

            // Error
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: GoogleFonts.lato(
                      color: AppTheme.terracotta, fontSize: 12)),
            ],

            const SizedBox(height: 16),

            // Display name
            Text('Display name',
                style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepGreen,
                    letterSpacing: 0.5)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              style: GoogleFonts.lato(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'How you know them',
                hintStyle: GoogleFonts.lato(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppTheme.sage.withOpacity(0.3))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppTheme.sage.withOpacity(0.3))),
              ),
            ),

            const SizedBox(height: 16),

            // Emoji picker
            Text('Pick an emoji',
                style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepGreen,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _emojis.map((e) {
                final selected = e == _emoji;
                return GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.sage.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: selected
                              ? AppTheme.deepGreen
                              : Colors.transparent),
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 22)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',
                        style: GoogleFonts.lato(color: AppTheme.sage)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.deepGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Add Friend',
                        style: GoogleFonts.lato(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}