import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';
import 'package:cassiel_drive/core/utils/utils.dart';
import 'package:cassiel_drive/providers/auth_provider.dart';
import 'package:cassiel_drive/providers/storage_provider.dart';
import 'package:cassiel_drive/screens/settings_screen.dart';
import 'package:cassiel_drive/widgets/glass_card.dart';
import 'package:cassiel_drive/widgets/storage_bar.dart';
import 'package:cassiel_drive/widgets/galaxy_storage_widget.dart';
import 'package:cassiel_drive/widgets/themed_logo.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final storageProvider = context.watch<StorageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = storageProvider.getAggregateStats();
    final categoryStats = storageProvider.categoryStats;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await authProvider.refreshAccounts();
            await storageProvider.loadFiles();
          },
          color: Theme.of(context).primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SizedBox(height: 16),

                // Header — Orion Store style
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: logo image + settings
                      Row(
                        children: [
                          ThemedLogo(
                            height: 32,
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withAlpha(10)
                                  : Colors.black.withAlpha(8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.settings_rounded,
                                color: isDark ? Colors.white60 : Colors.black54,
                                size: 22,
                              ),
                              onPressed: () => Navigator.of(context).push(
                                CupertinoPageRoute<void>(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // User greeting — uses stored username
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          Text(
                            'Hi ',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                isDark
                                    ? Colors.white
                                    : const Color(0xFF2D3436),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              authProvider.username,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Storage Overview Cards
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _buildStatCard(
                        context,
                        'Total Accounts',
                        '${stats['totalAccounts'] ?? 0}',
                        Icons.people_rounded,
                        Theme.of(context).primaryColor,
                      ),
                      _buildStatCard(
                        context,
                        'Total Storage',
                        FileUtils.formatFileSize(stats['totalStorage'] ?? 0),
                        Icons.storage_rounded,
                        AppColors.accentGlow,
                      ),
                      _buildStatCard(
                        context,
                        'Used',
                        FileUtils.formatFileSize(stats['totalUsed'] ?? 0),
                        Icons.pie_chart_rounded,
                        AppColors.warning,
                      ),
                      _buildStatCard(
                        context,
                        'Free',
                        FileUtils.formatFileSize(stats['totalFree'] ?? 0),
                        Icons.cloud_done_rounded,
                        AppColors.success,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Overall Storage Bar
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Storage',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      StorageBar(
                        usedPercentage: (stats['overallUsage'] as double?) ?? 0.0,
                        usedLabel: FileUtils.formatFileSize(
                            stats['totalUsed'] ?? 0),
                        totalLabel: FileUtils.formatFileSize(
                            stats['totalStorage'] ?? 0),
                        height: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Galaxy Storage Visualization
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Storage Galaxy',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${storageProvider.filesOnly.length} files',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RepaintBoundary(
                        child: Center(
                          child: GalaxyStorageWidget(
                            categoryStats: categoryStats,
                            totalFiles: storageProvider.filesOnly.length,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLegend(context, categoryStats),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Category breakdown
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'File Categories',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ...categoryStats.entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: FileUtils.getCategoryColor(e.key)
                                        .withAlpha(26),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    FileUtils.getCategoryIcon(e.key),
                                    color:
                                        FileUtils.getCategoryColor(e.key),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                                Text(
                                  '${e.value} files',
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(13)
                  : Colors.white.withAlpha(179),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.white.withAlpha(128),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(
      BuildContext context, Map<String, int> categoryStats) {
    final categories = ['Images', 'Videos', 'Documents', 'Audio', 'Archives', 'Code'];
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categories.map((cat) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FileUtils.getCategoryColor(cat),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              cat,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : Colors.black45,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
