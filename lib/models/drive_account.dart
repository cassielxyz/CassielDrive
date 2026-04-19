class DriveAccount {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final int storageUsed; // bytes
  final int storageTotal; // bytes
  final double healthScore; // 0.0 - 1.0
  final String? accessToken;
  final DateTime? tokenExpiry;
  final bool isActive;

  DriveAccount({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.storageUsed = 0,
    this.storageTotal = 16106127360, // 15GB default
    this.healthScore = 1.0,
    this.accessToken,
    this.tokenExpiry,
    this.isActive = true,
  });

  int get storageFree => storageTotal - storageUsed;
  double get usagePercentage =>
      storageTotal > 0 ? storageUsed / storageTotal : 0.0;
  bool get isTokenValid =>
      tokenExpiry != null && tokenExpiry!.isAfter(DateTime.now());

  String get storageUsedFormatted => _formatBytes(storageUsed);
  String get storageTotalFormatted => _formatBytes(storageTotal);
  String get storageFreeFormatted => _formatBytes(storageFree);

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  factory DriveAccount.fromJson(Map<String, dynamic> json) {
    return DriveAccount(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      avatarUrl: json['avatarUrl'],
      storageUsed: json['storageUsed'] ?? 0,
      storageTotal: json['storageTotal'] ?? 16106127360, // 15 GB
      healthScore: (json['healthScore'] ?? 1.0).toDouble(),
      accessToken: json['accessToken'],
      tokenExpiry: json['tokenExpiry'] != null
          ? DateTime.parse(json['tokenExpiry'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'storageUsed': storageUsed,
        'storageTotal': storageTotal,
        'healthScore': healthScore,
        'accessToken': accessToken,
        'tokenExpiry': tokenExpiry?.toIso8601String(),
        'isActive': isActive,
      };

  DriveAccount copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    int? storageUsed,
    int? storageTotal,
    double? healthScore,
    String? accessToken,
    DateTime? tokenExpiry,
    bool? isActive,
  }) {
    return DriveAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      storageUsed: storageUsed ?? this.storageUsed,
      storageTotal: storageTotal ?? this.storageTotal,
      healthScore: healthScore ?? this.healthScore,
      accessToken: accessToken ?? this.accessToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      isActive: isActive ?? this.isActive,
    );
  }
}
