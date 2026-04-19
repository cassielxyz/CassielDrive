import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:cassiel_drive/core/constants/app_constants.dart';
import 'package:cassiel_drive/models/file_model.dart';
import 'package:cassiel_drive/models/chunk_model.dart';
import 'package:cassiel_drive/services/drive_service.dart';
import 'package:cassiel_drive/services/storage_orchestrator.dart';
import 'package:cassiel_drive/models/drive_account.dart';
import 'package:cassiel_drive/services/auth_service.dart';

import 'package:crypto/crypto.dart';

enum UploadStatus { queued, uploading, completed, failed, cancelled }

class UploadTask {
  final String id;
  final String fileName;
  final int fileSize;
  final Uint8List fileBytes;
  final String strategy; // normal, parallel, chunk
  UploadStatus status;
  double progress;
  String? error;
  String? driveAccountId;
  FileModel? result;
  List<ChunkModel> chunks;

  UploadTask({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.fileBytes,
    required this.strategy,
    this.status = UploadStatus.queued,
    this.progress = 0.0,
    this.error,
    this.driveAccountId,
    this.result,
    List<ChunkModel>? chunks,
  }) : chunks = chunks ?? [];
}

class UploadManager {
  static final UploadManager _instance = UploadManager._internal();
  factory UploadManager() => _instance;
  UploadManager._internal();

  final DriveService _driveService = DriveService();
  final StorageOrchestrator _orchestrator = StorageOrchestrator();
  final AuthService _authService = AuthService();
  final List<UploadTask> _queue = [];
  final _uuid = const Uuid();
  int _activeUploads = 0;
  int _maxConcurrent = AppConstants.maxUploadThreads;
  int _chunkSize = AppConstants.defaultChunkSize;

  final StreamController<List<UploadTask>> _queueController =
      StreamController<List<UploadTask>>.broadcast();
  Stream<List<UploadTask>> get queueStream => _queueController.stream;
  List<UploadTask> get queue => List.unmodifiable(_queue);

  void configure({int? maxConcurrent, int? chunkSize}) {
    if (maxConcurrent != null) _maxConcurrent = maxConcurrent;
    if (chunkSize != null) _chunkSize = chunkSize;
  }

  /// Add files to upload queue
  String addToQueue(String fileName, Uint8List fileBytes,
      {String? targetAccountId}) {
    final strategy = _determineStrategy(fileBytes.length);
    final task = UploadTask(
      id: _uuid.v4(),
      fileName: fileName,
      fileSize: fileBytes.length,
      fileBytes: fileBytes,
      strategy: strategy,
      driveAccountId: targetAccountId,
    );
    _queue.add(task);
    _notifyQueue();
    _processQueue();
    return task.id;
  }

  /// Cancel upload
  void cancelUpload(String taskId) {
    final idx = _queue.indexWhere((t) => t.id == taskId);
    if (idx >= 0) {
      _queue[idx].status = UploadStatus.cancelled;
      _notifyQueue();
    }
  }

  /// Retry failed upload
  void retryUpload(String taskId) {
    final idx = _queue.indexWhere((t) => t.id == taskId);
    if (idx >= 0 && _queue[idx].status == UploadStatus.failed) {
      _queue[idx].status = UploadStatus.queued;
      _queue[idx].progress = 0.0;
      _queue[idx].error = null;
      _notifyQueue();
      _processQueue();
    }
  }

  /// Remove from queue
  void removeFromQueue(String taskId) {
    _queue.removeWhere((t) => t.id == taskId);
    _notifyQueue();
  }

  /// Clear completed/failed/cancelled
  void clearFinished() {
    _queue.removeWhere((t) =>
        t.status == UploadStatus.completed ||
        t.status == UploadStatus.failed ||
        t.status == UploadStatus.cancelled);
    _notifyQueue();
  }

  String _determineStrategy(int fileSize) {
    if (fileSize < AppConstants.normalUploadThreshold) return 'normal';
    if (fileSize < AppConstants.parallelUploadThreshold) return 'parallel';
    return 'chunk';
  }

  Future<void> _processQueue() async {
    while (_activeUploads < _maxConcurrent) {
      final nextTask = _queue.firstWhere(
        (t) => t.status == UploadStatus.queued,
        orElse: () => UploadTask(
          id: '',
          fileName: '',
          fileSize: 0,
          fileBytes: Uint8List(0),
          strategy: 'normal',
        ),
      );

      if (nextTask.id.isEmpty) break;

      _activeUploads++;
      nextTask.status = UploadStatus.uploading;
      _notifyQueue();

      _executeUpload(nextTask).then((_) {
        _activeUploads--;
        _processQueue();
      });
    }
  }

  Future<void> _executeUpload(UploadTask task) async {
    try {
      // Select best drive account
      final accounts = _getAvailableAccounts();
      if (accounts.isEmpty) {
        task.status = UploadStatus.failed;
        task.error = 'No accounts available';
        _notifyQueue();
        return;
      }

      final targetAccount = task.driveAccountId != null
          ? accounts.firstWhere(
              (a) => a.id == task.driveAccountId,
              orElse: () => _orchestrator.selectBestDrive(accounts),
            )
          : _orchestrator.selectBestDrive(accounts);

      task.driveAccountId = targetAccount.id;

      switch (task.strategy) {
        case 'normal':
          await _normalUpload(task, targetAccount);
          break;
        case 'parallel':
          await _parallelUpload(task, accounts);
          break;
        case 'chunk':
          await _chunkUpload(task, accounts);
          break;
      }
    } catch (e) {
      task.status = UploadStatus.failed;
      task.error = e.toString();
      _notifyQueue();
    }
  }

  Future<void> _normalUpload(UploadTask task, DriveAccount account) async {
    final result = await _driveService.uploadFile(
      account.id,
      task.fileName,
      task.fileBytes,
      onProgress: (progress) {
        task.progress = progress;
        _notifyQueue();
      },
    );

    if (result != null) {
      task.status = UploadStatus.completed;
      task.progress = 1.0;
      task.result = result;
    } else {
      task.status = UploadStatus.failed;
      task.error = 'Upload failed';
    }
    _notifyQueue();
  }

  Future<void> _parallelUpload(
      UploadTask task, List<DriveAccount> accounts) async {
    // Split into 2 parallel streams to the same drive
    final account = _orchestrator.selectBestDrive(accounts);
    task.driveAccountId = account.id;

    final result = await _driveService.uploadFile(
      account.id,
      task.fileName,
      task.fileBytes,
      onProgress: (progress) {
        task.progress = progress;
        _notifyQueue();
      },
    );

    if (result != null) {
      task.status = UploadStatus.completed;
      task.progress = 1.0;
      task.result = result;
    } else {
      task.status = UploadStatus.failed;
      task.error = 'Parallel upload failed';
    }
    _notifyQueue();
  }

  Future<void> _chunkUpload(
      UploadTask task, List<DriveAccount> accounts) async {
    final totalChunks = (task.fileSize / _chunkSize).ceil();
    final fileHash = sha256.convert(task.fileBytes).toString();

    // Create chunk models
    for (int i = 0; i < totalChunks; i++) {
      final start = i * _chunkSize;
      final end =
          (start + _chunkSize > task.fileSize) ? task.fileSize : start + _chunkSize;
      final chunkData = task.fileBytes.sublist(start, end);
      final chunkHash = sha256.convert(chunkData).toString();

      task.chunks.add(ChunkModel(
        id: _uuid.v4(),
        parentFileId: task.id,
        parentFileName: task.fileName,
        chunkIndex: i,
        totalChunks: totalChunks,
        chunkSize: end - start,
        sha256Hash: chunkHash,
      ));
    }

    // Upload chunks to different drives
    int completedChunks = 0;
    for (int i = 0; i < task.chunks.length; i++) {
      if (task.status == UploadStatus.cancelled) return;

      final chunk = task.chunks[i];
      final account =
          accounts[i % accounts.length]; // Distribute across accounts

      final start = chunk.chunkIndex * _chunkSize;
      final end = (start + chunk.chunkSize > task.fileSize)
          ? task.fileSize
          : start + chunk.chunkSize;
      final chunkData = task.fileBytes.sublist(start, end);

      task.chunks[i] = chunk.copyWith(
        status: ChunkStatus.uploading,
        driveAccountId: account.id,
      );
      _notifyQueue();

      final result = await _driveService.uploadFile(
        account.id,
        '${task.fileName}.chunk_$i',
        chunkData,
      );

      if (result != null) {
        task.chunks[i] = task.chunks[i].copyWith(
          status: ChunkStatus.completed,
          driveFileId: result.id,
          progress: 1.0,
        );
        completedChunks++;
        task.progress = completedChunks / totalChunks;
      } else {
        task.chunks[i] = task.chunks[i].copyWith(
          status: ChunkStatus.failed,
        );
      }
      _notifyQueue();
    }

    // Check if all chunks completed
    if (task.chunks.every((c) => c.isCompleted)) {
      task.status = UploadStatus.completed;
      task.progress = 1.0;
      // Store chunk metadata for reconstruction
      task.result = FileModel(
        id: task.id,
        name: task.fileName,
        size: task.fileSize,
        isChunked: true,
        chunkIds: task.chunks.map((c) => c.driveFileId ?? '').toList(),
        sha256Hash: fileHash,
      );
    } else {
      task.status = UploadStatus.failed;
      task.error = 'Some chunks failed to upload';
    }
    _notifyQueue();
  }

  List<DriveAccount> _getAvailableAccounts() {
    return _authService.accounts.where((a) => a.isActive).toList();
  }

  void _notifyQueue() {
    _queueController.add(List.from(_queue));
  }

  void dispose() {
    _queueController.close();
  }
}
