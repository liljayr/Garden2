import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _isRegister = false;
  String? _error;

  Future<void> _submit() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final result = _isRegister
        ? await AuthService.register(username, password)
        : await AuthService.login(username, password);

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => _error = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),

              // Logo / title
              Center(
                child: Column(
                  children: [
                    const Text('🌿', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 12),
                    Text(
                      'My Garden',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.deepGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isRegister ? 'Create your account' : 'Welcome back',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: AppTheme.sage,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Username
              _label('Username'),
              const SizedBox(height: 8),
              _field(
                controller: _usernameCtrl,
                hint: 'your_name',
                icon: Icons.person_outline_rounded,
              ),

              const SizedBox(height: 20),

              // Password
              _label('Password'),
              const SizedBox(height: 8),
              _field(
                controller: _passwordCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: true,
              ),

              // Error
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.terracotta.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          color: AppTheme.terracotta, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: GoogleFonts.lato(
                                color: AppTheme.terracotta, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _isRegister ? 'Create Account' : 'Sign In',
                          style: GoogleFonts.lato(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Toggle register / login
              Center(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isRegister = !_isRegister;
                    _error = null;
                  }),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.lato(
                          fontSize: 14, color: AppTheme.sage),
                      children: [
                        TextSpan(
                          text: _isRegister
                              ? 'Already have an account? '
                              : "Don't have an account? ",
                        ),
                        TextSpan(
                          text: _isRegister ? 'Sign in' : 'Register',
                          style: GoogleFonts.lato(
                            color: AppTheme.deepGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.lato(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.deepGreen,
            letterSpacing: 0.5),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textInputAction:
          obscure ? TextInputAction.done : TextInputAction.next,
      onSubmitted: obscure ? (_) => _submit() : null,
      style: GoogleFonts.lato(fontSize: 15, color: AppTheme.deepGreen),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lato(color: Colors.grey[400]),
        prefixIcon:
            Icon(icon, color: AppTheme.sage, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.sage.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.sage.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: AppTheme.deepGreen, width: 1.5),
        ),
      ),
    );
  }
}
