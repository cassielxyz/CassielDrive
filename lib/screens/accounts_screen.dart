import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';
import 'package:cassiel_drive/providers/auth_provider.dart';
import 'package:cassiel_drive/services/storage_orchestrator.dart';

import 'package:cassiel_drive/widgets/account_tile.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final orchestrator = StorageOrchestrator();
    final accounts = authProvider.accounts;
    final scores = orchestrator.getAllScores(accounts);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Accounts', style: Theme.of(context).textTheme.headlineLarge),
                ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${accounts.length} connected account${accounts.length != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: accounts.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.person_add_rounded, size: 64, color: Colors.white.withAlpha(51)),
                      const SizedBox(height: 16),
                      Text('No accounts connected', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white.withAlpha(77))),
                      const SizedBox(height: 8),
                      Text('Add a Google account to get started', style: Theme.of(context).textTheme.bodySmall),
                    ]))
                  : ListView.builder(
                      itemCount: accounts.length,
                      padding: const EdgeInsets.only(bottom: 100),
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        return AccountTile(
                          account: account,
                          score: scores[account.id],
                          onRemove: () => _confirmRemove(context, account.id, account.email),
                        );
                      },
                    ),
            ),
          ],
        ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          onPressed: () => context.read<AuthProvider>().addAccount(),
          backgroundColor: Theme.of(context).primaryColor,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Add Account', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, String accountId, String email) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Remove Account'),
      content: Text('Remove $email from Cassiel Drive?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () { context.read<AuthProvider>().removeAccount(accountId); Navigator.pop(ctx); },
          child: const Text('Remove', style: TextStyle(color: AppColors.error))),
      ],
    ));
  }
}
