import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cassiel_drive/models/file_model.dart';
import 'package:cassiel_drive/services/drive_service.dart';
import 'package:cassiel_drive/services/upload_manager.dart';
import 'package:cassiel_drive/services/ai_organizer.dart';
import 'package:cassiel_drive/services/storage_orchestrator.dart';
import 'package:cassiel_drive/services/auth_service.dart';
import 'package:cassiel_drive/core/constants/app_constants.dart';
import 'package:hive/hive.dart';

class StorageProvider extends ChangeNotifier {
  final DriveService _driveService = DriveService();
  final UploadManager _uploadManager = UploadManager();
  final AiOrganizer _aiOrganizer = AiOrganizer();
  final StorageOrchestrator _orchestrator = StorageOrchestrator();
  final AuthService _authService = AuthService();

  List<FileModel> _files = [];
  List<UploadTask> _uploads = [];
  bool _isLoading = false;
  String? _error;
  String? _currentFolderId;
  final List<String> _folderPath = [];
  String _searchQuery = '';
  Map<String, int> _categoryStats = {};
  StreamSubscription? _uploadSub;

  List<FileModel> get files => _files;
  List<FileModel> get folders =>
      _files.where((f) => f.isFolder).toList();
  List<FileModel> get filesOnly =>
      _files.where((f) => !f.isFolder).toList();
  List<UploadTask> get uploads => _uploads;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentFolderId => _currentFolderId;
  List<String> get folderPath => _folderPath;
  Map<String, int> get categoryStats => _categoryStats;

  List<FileModel> get filteredFiles {
    if (_searchQuery.isEmpty) return _files;
    return _files
        .where(
            (f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void initialize() {
    _uploadSub = _uploadManager.queueStream.listen((tasks) {
      _uploads = tasks;
      notifyListeners();
    });
  }

  Future<void> loadFiles({String? accountId, String? folderId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _files.clear();
      final accounts = _authService.accounts;

      if (accountId != null) {
        final accountFiles = await _driveService.listFiles(
          accountId,
          folderId: folderId ?? _currentFolderId,
        );
        _files.addAll(accountFiles);
      } else {
        // Load from all accounts
        for (final account in accounts) {
          final accountFiles = await _driveService.listFiles(
            account.id,
            folderId: folderId,
          );
          _files.addAll(accountFiles);
        }
      }

      // Update category stats
      _categoryStats = _aiOrganizer.getCategoryStats(_files);

      // Cache files
      _cacheFiles();
    } catch (e) {
      _error = 'Failed to load files: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> navigateToFolder(String folderId, String folderName) async {
    _currentFolderId = folderId;
    _folderPath.add(folderName);
    await loadFiles(folderId: folderId);
  }

  Future<void> navigateBack() async {
    if (_folderPath.isNotEmpty) {
      _folderPath.removeLast();
    }
    _currentFolderId = null;
    await loadFiles();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Upload operations
  String uploadFile(String fileName, Uint8List fileBytes,
      {String? targetAccountId}) {
    return _uploadManager.addToQueue(fileName, fileBytes,
        targetAccountId: targetAccountId);
  }

  void cancelUpload(String taskId) => _uploadManager.cancelUpload(taskId);
  void retryUpload(String taskId) => _uploadManager.retryUpload(taskId);
  void removeUpload(String taskId) => _uploadManager.removeFromQueue(taskId);
  void clearFinishedUploads() => _uploadManager.clearFinished();

  // File operations
  Future<bool> createFolder(String accountId, String name) async {
    final result = await _driveService.createFolder(
      accountId,
      name,
      parentId: _currentFolderId,
    );
    if (result != null) {
      await loadFiles();
      return true;
    }
    return false;
  }

  Future<bool> deleteFile(FileModel file) async {
    if (file.driveAccountId == null) return false;
    final success =
        await _driveService.deleteFile(file.driveAccountId!, file.id);
    if (success) {
      _files.removeWhere((f) => f.id == file.id);
      notifyListeners();
    }
    return success;
  }

  Future<bool> renameFile(FileModel file, String newName) async {
    if (file.driveAccountId == null) return false;
    final success =
        await _driveService.renameFile(file.driveAccountId!, file.id, newName);
    if (success) await loadFiles();
    return success;
  }

  Future<Uint8List?> downloadFile(FileModel file) async {
    if (file.driveAccountId == null) return null;
    return _driveService.downloadFile(file.driveAccountId!, file.id);
  }

  // AI Organizer
  Future<Map<String, int>> organizeFiles(String accountId) async {
    final results = await _aiOrganizer.organizeFiles(
      accountId,
      _files.where((f) => f.driveAccountId == accountId && !f.isFolder).toList(),
    );
    await loadFiles();
    return results;
  }

  // Aggregate stats
  Map<String, dynamic> getAggregateStats() {
    return _orchestrator.getAggregateStats(_authService.accounts);
  }

  Map<String, int> getStorageByCategory() {
    return _aiOrganizer.getStorageByCategory(_files);
  }

  void _cacheFiles() {
    try {
      if (!Hive.isBoxOpen(AppConstants.cacheBox)) return;
      final box = Hive.box(AppConstants.cacheBox);
      final fileData = _files.map((f) => f.toJson()).toList();
      box.put('cached_files', fileData);
    } catch (e) {
      debugPrint('Cache error: $e');
    }
  }

  Future<void> loadCachedFiles() async {
    try {
      if (!Hive.isBoxOpen(AppConstants.cacheBox)) return;
      final box = Hive.box(AppConstants.cacheBox);
      final cached = box.get('cached_files');
      if (cached != null) {
        _files = (cached as List)
            .map((f) => FileModel.fromJson(Map<String, dynamic>.from(f)))
            .toList();
        _categoryStats = _aiOrganizer.getCategoryStats(_files);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load cache error: $e');
    }
  }

  @override
  void dispose() {
    _uploadSub?.cancel();
    super.dispose();
  }
}
