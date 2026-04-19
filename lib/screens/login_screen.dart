import 'package:flutter/material.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';
import 'package:cassiel_drive/core/constants/app_constants.dart';
import 'package:cassiel_drive/widgets/glass_card.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:cassiel_drive/providers/auth_provider.dart';
import 'package:cassiel_drive/widgets/themed_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _usernameController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    Theme.of(context).primaryColor.withAlpha(26),
                    bgColor,
                  ],
                ),
              ),
            ),
          ),

          // Decorative particles
          ..._buildParticles(size),

          // Main content
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        ThemedLogo(
                          width: 180,
                        ),
                        const SizedBox(height: 28),

                        // Title
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [Theme.of(context).primaryColor, AppColors.accentGlow],
                          ).createShader(bounds),
                          child: const Text(
                            'Cassiel Drive',
                            style: TextStyle(
                              fontFamily: 'Inter', fontSize: 32,
                              fontWeight: FontWeight.bold, color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Set up your profile to get started',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 15,
                            color: isDark ? Colors.white.withAlpha(128) : Colors.black.withAlpha(128), height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Username input card
                        GlassCard(
                          margin: EdgeInsets.zero,

                          borderRadius: 18,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              TextField(
                                controller: _usernameController,
                                style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                                decoration: InputDecoration(
                                  hintText: 'Enter your name',
                                  hintStyle: TextStyle(color: isDark ? Colors.white.withAlpha(77) : Colors.black.withAlpha(77)),
                                  prefixIcon: Icon(Icons.person_rounded, color: Theme.of(context).primaryColor),
                                  filled: true,
                                  fillColor: Colors.white.withAlpha(10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: Colors.white.withAlpha(26)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: Colors.white.withAlpha(26)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                onSubmitted: (_) => _handleContinue(),
                              ),
                              const SizedBox(height: 20),

                              // Continue button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleContinue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(width: 22, height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text('Continue',
                                          style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),

                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Features hint
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeature(Icons.account_circle_rounded, 'Multi\nAccount'),
                            _buildFeature(Icons.security_rounded, 'Encrypted\nVault'),
                            _buildFeature(Icons.speed_rounded, '10× Faster\nUploads'),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Hint
                        Text(
                          'You can add Google accounts later\nin Settings with your Client ID & Secret',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 12,
                            color: isDark ? Colors.white.withAlpha(77) : Colors.black.withAlpha(110), height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles(Size size) {
    return List.generate(5, (i) {
      final positions = [
        Offset(size.width * 0.1, size.height * 0.15),
        Offset(size.width * 0.85, size.height * 0.2),
        Offset(size.width * 0.15, size.height * 0.75),
        Offset(size.width * 0.9, size.height * 0.8),
        Offset(size.width * 0.5, size.height * 0.1),
      ];
      final sizes = [30.0, 20.0, 25.0, 15.0, 35.0];
      return Positioned(
        left: positions[i].dx, top: positions[i].dy,
        child: Container(width: sizes[i], height: sizes[i],
          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor.withAlpha(13))),
      );
    });
  }

  Widget _buildFeature(IconData icon, String label) {
    return Column(children: [
      Container(width: 48, height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withAlpha(20), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).primaryColor.withAlpha(51))),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 22)),
      const SizedBox(height: 8),
      Text(label, textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withAlpha(128)
              : Colors.black.withAlpha(140),
          height: 1.3,
        )),
    ]);
  }

  Future<void> _handleContinue() async {
    final username = _usernameController.text.trim();
    final authProvider = context.read<AuthProvider>();
    if (username.isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      await _storage.write(key: AppConstants.usernameKey, value: username);
      await authProvider.setUsername(username);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() { _error = 'Error: $e'; _isLoading = false; });
    }
  }
}
