class FileModel {
  final String id;
  final String name;
  final int size;
  final String mimeType;
  final String? driveAccountId;
  final String? driveAccountEmail;
  final String? folderId;
  final String? folderName;
  final String? thumbnailUrl;
  final String? webViewLink;
  final String? downloadUrl;
  final String? sha256Hash;
  final DateTime? createdTime;
  final DateTime? modifiedTime;
  final bool isFolder;
  final bool isEncrypted;
  final bool isChunked;
  final List<String>? chunkIds;
  final String? category;

  FileModel({
    required this.id,
    required this.name,
    this.size = 0,
    this.mimeType = 'application/octet-stream',
    this.driveAccountId,
    this.driveAccountEmail,
    this.folderId,
    this.folderName,
    this.thumbnailUrl,
    this.webViewLink,
    this.downloadUrl,
    this.sha256Hash,
    this.createdTime,
    this.modifiedTime,
    this.isFolder = false,
    this.isEncrypted = false,
    this.isChunked = false,
    this.chunkIds,
    this.category,
  });

  String get extension {
    final dotIndex = name.lastIndexOf('.');
    return dotIndex != -1 ? name.substring(dotIndex + 1).toLowerCase() : '';
  }

  String get sizeFormatted {
    if (size <= 0) return '—';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double s = size.toDouble();
    while (s >= 1024 && i < suffixes.length - 1) {
      s /= 1024;
      i++;
    }
    return '${s.toStringAsFixed(1)} ${suffixes[i]}';
  }

  factory FileModel.fromDriveJson(Map<String, dynamic> json, {String? accountId, String? accountEmail}) {
    return FileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Untitled',
      size: int.tryParse(json['size']?.toString() ?? '0') ?? 0,
      mimeType: json['mimeType'] ?? 'application/octet-stream',
      driveAccountId: accountId,
      driveAccountEmail: accountEmail,
      folderId: (json['parents'] as List?)?.firstOrNull,
      thumbnailUrl: json['thumbnailLink'],
      webViewLink: json['webViewLink'],
      sha256Hash: json['sha256Checksum'],
      createdTime: json['createdTime'] != null
          ? DateTime.tryParse(json['createdTime'])
          : null,
      modifiedTime: json['modifiedTime'] != null
          ? DateTime.tryParse(json['modifiedTime'])
          : null,
      isFolder: json['mimeType'] == 'application/vnd.google-apps.folder',
    );
  }

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      size: json['size'] ?? 0,
      mimeType: json['mimeType'] ?? '',
      driveAccountId: json['driveAccountId'],
      driveAccountEmail: json['driveAccountEmail'],
      folderId: json['folderId'],
      folderName: json['folderName'],
      thumbnailUrl: json['thumbnailUrl'],
      webViewLink: json['webViewLink'],
      downloadUrl: json['downloadUrl'],
      sha256Hash: json['sha256Hash'],
      createdTime: json['createdTime'] != null
          ? DateTime.parse(json['createdTime'])
          : null,
      modifiedTime: json['modifiedTime'] != null
          ? DateTime.parse(json['modifiedTime'])
          : null,
      isFolder: json['isFolder'] ?? false,
      isEncrypted: json['isEncrypted'] ?? false,
      isChunked: json['isChunked'] ?? false,
      chunkIds: (json['chunkIds'] as List?)?.cast<String>(),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'size': size,
        'mimeType': mimeType,
        'driveAccountId': driveAccountId,
        'driveAccountEmail': driveAccountEmail,
        'folderId': folderId,
        'folderName': folderName,
        'thumbnailUrl': thumbnailUrl,
        'webViewLink': webViewLink,
        'downloadUrl': downloadUrl,
        'sha256Hash': sha256Hash,
        'createdTime': createdTime?.toIso8601String(),
        'modifiedTime': modifiedTime?.toIso8601String(),
        'isFolder': isFolder,
        'isEncrypted': isEncrypted,
        'isChunked': isChunked,
        'chunkIds': chunkIds,
        'category': category,
      };

  FileModel copyWith({
    String? id,
    String? name,
    int? size,
    String? mimeType,
    String? driveAccountId,
    String? driveAccountEmail,
    String? folderId,
    String? folderName,
    String? thumbnailUrl,
    String? sha256Hash,
    bool? isFolder,
    bool? isEncrypted,
    bool? isChunked,
    List<String>? chunkIds,
    String? category,
  }) {
    return FileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      driveAccountId: driveAccountId ?? this.driveAccountId,
      driveAccountEmail: driveAccountEmail ?? this.driveAccountEmail,
      folderId: folderId ?? this.folderId,
      folderName: folderName ?? this.folderName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sha256Hash: sha256Hash ?? this.sha256Hash,
      createdTime: createdTime,
      modifiedTime: modifiedTime,
      isFolder: isFolder ?? this.isFolder,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isChunked: isChunked ?? this.isChunked,
      chunkIds: chunkIds ?? this.chunkIds,
      category: category ?? this.category,
    );
  }
}
