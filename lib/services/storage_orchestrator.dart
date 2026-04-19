import 'package:cassiel_drive/models/drive_account.dart';
import 'package:cassiel_drive/core/constants/app_constants.dart';

class StorageOrchestrator {
  static final StorageOrchestrator _instance = StorageOrchestrator._internal();
  factory StorageOrchestrator() => _instance;
  StorageOrchestrator._internal();

  /// Score algorithm:
  /// score = (free_space_ratio × 0.6) + (api_health × 0.3) + (usage_balance × 0.1)
  double calculateScore(DriveAccount account, List<DriveAccount> allAccounts) {
    final freeSpaceRatio = account.storageTotal > 0
        ? account.storageFree / account.storageTotal
        : 0.0;

    final healthScore = account.healthScore;

    // Usage balance: how evenly distributed usage is
    final avgUsage = allAccounts.isNotEmpty
        ? allAccounts.fold<double>(
                0.0, (sum, a) => sum + a.usagePercentage) /
            allAccounts.length
        : 0.0;
    final usageBalance =
        1.0 - (account.usagePercentage - avgUsage).abs().clamp(0.0, 1.0);

    return (freeSpaceRatio * AppConstants.freeSpaceWeight) +
        (healthScore * AppConstants.apiHealthWeight) +
        (usageBalance * AppConstants.usageBalanceWeight);
  }

  /// Select the best drive for upload based on scoring
  DriveAccount selectBestDrive(List<DriveAccount> accounts) {
    if (accounts.isEmpty) throw Exception('No accounts available');
    if (accounts.length == 1) return accounts.first;

    DriveAccount bestAccount = accounts.first;
    double bestScore = -1;

    for (final account in accounts) {
      if (!account.isActive) continue;
      final score = calculateScore(account, accounts);
      if (score > bestScore) {
        bestScore = score;
        bestAccount = account;
      }
    }

    return bestAccount;
  }

  /// Get scores for all accounts (for UI display)
  Map<String, double> getAllScores(List<DriveAccount> accounts) {
    final scores = <String, double>{};
    for (final account in accounts) {
      scores[account.id] = calculateScore(account, accounts);
    }
    return scores;
  }

  /// Distribute chunks across drives optimally
  List<DriveAccount> distributeChunks(
      List<DriveAccount> accounts, int totalChunks) {
    if (accounts.isEmpty) return [];

    final distribution = <DriveAccount>[];
    final scores = getAllScores(accounts);

    // Sort by score descending
    final sortedAccounts = List<DriveAccount>.from(accounts)
      ..sort((a, b) =>
          (scores[b.id] ?? 0).compareTo(scores[a.id] ?? 0));

    // Round-robin weighted by score
    for (int i = 0; i < totalChunks; i++) {
      distribution.add(sortedAccounts[i % sortedAccounts.length]);
    }

    return distribution;
  }

  /// Get aggregate storage stats
  Map<String, dynamic> getAggregateStats(List<DriveAccount> accounts) {
    int totalStorage = 0;
    int totalUsed = 0;

    for (final account in accounts) {
      totalStorage += account.storageTotal;
      totalUsed += account.storageUsed;
    }

    return {
      'totalAccounts': accounts.length,
      'totalStorage': totalStorage,
      'totalUsed': totalUsed,
      'totalFree': totalStorage - totalUsed,
      'overallUsage':
          totalStorage > 0 ? totalUsed / totalStorage : 0.0,
    };
  }
}
