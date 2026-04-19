import 'package:flutter/material.dart';
import 'package:cassiel_drive/services/upload_manager.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';
import 'package:cassiel_drive/core/utils/utils.dart';
import 'package:cassiel_drive/widgets/glass_card.dart';

class UploadProgressCard extends StatelessWidget {
  final UploadTask task;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onRemove;

  const UploadProgressCard({
    super.key,
    required this.task,
    this.onCancel,
    this.onRetry,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status icon
              _buildStatusIcon(context),
              const SizedBox(width: 12),

              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.fileName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${FileUtils.formatFileSize(task.fileSize)} • ${task.strategy} upload',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                    ),
                  ],
                ),
              ),

              // Action button
              _buildActionButton(context),
            ],
          ),

          if (task.status == UploadStatus.uploading) ...[
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: task.progress,
                backgroundColor: isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.black.withAlpha(15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(task.progress * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          if (task.error != null) ...[
            const SizedBox(height: 8),
            Text(
              task.error!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (task.chunks.isNotEmpty && task.status == UploadStatus.uploading) ...[
            const SizedBox(height: 8),
            Text(
              'Chunks: ${task.chunks.where((c) => c.isCompleted).length}/${task.chunks.length}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    switch (task.status) {
      case UploadStatus.queued:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.schedule_rounded,
              color: Colors.grey, size: 20),
        );
      case UploadStatus.uploading:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
      case UploadStatus.completed:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 20),
        );
      case UploadStatus.failed:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.error.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.error_rounded,
              color: AppColors.error, size: 20),
        );
      case UploadStatus.cancelled:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.cancel_rounded,
              color: Colors.orange, size: 20),
        );
    }
  }

  Widget _buildActionButton(BuildContext context) {
    switch (task.status) {
      case UploadStatus.uploading:
      case UploadStatus.queued:
        return IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          onPressed: onCancel,
          color: Colors.white54,
        );
      case UploadStatus.failed:
        return IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 20),
          onPressed: onRetry,
          color: Theme.of(context).primaryColor,
        );
      case UploadStatus.completed:
      case UploadStatus.cancelled:
        return IconButton(
          icon: const Icon(Icons.close_rounded, size: 18),
          onPressed: onRemove,
          color: Colors.white38,
        );
    }
  }
}
