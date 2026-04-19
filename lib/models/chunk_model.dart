enum ChunkStatus { pending, uploading, completed, failed }

class ChunkModel {
  final String id;
  final String parentFileId;
  final String parentFileName;
  final int chunkIndex;
  final int totalChunks;
  final int chunkSize;
  final String? driveAccountId;
  final String? driveFileId;
  final String? sha256Hash;
  final ChunkStatus status;
  final double progress;

  ChunkModel({
    required this.id,
    required this.parentFileId,
    required this.parentFileName,
    required this.chunkIndex,
    required this.totalChunks,
    required this.chunkSize,
    this.driveAccountId,
    this.driveFileId,
    this.sha256Hash,
    this.status = ChunkStatus.pending,
    this.progress = 0.0,
  });

  bool get isCompleted => status == ChunkStatus.completed;
  bool get isFailed => status == ChunkStatus.failed;

  factory ChunkModel.fromJson(Map<String, dynamic> json) {
    return ChunkModel(
      id: json['id'] ?? '',
      parentFileId: json['parentFileId'] ?? '',
      parentFileName: json['parentFileName'] ?? '',
      chunkIndex: json['chunkIndex'] ?? 0,
      totalChunks: json['totalChunks'] ?? 0,
      chunkSize: json['chunkSize'] ?? 0,
      driveAccountId: json['driveAccountId'],
      driveFileId: json['driveFileId'],
      sha256Hash: json['sha256Hash'],
      status: ChunkStatus.values[json['status'] ?? 0],
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'parentFileId': parentFileId,
        'parentFileName': parentFileName,
        'chunkIndex': chunkIndex,
        'totalChunks': totalChunks,
        'chunkSize': chunkSize,
        'driveAccountId': driveAccountId,
        'driveFileId': driveFileId,
        'sha256Hash': sha256Hash,
        'status': status.index,
        'progress': progress,
      };

  ChunkModel copyWith({
    String? driveAccountId,
    String? driveFileId,
    String? sha256Hash,
    ChunkStatus? status,
    double? progress,
  }) {
    return ChunkModel(
      id: id,
      parentFileId: parentFileId,
      parentFileName: parentFileName,
      chunkIndex: chunkIndex,
      totalChunks: totalChunks,
      chunkSize: chunkSize,
      driveAccountId: driveAccountId ?? this.driveAccountId,
      driveFileId: driveFileId ?? this.driveFileId,
      sha256Hash: sha256Hash ?? this.sha256Hash,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}
