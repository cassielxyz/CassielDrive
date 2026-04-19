import 'package:flutter/material.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';
import 'package:cassiel_drive/services/encryption_service.dart';
import 'package:cassiel_drive/widgets/glass_card.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen>
    with SingleTickerProviderStateMixin {
  final EncryptionService _encryptionService = EncryptionService();
  final TextEditingController _passwordController = TextEditingController();
  bool _isUnlocked = false;
  bool _isLoading = false;
  bool _isConfigured = false;
  bool _obscurePassword = true;
  String? _error;

  late AnimationController _lockAnimController;
  late Animation<double> _lockAnimation;

  @override
  void initState() {
    super.initState();
    _lockAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _lockAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lockAnimController, curve: Curves.elasticOut),
    );
    _checkVaultStatus();
  }

  Future<void> _checkVaultStatus() async {
    _isConfigured = await _encryptionService.isVaultConfigured();
    setState(() {});
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _lockAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _isUnlocked ? _buildUnlockedVault(context) : _buildLockedVault(context),
      ),
    );
  }

  Widget _buildLockedVault(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lock icon with glow
            AnimatedBuilder(
              animation: _lockAnimation,
              builder: (context, child) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withAlpha(51),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor.withAlpha(51),
                          AppColors.darkCard.withAlpha(179),
                        ],
                      ),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withAlpha(51),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 44,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Title
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                  colors: [Theme.of(context).primaryColor, isDark ? Colors.white : Colors.black],
              ).createShader(bounds),
              child: const Text(
                'Cassiel Vault',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isConfigured
                  ? 'Enter your password to unlock'
                  : 'Create a password to set up your vault',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 36),

            // Password field
            GlassCard(
              margin: EdgeInsets.zero,

              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.key_rounded,
                          color: Theme.of(context).primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: isDark ? Colors.white38 : Colors.black38,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    onSubmitted: (_) => _handleUnlock(),
                  ),
                  const SizedBox(height: 20),

                  // Unlock button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleUnlock,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isConfigured ? 'Unlock' : 'Create Vault',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_rounded,
                    size: 14, color: Theme.of(context).primaryColor.withAlpha(128)),
                const SizedBox(width: 6),
                Text(
                  'AES-256 Encrypted',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockedVault(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 16),

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock_open_rounded,
                            color: AppColors.success, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Cassiel Vault',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your encrypted files',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _isUnlocked = false;
                  _passwordController.clear();
                }),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: AppColors.error, size: 20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Empty vault state
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.enhanced_encryption_rounded,
                    size: 64,
                    color: Theme.of(context).primaryColor.withAlpha(51)),
                const SizedBox(height: 16),
                Text(
                  'Vault is empty',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDark
                            ? Colors.white.withAlpha(77)
                            : Colors.black38,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Encrypted files will appear here',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleUnlock() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = 'Please enter a password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isConfigured) {
        final isValid =
            await _encryptionService.verifyVaultPassword(password);
        if (isValid) {
          _lockAnimController.forward();
          setState(() {
            _isUnlocked = true;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Incorrect password';
            _isLoading = false;
          });
        }
      } else {
        await _encryptionService.storeVaultPasswordHash(password);
        _lockAnimController.forward();
        setState(() {
          _isUnlocked = true;
          _isConfigured = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }
}
