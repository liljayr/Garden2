// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../services/app_theme.dart';
// import '../services/api_service.dart';
// import 'friend_profile_screen.dart';

// class FriendsScreen extends StatefulWidget {
//   const FriendsScreen({super.key});

//   @override
//   State<FriendsScreen> createState() => _FriendsScreenState();
// }

// class _FriendsScreenState extends State<FriendsScreen> {
//   List<Map<String, dynamic>> _friends = [];
//   bool _loading = false;

//   final List<String> _emojis = ['🌸', '🌻', '🌿', '🍀', '🌺', '🌼', '🦋', '🌙', '⭐', '🌈'];

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     setState(() => _loading = true);
//     try {
//       final f = await ApiService.getFriends();
//       setState(() => _friends = f);
//     } catch (_) {}
//     setState(() => _loading = false);
//   }

//   void _showAddFriend() {
//     final nameCtrl = TextEditingController();
//     String selectedEmoji = _emojis[0];

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppTheme.cream,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx, setModalState) => Padding(
//           padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Add a Friend 🌱', style: GoogleFonts.playfairDisplay(
//                 fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.deepGreen,
//               )),
//               const SizedBox(height: 20),
//               // Emoji picker
//               Text('Choose an emoji', style: GoogleFonts.lato(color: AppTheme.sage, fontSize: 13)),
//               const SizedBox(height: 8),
//               Wrap(
//                 spacing: 8,
//                 children: _emojis.map((e) => GestureDetector(
//                   onTap: () => setModalState(() => selectedEmoji = e),
//                   child: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: selectedEmoji == e ? AppTheme.sage.withOpacity(0.3) : Colors.transparent,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: selectedEmoji == e ? AppTheme.deepGreen : Colors.transparent,
//                       ),
//                     ),
//                     child: Text(e, style: const TextStyle(fontSize: 24)),
//                   ),
//                 )).toList(),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: nameCtrl,
//                 autofocus: true,
//                 decoration: const InputDecoration(
//                   labelText: 'Friend\'s Name',
//                   prefixIcon: Icon(Icons.person_outline_rounded),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     if (nameCtrl.text.trim().isEmpty) return;
//                     await ApiService.addFriend({
//                       'name': nameCtrl.text.trim(),
//                       'emoji': selectedEmoji,
//                       'note': '',
//                       'strengths': [],
//                     });
//                     Navigator.pop(ctx);
//                     _load();
//                   },
//                   child: const Text('Add Friend'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Friends')),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _showAddFriend,
//         backgroundColor: AppTheme.deepGreen,
//         icon: const Icon(Icons.person_add_rounded, color: Colors.white),
//         label: Text('Add Friend', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w600)),
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : _friends.isEmpty
//               ? _emptyState()
//               : ListView.builder(
//                   padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
//                   itemCount: _friends.length,
//                   itemBuilder: (ctx, i) {
//                     final f = _friends[i];
//                     return _FriendCard(
//                       friend: f,
//                       index: i,
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => FriendProfileScreen(friend: f)),
//                       ).then((_) => _load()),
//                     );
//                   },
//                 ),
//     );
//   }

//   Widget _emptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text('🌻', style: TextStyle(fontSize: 60)),
//           const SizedBox(height: 16),
//           Text('Your garden is quiet', style: GoogleFonts.playfairDisplay(fontSize: 20, color: AppTheme.deepGreen)),
//           const SizedBox(height: 8),
//           Text('Add friends to cultivate connections', style: GoogleFonts.lato(color: AppTheme.sage)),
//         ],
//       ),
//     );
//   }
// }

// class _FriendCard extends StatelessWidget {
//   final Map<String, dynamic> friend;
//   final int index;
//   final VoidCallback onTap;

//   const _FriendCard({required this.friend, required this.index, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final strengths = List<String>.from(friend['strengths'] ?? []);
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 14),
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(22),
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4)),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 56, height: 56,
//               decoration: BoxDecoration(
//                 color: AppTheme.blush.withOpacity(0.3),
//                 shape: BoxShape.circle,
//               ),
//               child: Center(child: Text(friend['emoji'] ?? '🌱', style: const TextStyle(fontSize: 28))),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(friend['name'] ?? '', style: GoogleFonts.playfairDisplay(
//                     fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.deepGreen,
//                   )),
//                   if (strengths.isNotEmpty) ...[
//                     const SizedBox(height: 4),
//                     Text(
//                       strengths.take(3).join(' · '),
//                       style: GoogleFonts.lato(fontSize: 12, color: AppTheme.sage),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                   if (friend['note'] != null && (friend['note'] as String).isNotEmpty) ...[
//                     const SizedBox(height: 4),
//                     Text(
//                       friend['note'],
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: GoogleFonts.lato(fontSize: 13, color: const Color(0xFF5A4A3A)),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
//           ],
//         ),
//       ).animate().fadeIn(delay: Duration(milliseconds: index * 60)).slideX(begin: 0.1),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_theme.dart';
import '../services/api_service.dart';
import 'friend_profile_screen.dart';
import 'add_friend_dialog.dart'; // ← only new import

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<Map<String, dynamic>> _friends = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final f = await ApiService.getFriends();
      setState(() => _friends = f);
    } catch (_) {}
    setState(() => _loading = false);
  }

  // ← replaced _showAddFriend() — now just opens the dialog
  void _showAddFriend() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const AddFriendDialog(),
    );
    if (result != null) {
      try {
        await ApiService.addFriend(result);
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFriend,
        backgroundColor: AppTheme.deepGreen,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text('Add Friend',
            style: GoogleFonts.lato(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _friends.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  itemCount: _friends.length,
                  itemBuilder: (ctx, i) {
                    final f = _friends[i];
                    return _FriendCard(
                      friend: f,
                      index: i,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => FriendProfileScreen(friend: f)),
                      ).then((_) => _load()),
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
          const Text('🌻', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text('Your garden is quiet',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20, color: AppTheme.deepGreen)),
          const SizedBox(height: 8),
          Text('Add friends to cultivate connections',
              style: GoogleFonts.lato(color: AppTheme.sage)),
        ],
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final Map<String, dynamic> friend;
  final int index;
  final VoidCallback onTap;

  const _FriendCard(
      {required this.friend, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final strengths = List<String>.from(friend['strengths'] ?? []);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.blush.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                  child: Text(friend['emoji'] ?? '🌱',
                      style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(friend['name'] ?? '',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepGreen,
                      )),
                  // Show @username below their display name
                  if ((friend['username'] ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('@${friend['username']}',
                        style:
                            GoogleFonts.lato(fontSize: 12, color: AppTheme.sage)),
                  ],
                  if (strengths.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      strengths.take(3).join(' · '),
                      style:
                          GoogleFonts.lato(fontSize: 12, color: AppTheme.sage),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (friend['note'] != null &&
                      (friend['note'] as String).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      friend['note'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                          fontSize: 13, color: const Color(0xFF5A4A3A)),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: index * 60))
          .slideX(begin: 0.1),
    );
  }
}