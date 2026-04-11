import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/app_theme.dart';
import '../services/api_service.dart';
import 'gratitude_screen.dart';
import 'strengths_screen.dart';
import 'journal_screen.dart';
import 'friends_screen.dart';
import 'message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _friends = [];

  String get _displayName {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email ?? 'Gardener';
    // Show only the first name if it's a full name
    return name.split(' ').first;
  }

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await ApiService.getFriends();
      if (mounted) setState(() => _friends = friends);
    } catch (_) {}
  }

  void _openQuickMessage(BuildContext context) {
    if (_friends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some friends first! 🌱')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a message to...',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepGreen,
              ),
            ),
            const SizedBox(height: 16),
            ...(_friends.map((f) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.sage.withOpacity(0.2),
                    child: Text(
                      f['emoji'] ?? '🌱',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    f['name'] ?? '',
                    style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessageScreen(friend: f),
                      ),
                    ).then((_) => _loadFriends());
                  },
                ))),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Leave your garden?',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            color: AppTheme.deepGreen,
          ),
        ),
        content: Text(
          'You can always come back. 🌿',
          style: GoogleFonts.lato(color: AppTheme.sage),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Stay', style: GoogleFonts.lato(color: AppTheme.sage)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              // StreamBuilder in main.dart will route back to LoginScreen
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.lato(
                color: AppTheme.terracotta,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -80, right: -60,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.sage.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 100, left: -80,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.terracotta.withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title + greeting
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🌿', style: const TextStyle(fontSize: 32))
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .scale(),
                          const SizedBox(height: 4),
                          Text(
                            'My Garden',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.deepGreen,
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                          Text(
                            'Hello, $_displayName 🌱',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: AppTheme.sage,
                              letterSpacing: 0.5,
                            ),
                          ).animate().fadeIn(delay: 400.ms),
                        ],
                      ),

                      // Action buttons
                      Column(
                        children: [
                          // Quick message button
                          GestureDetector(
                            onTap: () => _openQuickMessage(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.deepGreen,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.deepGreen.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ).animate().fadeIn(delay: 400.ms).scale(),

                          const SizedBox(height: 10),

                          // Sign out button
                          GestureDetector(
                            onTap: () => _confirmSignOut(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.terracotta.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.terracotta.withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                Icons.logout_rounded,
                                color: AppTheme.terracotta,
                                size: 20,
                              ),
                            ),
                          ).animate().fadeIn(delay: 500.ms).scale(),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Feature grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _GardenCard(
                          emoji: '🙏',
                          title: 'Gratitude',
                          subtitle: 'Count your blessings',
                          color: AppTheme.gold,
                          delay: 0,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const GratitudeScreen()),
                          ),
                        ),
                        _GardenCard(
                          emoji: '✨',
                          title: 'Strengths',
                          subtitle: 'Know your power',
                          color: AppTheme.lavender,
                          delay: 100,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const StrengthsScreen()),
                          ),
                        ),
                        _GardenCard(
                          emoji: '📖',
                          title: 'Journal',
                          subtitle: 'Your daily story',
                          color: AppTheme.sky,
                          delay: 200,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const JournalScreen()),
                          ),
                        ),
                        _GardenCard(
                          emoji: '🌻',
                          title: 'Friends',
                          subtitle: 'Your garden crew',
                          color: AppTheme.blush,
                          delay: 300,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FriendsScreen()),
                          ).then((_) => _loadFriends()),
                        ),
                      ],
                    ),
                  ),

                  // Today's date
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Center(
                      child: Text(
                        _todayString(),
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: AppTheme.sage,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _todayString() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

// ─── Garden Card ─────────────────────────────────────────────────────────────

class _GardenCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final int delay;
  final VoidCallback onTap;

  const _GardenCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_GardenCard> createState() => _GardenCardState();
}

class _GardenCardState extends State<_GardenCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: widget.color.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 36)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.deepGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: AppTheme.deepGreen.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: widget.delay + 600))
            .slideY(begin: 0.2),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../services/app_theme.dart';
// import '../services/api_service.dart';
// import 'gratitude_screen.dart';
// import 'strengths_screen.dart';
// import 'journal_screen.dart';
// import 'friends_screen.dart';
// import 'message_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   List<Map<String, dynamic>> _friends = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadFriends();
//   }

//   Future<void> _loadFriends() async {
//     try {
//       final friends = await ApiService.getFriends();
//       setState(() => _friends = friends);
//     } catch (_) {}
//   }
//   Future<void> testMessage() async {
//   final user = FirebaseAuth.instance.currentUser;
//   final token = await user!.getIdToken();

//   final response = await http.post(
//     Uri.parse("https://your-api.onrender.com/messages"),
//     headers: {
//       "Authorization": "Bearer $token",
//       "Content-Type": "application/json",
//     },
//     body: jsonEncode({
//       "friend_id": "test_friend",
//       "content": "Hello from test",
//       "from_me": true
//     }),
//   );

//   print("STATUS: ${response.statusCode}");
//   print("BODY: ${response.body}");
// }

//   void _openQuickMessage(BuildContext context) async {
//     if (_friends.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Add some friends first! 🌱')),
//       );
//       return;
//     }
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppTheme.cream,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (ctx) => Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Send a message to...', style: GoogleFonts.playfairDisplay(
//               fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.deepGreen,
//             )),
//             const SizedBox(height: 16),
//             ...(_friends.map((f) => ListTile(
//               leading: CircleAvatar(
//                 backgroundColor: AppTheme.sage.withOpacity(0.2),
//                 child: Text(f['emoji'] ?? '🌱', style: const TextStyle(fontSize: 20)),
//               ),
//               title: Text(f['name'] ?? '', style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
//               onTap: () {
//                 Navigator.pop(ctx);
//                 Navigator.push(context, MaterialPageRoute(
//                   builder: (_) => MessageScreen(friend: f),
//                 )).then((_) => _loadFriends());
//               },
//             ))),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           ElevatedButton(
//   onPressed: testMessage,
//   child: Text("Test Message"),
// ),
//           // Background decoration
//           Positioned(
//             top: -80, right: -60,
//             child: Container(
//               width: 280, height: 280,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppTheme.sage.withOpacity(0.12),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 100, left: -80,
//             child: Container(
//               width: 220, height: 220,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppTheme.terracotta.withOpacity(0.08),
//               ),
//             ),
//           ),

//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 32),

//                   // Header
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('🌿', style: const TextStyle(fontSize: 32))
//                               .animate().fadeIn(duration: 600.ms).scale(),
//                           const SizedBox(height: 4),
//                           Text(
//                             'My Garden',
//                             style: GoogleFonts.playfairDisplay(
//                               fontSize: 38,
//                               fontWeight: FontWeight.w800,
//                               color: AppTheme.deepGreen,
//                             ),
//                           ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
//                           Text(
//                             'Your personal sanctuary',
//                             style: GoogleFonts.lato(
//                               fontSize: 14,
//                               color: AppTheme.sage,
//                               letterSpacing: 0.5,
//                             ),
//                           ).animate().fadeIn(delay: 400.ms),
//                         ],
//                       ),
//                       // Quick message button
//                       GestureDetector(
//                         onTap: () => _openQuickMessage(context),
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: AppTheme.deepGreen,
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: AppTheme.deepGreen.withOpacity(0.3),
//                                 blurRadius: 12, offset: const Offset(0, 4),
//                               )
//                             ],
//                           ),
//                           child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
//                         ),
//                       ).animate().fadeIn(delay: 400.ms).scale(),
//                     ],
//                   ),

//                   const SizedBox(height: 40),

//                   // Grid of buttons
//                   Expanded(
//                     child: GridView.count(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 16,
//                       mainAxisSpacing: 16,
//                       children: [
//                         _GardenCard(
//                           emoji: '🙏',
//                           title: 'Gratitude',
//                           subtitle: 'Count your blessings',
//                           color: AppTheme.gold,
//                           delay: 0,
//                           onTap: () => Navigator.push(context,
//                             MaterialPageRoute(builder: (_) => const GratitudeScreen()),
//                           ),
//                         ),
//                         _GardenCard(
//                           emoji: '✨',
//                           title: 'Strengths',
//                           subtitle: 'Know your power',
//                           color: AppTheme.lavender,
//                           delay: 100,
//                           onTap: () => Navigator.push(context,
//                             MaterialPageRoute(builder: (_) => const StrengthsScreen()),
//                           ),
//                         ),
//                         _GardenCard(
//                           emoji: '📖',
//                           title: 'Journal',
//                           subtitle: 'Your daily story',
//                           color: AppTheme.sky,
//                           delay: 200,
//                           onTap: () => Navigator.push(context,
//                             MaterialPageRoute(builder: (_) => const JournalScreen()),
//                           ),
//                         ),
//                         _GardenCard(
//                           emoji: '🌻',
//                           title: 'Friends',
//                           subtitle: 'Your garden crew',
//                           color: AppTheme.blush,
//                           delay: 300,
//                           onTap: () => Navigator.push(context,
//                             MaterialPageRoute(builder: (_) => const FriendsScreen()),
//                           ).then((_) => _loadFriends()),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Today's date
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 24),
//                     child: Center(
//                       child: Text(
//                         _todayString(),
//                         style: GoogleFonts.lato(
//                           fontSize: 13,
//                           color: AppTheme.sage,
//                           letterSpacing: 1,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _todayString() {
//     final now = DateTime.now();
//     const months = [
//       'January', 'February', 'March', 'April', 'May', 'June',
//       'July', 'August', 'September', 'October', 'November', 'December'
//     ];
//     return '${months[now.month - 1]} ${now.day}, ${now.year}';
//   }
// }

// class _GardenCard extends StatefulWidget {
//   final String emoji;
//   final String title;
//   final String subtitle;
//   final Color color;
//   final int delay;
//   final VoidCallback onTap;

//   const _GardenCard({
//     required this.emoji,
//     required this.title,
//     required this.subtitle,
//     required this.color,
//     required this.delay,
//     required this.onTap,
//   });

//   @override
//   State<_GardenCard> createState() => _GardenCardState();
// }

// class _GardenCardState extends State<_GardenCard> {
//   bool _pressed = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => setState(() => _pressed = true),
//       onTapUp: (_) => setState(() => _pressed = false),
//       onTapCancel: () => setState(() => _pressed = false),
//       onTap: widget.onTap,
//       child: AnimatedScale(
//         scale: _pressed ? 0.95 : 1.0,
//         duration: const Duration(milliseconds: 120),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: widget.color.withOpacity(0.18),
//             borderRadius: BorderRadius.circular(24),
//             border: Border.all(color: widget.color.withOpacity(0.4), width: 1.5),
//             boxShadow: [
//               BoxShadow(
//                 color: widget.color.withOpacity(0.15),
//                 blurRadius: 16,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(widget.emoji, style: const TextStyle(fontSize: 36)),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.title,
//                     style: GoogleFonts.playfairDisplay(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                       color: AppTheme.deepGreen,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     widget.subtitle,
//                     style: GoogleFonts.lato(
//                       fontSize: 12,
//                       color: AppTheme.deepGreen.withOpacity(0.65),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ).animate().fadeIn(delay: Duration(milliseconds: widget.delay + 600)).slideY(begin: 0.2),
//       ),
//     );
//   }
// }
