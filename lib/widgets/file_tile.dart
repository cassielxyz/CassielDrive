import 'package:flutter/material.dart';
import 'package:cassiel_drive/models/file_model.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';
import 'package:cassiel_drive/core/utils/utils.dart';
import 'package:cassiel_drive/widgets/glass_card.dart';

class FileTile extends StatelessWidget {
  final FileModel file;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;
  final VoidCallback? onDownload;
  final VoidCallback? onMove;

  const FileTile({
    super.key,
    required this.file,
    this.onTap,
    this.onDelete,
    this.onRename,
    this.onDownload,
    this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final category = FileUtils.getCategory(file.extension);
    final color = FileUtils.getCategoryColor(category);
    final icon = FileUtils.getCategoryIcon(category);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      onTap: onTap,
      child: Row(
        children: [
          // File icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withAlpha(51), width: 1),
            ),
            child: Icon(
              file.isFolder ? Icons.folder_rounded : icon,
              color: file.isFolder ? Theme.of(context).primaryColor : color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      file.isFolder ? 'Folder' : file.sizeFormatted,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                    ),
                    if (file.driveAccountEmail != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.cloud_outlined,
                          size: 12,
                          color: isDark ? Colors.white38 : Colors.black38),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          file.driveAccountEmail!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                    fontSize: 11,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions menu
          if (!file.isFolder)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: isDark ? Colors.white54 : Colors.black45,
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              color: isDark
                  ? const Color(0xFF1A1A2E)
                  : Colors.white,
              onSelected: (value) {
                switch (value) {
                  case 'download':
                    onDownload?.call();
                    break;
                  case 'rename':
                    onRename?.call();
                    break;
                  case 'move':
                    onMove?.call();
                    break;
                  case 'delete':
                    onDelete?.call();
                    break;
                }
              },
              itemBuilder: (context) => [
                _buildMenuItem(context, Icons.download_rounded, 'Download', 'download'),
                _buildMenuItem(context, Icons.edit_rounded, 'Rename', 'rename'),
                _buildMenuItem(context, Icons.drive_file_move_rounded, 'Move', 'move'),
                _buildMenuItem(context, Icons.delete_rounded, 'Delete', 'delete',
                    isDestructive: true),
              ],
            ),

          if (file.isFolder)
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.black38,
            ),

          if (file.isEncrypted)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.lock_rounded,
                  size: 16, color: AppColors.warning),
            ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      BuildContext context, IconData icon, String label, String value,
      {bool isDestructive = false}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: isDestructive ? AppColors.error : Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: isDestructive ? AppColors.error : null,
                  fontSize: 14)),
        ],
      ),
    );
  }
}
