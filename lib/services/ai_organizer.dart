import 'package:flutter/foundation.dart';
import 'package:cassiel_drive/models/file_model.dart';
import 'package:cassiel_drive/services/drive_service.dart';
import 'package:cassiel_drive/core/constants/app_constants.dart';

class AiOrganizer {
  static final AiOrganizer _instance = AiOrganizer._internal();
  factory AiOrganizer() => _instance;
  AiOrganizer._internal();

  final DriveService _driveService = DriveService();

  /// Categorize a file based on extension
  String categorize(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    for (final entry in AppConstants.fileCategories.entries) {
      if (entry.value.contains(ext)) return entry.key;
    }
    return 'Other';
  }

  /// Categorize multiple files
  Map<String, List<FileModel>> categorizeFiles(List<FileModel> files) {
    final categorized = <String, List<FileModel>>{};

    for (final file in files) {
      if (file.isFolder) continue;
      final category = categorize(file.name);
      categorized.putIfAbsent(category, () => []);
      categorized[category]!.add(file);
    }

    return categorized;
  }

  /// Auto-organize: create folders and move files
  Future<Map<String, int>> organizeFiles(
    String accountId,
    List<FileModel> files, {
    String? parentFolderId,
    Function(String, double)? onProgress,
  }) async {
    final categorized = categorizeFiles(files);
    final results = <String, int>{};
    int processed = 0;
    final total = files.where((f) => !f.isFolder).length;

    for (final entry in categorized.entries) {
      final category = entry.key;
      final categoryFiles = entry.value;

      if (categoryFiles.isEmpty) continue;

      onProgress?.call('Creating $category folder...', processed / total);

      // Create category folder
      final folder = await _driveService.createFolder(
        accountId,
        category,
        parentId: parentFolderId,
      );

      if (folder == null) {
        debugPrint('Failed to create folder: $category');
        continue;
      }

      // Move files to folder
      int movedCount = 0;
      for (final file in categoryFiles) {
        final success =
            await _driveService.moveFile(accountId, file.id, folder.id);
        if (success) movedCount++;
        processed++;
        onProgress?.call(
          'Moving ${file.name} to $category',
          processed / total,
        );
      }

      results[category] = movedCount;
    }

    return results;
  }

  /// Get category stats for dashboard
  Map<String, int> getCategoryStats(List<FileModel> files) {
    final stats = <String, int>{};
    for (final file in files) {
      if (file.isFolder) continue;
      final category = categorize(file.name);
      stats[category] = (stats[category] ?? 0) + 1;
    }
    return stats;
  }

  /// Get storage by category
  Map<String, int> getStorageByCategory(List<FileModel> files) {
    final storage = <String, int>{};
    for (final file in files) {
      if (file.isFolder) continue;
      final category = categorize(file.name);
      storage[category] = (storage[category] ?? 0) + file.size;
    }
    return storage;
  }
}
