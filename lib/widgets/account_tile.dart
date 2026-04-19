import 'package:flutter/material.dart';
import 'package:cassiel_drive/models/drive_account.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';
import 'package:cassiel_drive/widgets/glass_card.dart';
import 'package:cassiel_drive/widgets/storage_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AccountTile extends StatelessWidget {
  final DriveAccount account;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final double? score;

  const AccountTile({
    super.key,
    required this.account,
    this.onTap,
    this.onRemove,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      onTap: onTap,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withAlpha(77),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withAlpha(26),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: account.avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: account.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            color: Theme.of(context).primaryColor.withAlpha(51),
                            child: const Icon(Icons.person,
                                color: Colors.white54, size: 24),
                          ),
                          errorWidget: (_, _, _) => Container(
                            color: Theme.of(context).primaryColor.withAlpha(51),
                            child: const Icon(Icons.person,
                                color: Colors.white54, size: 24),
                          ),
                        )
                      : Container(
                          color: Theme.of(context).primaryColor.withAlpha(51),
                          child: Icon(Icons.person,
                              color: isDark ? Colors.white54 : Colors.black45,
                              size: 24),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Account info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.displayName,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account.email,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color:
                                    isDark ? Colors.white54 : Colors.black45,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Health indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getHealthColor(account.healthScore).withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getHealthColor(account.healthScore),
                        boxShadow: [
                          BoxShadow(
                            color: _getHealthColor(account.healthScore)
                                .withAlpha(128),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _getHealthLabel(account.healthScore),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getHealthColor(account.healthScore),
                      ),
                    ),
                  ],
                ),
              ),

              if (onRemove != null)
                IconButton(
                  icon: Icon(Icons.remove_circle_outline,
                      color: AppColors.error.withAlpha(179), size: 20),
                  onPressed: onRemove,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Storage bar
          StorageBar(
            usedPercentage: account.usagePercentage,
            usedLabel: '${account.storageUsedFormatted} used',
            totalLabel: account.storageTotalFormatted,
          ),

          if (score != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.speed_rounded,
                    size: 14, color: Theme.of(context).primaryColor),
                const SizedBox(width: 4),
                Text(
                  'Score: ${(score! * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getHealthColor(double health) {
    if (health >= 0.8) return AppColors.success;
    if (health >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  String _getHealthLabel(double health) {
    if (health >= 0.8) return 'Good';
    if (health >= 0.5) return 'Fair';
    return 'Poor';
  }
}
