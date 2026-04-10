import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_theme.dart';
import '../services/api_service.dart';

class StrengthsScreen extends StatefulWidget {
  const StrengthsScreen({super.key});

  @override
  State<StrengthsScreen> createState() => _StrengthsScreenState();
}

class _StrengthsScreenState extends State<StrengthsScreen> {
  List<Map<String, dynamic>> _strengths = [];
  bool _loading = false;
  bool _saving = false;
  final _newStrengthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final s = await ApiService.getStrengths();
      setState(() => _strengths = s);
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ApiService.updateStrengths(_strengths);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Strengths saved! ✨')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save')),
      );
    }
    setState(() => _saving = false);
  }

  Future<void> _addCustom() async {
    if (_newStrengthController.text.trim().isEmpty) return;
    try {
      final s = await ApiService.addStrength(_newStrengthController.text.trim());
      setState(() => _strengths.add(s));
      _newStrengthController.clear();
      Navigator.pop(context);
    } catch (_) {}
  }

  void _toggleStrength(int index) {
    setState(() {
      _strengths[index] = {
        ..._strengths[index],
        'selected': !(_strengths[index]['selected'] ?? false),
      };
    });
  }

  void _showAddCustom() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Your Own Strength', style: GoogleFonts.playfairDisplay(
          color: AppTheme.deepGreen, fontWeight: FontWeight.w700,
        )),
        content: TextField(
          controller: _newStrengthController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Resilience'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.lato(color: AppTheme.sage)),
          ),
          ElevatedButton(
            onPressed: _addCustom,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _selected =>
      _strengths.where((s) => s['selected'] == true).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Strengths'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _showAddCustom,
            icon: const Icon(Icons.add_rounded, color: AppTheme.deepGreen),
            label: Text('Custom', style: GoogleFonts.lato(color: AppTheme.deepGreen)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Selected count banner
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lavender.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.lavender.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selected.isEmpty
                              ? 'Select your strengths below'
                              : 'You have ${_selected.length} strengths: ${_selected.take(3).map((s) => s['name']).join(', ')}${_selected.length > 3 ? '...' : ''}',
                          style: GoogleFonts.lato(
                            fontSize: 14, color: AppTheme.deepGreen, fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: _strengths.length,
                    itemBuilder: (ctx, i) {
                      final s = _strengths[i];
                      final selected = s['selected'] == true;
                      return GestureDetector(
                        onTap: () => _toggleStrength(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.deepGreen
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected ? AppTheme.deepGreen : AppTheme.sage.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: selected ? [
                              BoxShadow(
                                color: AppTheme.deepGreen.withOpacity(0.2),
                                blurRadius: 8, offset: const Offset(0, 3),
                              )
                            ] : [],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                                color: selected ? Colors.white : AppTheme.sage,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s['name'] ?? '',
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? Colors.white : AppTheme.deepGreen,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: Duration(milliseconds: i * 30)),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_rounded),
                      label: const Text('Save My Strengths'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
