import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cassiel_drive/core/theme/app_theme.dart';
import 'package:cassiel_drive/core/constants/app_constants.dart';

class FileUtils {
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  static String getCategory(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    for (final entry in AppConstants.fileCategories.entries) {
      if (entry.value.contains(ext)) return entry.key;
    }
    return 'Other';
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Images':
        return Icons.image_rounded;
      case 'Videos':
        return Icons.video_file_rounded;
      case 'Documents':
        return Icons.description_rounded;
      case 'Archives':
        return Icons.archive_rounded;
      case 'Audio':
        return Icons.audio_file_rounded;
      case 'Code':
        return Icons.code_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Images':
        return AppColors.imageColor;
      case 'Videos':
        return AppColors.videoColor;
      case 'Documents':
        return AppColors.documentColor;
      case 'Archives':
        return AppColors.archiveColor;
      case 'Audio':
        return AppColors.audioColor;
      case 'Code':
        return AppColors.codeColor;
      default:
        return AppColors.otherColor;
    }
  }

  static String getUploadStrategy(int fileSize) {
    if (fileSize < AppConstants.normalUploadThreshold) {
      return 'normal';
    } else if (fileSize < AppConstants.parallelUploadThreshold) {
      return 'parallel';
    } else {
      return 'chunk';
    }
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  static String getMimeType(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    final mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'mp4': 'video/mp4',
      'mp3': 'audio/mpeg',
      'zip': 'application/zip',
      'txt': 'text/plain',
      'dart': 'text/x-dart',
    };
    return mimeTypes[ext] ?? 'application/octet-stream';
  }
}
