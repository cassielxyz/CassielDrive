import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';
import 'package:cassiel_drive/core/constants/app_constants.dart';
import 'package:cassiel_drive/providers/auth_provider.dart';
import 'package:cassiel_drive/providers/storage_provider.dart';
import 'package:cassiel_drive/providers/theme_provider.dart';
import 'package:cassiel_drive/screens/splash_screen.dart';
import 'package:cassiel_drive/screens/login_screen.dart';
import 'package:cassiel_drive/screens/dashboard_screen.dart';
import 'package:cassiel_drive/screens/playground_screen.dart';
import 'package:cassiel_drive/screens/vault_screen.dart';
import 'package:cassiel_drive/screens/accounts_screen.dart';
import 'package:cassiel_drive/screens/profile_screen.dart';
import 'package:cassiel_drive/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open required Hive boxes before app starts
  await Hive.openBox(AppConstants.cacheBox);
  await Hive.openBox(AppConstants.settingsBox);

  // System UI (not applicable on web)
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
    ));
  }

  runApp(const CassielDriveApp());
}

class CassielDriveApp extends StatelessWidget {
  const CassielDriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => StorageProvider()..initialize()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isDark = themeProvider.themeMode == ThemeMode.dark;
          if (!kIsWeb) {
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
                systemNavigationBarColor:
                    isDark ? AppColors.darkBg : AppColors.lightBg,
                systemNavigationBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
              ),
            );
          }

          return MaterialApp(
            key: ValueKey(
              '${themeProvider.themeMode.name}_${themeProvider.primaryColor.toARGB32()}_${themeProvider.logoVariant.name}',
            ),
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(themeProvider.primaryColor),
            darkTheme: AppTheme.darkTheme(themeProvider.primaryColor),
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeShell(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late AnimationController _orbController;
  late final PageController _pageController;
  bool _isTabAnimating = false;

  @override
  void initState() {
    super.initState();
    _screens = const [
      DashboardScreen(),
      PlaygroundScreen(),
      VaultScreen(),
      AccountsScreen(),
      ProfileScreen(),
    ];
    _orbController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _orbController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Stack(
        children: [
          // Animated background orbs — visible through frosted glass
          RepaintBoundary(
            child: _AnimatedOrbBackground(controller: _orbController),
          ),

          // Screen content with non-overlapping page transitions.
          RepaintBoundary(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _currentIndex = index;
                });
              },
              children: _screens,
            ),
          ),

          // Bottom navigation — frosted glassmorphism pill
          Positioned(
            left: 0,
            right: 0,
            bottom: 76,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withAlpha(12)
                        : Colors.white.withAlpha(200),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withAlpha(10)
                          : Colors.black.withAlpha(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                        _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard'),
                      _buildNavItem(1, Icons.folder_rounded, 'Files'),
                      _buildNavItem(2, Icons.lock_rounded, 'Vault'),
                      _buildNavItem(3, Icons.people_rounded, 'Accounts'),
                      _buildNavItem(4, Icons.person_rounded, 'Profile'),
                    ],
                  ),
                ),
              ),
            ),
          ),
            ),
            ),
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () => _onTapNavItem(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withAlpha(isDark ? 222 : 242)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 21,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white38 : Colors.black38),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _onTapNavItem(int index) async {
    if (_currentIndex == index || _isTabAnimating) {
      return;
    }

    setState(() {
      _isTabAnimating = true;
      _currentIndex = index;
    });

    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 360),
      curve: Curves.fastOutSlowIn
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isTabAnimating = false;
    });
  }
}

class _AnimatedOrbBackground extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedOrbBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);
    final primary = Theme.of(context).primaryColor;
    final accent = HSLColor.fromColor(primary)
      .withSaturation((HSLColor.fromColor(primary).saturation * 0.7)
        .clamp(0.0, 1.0))
      .withLightness((HSLColor.fromColor(primary).lightness + 0.14)
        .clamp(0.0, 1.0))
      .toColor();

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                top: -40 + (t * 60),
                left: -30 + (t * 40),
                child: _Orb(
                  size: 220,
                  color: primary.withAlpha(isDark ? 50 : 30),
                ),
              ),
              Positioned(
                bottom: -60 + (t * 50),
                right: -40 + ((1 - t) * 30),
                child: _Orb(
                  size: 260,
                  color: accent.withAlpha(isDark ? 36 : 22),
                ),
              ),
              Positioned(
                top: screenSize.height * 0.4,
                left: screenSize.width * 0.3 + (t * 30),
                child: _Orb(
                  size: 120,
                  color: primary.withAlpha(isDark ? 25 : 15),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;

  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
