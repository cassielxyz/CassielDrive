import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';
import 'package:cassiel_drive/core/utils/utils.dart';
import 'package:cassiel_drive/providers/auth_provider.dart';
import 'package:cassiel_drive/providers/storage_provider.dart';
import 'package:cassiel_drive/widgets/glass_card.dart';
import 'package:cassiel_drive/widgets/storage_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final storage = context.watch<StorageProvider>();
    final user = auth.currentUser;
    final stats = storage.getAggregateStats();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Avatar
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).primaryColor.withAlpha(77), width: 3),
                  boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withAlpha(38), blurRadius: 20)],
                ),
                child: ClipOval(
                  child: user?.avatarUrl != null
                      ? CachedNetworkImage(imageUrl: user!.avatarUrl!, fit: BoxFit.cover,
                          placeholder: (_, _) => _avatarPlaceholder(isDark, context),
                          errorWidget: (_, _, _) => _avatarPlaceholder(isDark, context))
                      : _avatarPlaceholder(isDark, context),
                ),
              ),
              const SizedBox(height: 16),
              Text(user?.displayName ?? 'User',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(user?.email ?? '', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 28),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat(context, '${stats['totalAccounts'] ?? 0}', 'Accounts'),
                  _stat(context, FileUtils.formatFileSize(stats['totalUsed'] ?? 0), 'Used'),
                  _stat(context, FileUtils.formatFileSize(stats['totalFree'] ?? 0), 'Free'),
                ],
              ),
              const SizedBox(height: 24),

              // Storage overview
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Storage Overview', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    StorageBar(
                      usedPercentage: (stats['overallUsage'] as double?) ?? 0.0,
                      usedLabel: FileUtils.formatFileSize(stats['totalUsed'] ?? 0),
                      totalLabel: FileUtils.formatFileSize(stats['totalStorage'] ?? 0),
                    ),
                  ],
                ),
              ),

              // Connected accounts
              GlassCard(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Connected Accounts', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ...auth.accounts.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(children: [
                        CircleAvatar(radius: 16, backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
                          child: Icon(Icons.person, size: 16, color: Theme.of(context).primaryColor)),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(a.email, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          Text(a.storageUsedFormatted, style: Theme.of(context).textTheme.bodySmall),
                        ])),
                        Container(width: 8, height: 8,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                            color: a.healthScore >= 0.8 ? AppColors.success : AppColors.warning)),
                      ]),
                    )),
                  ],
                ),
              ),

              // Sign out
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(width: double.infinity, height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                    label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                      side: BorderSide(color: AppColors.error.withAlpha(isDark ? 51 : 77)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarPlaceholder(bool isDark, BuildContext context) => Container(
    color: Theme.of(context).primaryColor.withAlpha(51),
    child: Icon(Icons.person, size: 40, color: isDark ? Colors.white54 : Colors.black38));

  Widget _stat(BuildContext context, String value, String label) => Column(children: [
    Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
    const SizedBox(height: 4),
    Text(label, style: Theme.of(context).textTheme.bodySmall),
  ]);

  void _signOut(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Sign Out'),
      content: const Text('Sign out from all accounts?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () { context.read<AuthProvider>().signOut(); Navigator.pop(ctx);
          Navigator.of(context).pushReplacementNamed('/login'); },
          child: const Text('Sign Out', style: TextStyle(color: AppColors.error))),
      ],
    ));
  }
}
