import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cassiel_drive/models/file_model.dart';
import 'package:cassiel_drive/services/auth_service.dart';
import 'package:cassiel_drive/core/constants/app_constants.dart';

class DriveService {
  static final DriveService _instance = DriveService._internal();
  factory DriveService() => _instance;
  DriveService._internal();

  final AuthService _authService = AuthService();

  /// List files from a specific drive account
  Future<List<FileModel>> listFiles(String accountId,
      {String? folderId, String? query, int pageSize = 100}) async {
    final token = await _authService.getAccessToken(accountId);
    if (token == null) return [];

    try {
      String q = "trashed=false";
      if (folderId != null) {
        q += " and '$folderId' in parents";
      }
      if (query != null && query.isNotEmpty) {
        q += " and name contains '$query'";
      }

      final uri = Uri.parse('${AppConstants.driveApiBase}/files').replace(
        queryParameters: {
          'q': q,
          'fields':
              'files(id,name,mimeType,size,parents,thumbnailLink,webViewLink,createdTime,modifiedTime,sha256Checksum)',
          'pageSize': pageSize.toString(),
          'orderBy': 'modifiedTime desc',
        },
      );

      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final files = (data['files'] as List?) ?? [];
        final account = _authService.accounts.firstWhere(
          (a) => a.id == accountId,
          orElse: () => throw Exception('Account not found'),
        );
        return files
            .map((f) => FileModel.fromDriveJson(f,
                accountId: accountId, accountEmail: account.email))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('List files error: $e');
      return [];
    }
  }

  /// Get storage quota for account
  Future<Map<String, int>> getStorageQuota(String accountId) async {
    final token = await _authService.getAccessToken(accountId);
    if (token == null) return {'used': 0, 'total': 0};

    try {
      final uri = Uri.parse('${AppConstants.driveApiBase}/about').replace(
        queryParameters: {
          'fields': 'storageQuota',
        },
      );

      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final quota = data['storageQuota'];
        return {
          'used': int.tryParse(quota['usage'] ?? '0') ?? 0,
          'total': int.tryParse(quota['limit'] ?? '0') ?? 0,
        };
      }
      return {'used': 0, 'total': 0};
    } catch (e) {
      debugPrint('Storage quota error: $e');
      return {'used': 0, 'total': 0};
    }
  }

  /// Upload file to drive
  Future<FileModel?> uploadFile(
    String accountId,
    String fileName,
    Uint8List fileBytes, {
    String? folderId,
    String? mimeType,
    Function(double)? onProgress,
  }) async {
    final token = await _authService.getAccessToken(accountId);
    if (token == null) return null;

    try {
      // Create metadata
      final metadata = {
        'name': fileName,
        if (folderId != null) 'parents': [folderId],
      };

      // Multipart upload
      final boundary = '===cassiel_boundary===';
      final body = StringBuffer();
      body.writeln('--$boundary');
      body.writeln('Content-Type: application/json; charset=UTF-8');
      body.writeln();
      body.writeln(jsonEncode(metadata));
      body.writeln('--$boundary');
      body.writeln('Content-Type: ${mimeType ?? 'application/octet-stream'}');
      body.writeln('Content-Transfer-Encoding: base64');
      body.writeln();

      final base64Data = base64Encode(fileBytes);
      body.writeln(base64Data);
      body.writeln('--$boundary--');

      final uri = Uri.parse(
          '${AppConstants.uploadApiBase}/files?uploadType=multipart&fields=id,name,mimeType,size,parents,createdTime,modifiedTime');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/related; boundary=$boundary',
        },
        body: body.toString(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        onProgress?.call(1.0);
        return FileModel.fromDriveJson(data, accountId: accountId);
      }
      return null;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  /// Download file from drive
  Future<Uint8List?> downloadFile(String accountId, String fileId) async {
    final token = await _authService.getAccessToken(accountId);
    if (token == null) return null;

    try {
      final uri = Uri.parse('${AppConstants.driveApiBase}/files/$fileId')
          .replace(queryParameters: {'alt': 'media'});

      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      debugPrint('Download error: $e');
      return null;
    }
  }

  /// Create folder
  Future<FileModel?> createFolder(String accountId, String folderName,
      {String? parentId}) async {
    final token = await _authService.getAccessToken(accountId);
    if (token == null) return null;

    try {
      final metadata = {
        'name': folderName,
        'mimeType': 'application/vnd.google-apps.folder',
        if (parentId != null) 'parents': [parentId],
      };

      final uri = Uri.parse('${AppConstants.driveApiBase}/files');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(metadata),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return FileModel.fromDriveJson(data, accountId: accountId);
      }
      return null;
    } catch (e) {
      debugPrint('Create folder error: $e');
      return null;
    }
  }

  /// Delete file
  Future<bool> deleteFile(String accountId, String fileId) async {
    final token = await _authService.getAccessToken(accountId);
    if (token == null) return false;

    try {
      final uri = Uri.parse('${AppConstants.driveApiBase}/files/$fileId');
      final response = await http.delete(uri, headers: {
        'Authorization': 'Bearer $token',
      });
      return response.statusCode == 204;
    } catch (e) {
      debugPrint('Delete error: $e');
      return false;
    }
  }

  /// Rename file
  Future<bool> renameFile(
      String accountId, String fileId, String newName) async {
    final token = await _authService.getAccessToken(accountId);
    if (token == null) return false;

    try {
      final uri = Uri.parse('${AppConstants.driveApiBase}/files/$fileId');
      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': newName}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Rename error: $e');
      return false;
    }
  }

  /// Move file to another folder
  Future<bool> moveFile(
      String accountId, String fileId, String newFolderId) async {
    final token = await _authService.getAccessToken(accountId);
    if (token == null) return false;

    try {
      // Get current parents
      final getUri = Uri.parse('${AppConstants.driveApiBase}/files/$fileId')
          .replace(queryParameters: {'fields': 'parents'});

      final getResponse = await http.get(getUri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (getResponse.statusCode != 200) return false;

      final currentParents =
          (jsonDecode(getResponse.body)['parents'] as List?)?.join(',') ?? '';

      // Move file
      final moveUri =
          Uri.parse('${AppConstants.driveApiBase}/files/$fileId').replace(
        queryParameters: {
          'addParents': newFolderId,
          'removeParents': currentParents,
        },
      );

      final response = await http.patch(moveUri, headers: {
        'Authorization': 'Bearer $token',
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Move error: $e');
      return false;
    }
  }
}
