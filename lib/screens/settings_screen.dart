import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';
import 'package:cassiel_drive/core/constants/app_constants.dart';
import 'package:cassiel_drive/providers/theme_provider.dart';
import 'package:cassiel_drive/providers/auth_provider.dart';
import 'package:cassiel_drive/widgets/glass_card.dart';
import 'package:cassiel_drive/core/utils/pdf_guide_generator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = const FlutterSecureStorage();
  final _clientIdController = TextEditingController();
  final _clientSecretController = TextEditingController();
  final _chunkSizeController = TextEditingController();
  final _maxThreadsController = TextEditingController();
  bool _obscureClientId = true;
  bool _obscureClientSecret = true;
  bool _credentialsSaved = false;
  bool _isAddingAccount = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _clientIdController.text =
        await _storage.read(key: AppConstants.clientIdKey) ?? '';
    _clientSecretController.text =
        await _storage.read(key: AppConstants.clientSecretKey) ?? '';
    _chunkSizeController.text =
        await _storage.read(key: AppConstants.chunkSizeKey) ?? '100';
    _maxThreadsController.text =
        await _storage.read(key: AppConstants.maxThreadsKey) ?? '5';
    _credentialsSaved = _clientIdController.text.isNotEmpty &&
        _clientSecretController.text.isNotEmpty;
    if (mounted) setState(() {});
  }

  Future<void> _saveSettings() async {
    await _storage.write(
        key: AppConstants.clientIdKey, value: _clientIdController.text.trim());
    await _storage.write(
        key: AppConstants.clientSecretKey,
        value: _clientSecretController.text.trim());
    await _storage.write(
        key: AppConstants.chunkSizeKey, value: _chunkSizeController.text);
    await _storage.write(
        key: AppConstants.maxThreadsKey, value: _maxThreadsController.text);
    setState(() {
      _credentialsSaved = _clientIdController.text.trim().isNotEmpty &&
          _clientSecretController.text.trim().isNotEmpty;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved'),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String? _validateClientId(String value) {
    if (value.isEmpty) return null;
    if (!value.endsWith('.apps.googleusercontent.com')) {
      return 'Must end with .apps.googleusercontent.com';
    }
    return null;
  }

  String? _validateClientSecret(String value) {
    if (value.isEmpty) return null;
    if (value.length < 10) return 'Secret seems too short';
    return null;
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _clientSecretController.dispose();
    _chunkSizeController.dispose();
    _maxThreadsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Theme.of(context).primaryColor.withAlpha(isDark ? 30 : 18),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(13)
                              : Colors.black.withAlpha(10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.arrow_back_rounded,
                            color: isDark ? Colors.white70 : Colors.black54,
                            size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Settings',
                        style: Theme.of(context).textTheme.headlineLarge),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Theme toggle and Colors
              GlassCard(
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                          isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Dark Mode',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text(isDark ? 'ON' : 'OFF',
                              style: Theme.of(context).textTheme.bodySmall),
                        ])),
                    Switch.adaptive(
                      value: isDark,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      activeTrackColor: Theme.of(context).primaryColor,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.palette_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text('Accent Color',
                          style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: themeProvider.availableColors.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final color = themeProvider.availableColors[index];
                        final isSelected = color.toARGB32() ==
                            themeProvider.primaryColor.toARGB32();
                        return GestureDetector(
                          onTap: () => themeProvider.setPrimaryColor(color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutCubic,
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : Border.all(
                                      color: Colors.transparent, width: 3),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                          color: color.withAlpha(128),
                                          blurRadius: 10)
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ]),
              ),

              // Google Credentials section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(children: [
                  Icon(Icons.key_rounded,
                      size: 18, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text('Google Credentials',
                      style: Theme.of(context).textTheme.titleLarge),
                  if (_credentialsSaved) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Active',
                          style: TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ]),
              ),

              GlassCard(
                child: Column(children: [
                  Text(
                    'Enter your Google Cloud Console OAuth 2.0 credentials to connect Google Drive accounts.',
                    style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black45,
                        height: 1.4),
                  ),
                  const SizedBox(height: 12),

                  // Setup wizard + PDF guide buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final uri = Uri.parse(
                                  'https://cassieldrive.vercel.app/setup/');
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            },
                            icon: Icon(Icons.rocket_launch_rounded,
                                size: 16,
                                color: Theme.of(context).primaryColor),
                            label: Text('Setup Wizard',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withAlpha(77)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ),
                      if (!kIsWeb) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final success =
                                    await PdfGuideGenerator.generateAndOpen();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success
                                          ? 'PDF saved to Downloads folder'
                                          : 'Failed to generate PDF — check storage permissions'),
                                      backgroundColor: success
                                          ? AppColors.success
                                          : AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(Icons.picture_as_pdf_rounded,
                                  size: 16,
                                  color: Theme.of(context).primaryColor),
                              label: Text('PDF Guide',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).primaryColor)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withAlpha(77)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _clientIdController,
                    obscureText: _obscureClientId,
                    decoration: InputDecoration(
                      labelText: 'Client ID',
                      prefixIcon: const Icon(Icons.badge_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscureClientId
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 18),
                        onPressed: () =>
                            setState(() => _obscureClientId = !_obscureClientId),
                      ),
                      errorText:
                          _validateClientId(_clientIdController.text.trim()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _clientSecretController,
                    obscureText: _obscureClientSecret,
                    decoration: InputDecoration(
                      labelText: 'Client Secret',
                      prefixIcon: const Icon(Icons.lock_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscureClientSecret
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 18),
                        onPressed: () => setState(
                            () => _obscureClientSecret = !_obscureClientSecret),
                      ),
                      errorText: _validateClientSecret(
                          _clientSecretController.text.trim()),
                    ),
                  ),
                ]),
              ),

              // Add Google Account button (only if credentials saved)
              if (_credentialsSaved)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed:
                          _isAddingAccount ? null : () => _addGoogleAccount(context),
                      icon: _isAddingAccount
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Center(
                                  child: Text('G',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .primaryColor))),
                            ),
                      label: Text(_isAddingAccount
                          ? 'Authenticating...'
                          : 'Add Google Account'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Theme.of(context)
                                .primaryColor
                                .withAlpha(77)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),

              // Upload settings
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(children: [
                  Icon(Icons.upload_rounded,
                      size: 18, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text('Upload Config',
                      style: Theme.of(context).textTheme.titleLarge),
                ]),
              ),

              GlassCard(
                child: Column(children: [
                  TextField(
                    controller: _chunkSizeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Chunk Size (MB)',
                        prefixIcon: Icon(Icons.storage_rounded, size: 20)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _maxThreadsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Max Upload Threads',
                        prefixIcon: Icon(Icons.speed_rounded, size: 20)),
                  ),
                ]),
              ),
              const SizedBox(height: 20),

              // Save button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Save Settings',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),

              // App info
              const SizedBox(height: 32),
              Center(
                  child: Column(children: [
                Text(AppConstants.appName,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .primaryColor
                            .withAlpha(128))),
                const SizedBox(height: 4),
                Text('v${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.bodySmall),
              ])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addGoogleAccount(BuildContext context) async {
    setState(() => _isAddingAccount = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(kIsWeb
            ? 'Opening authentication popup...'
            : 'Opening browser for Google Sign-In...'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.addAccount();

    if (context.mounted) {
      setState(() => _isAddingAccount = false);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Google account added successfully!'
              : 'Failed to add account. Make sure:\n• Client ID type is "Desktop app"\n• Your email is added as a test user\n• You completed the consent screen'),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: success ? 3 : 6),
        ),
      );
    }
  }
}
