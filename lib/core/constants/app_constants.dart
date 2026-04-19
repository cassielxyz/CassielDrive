class AppConstants {
  // App Info
  static const String appName = 'Cassiel Drive';
  static const String appVersion = '2.0.0';

  // Upload Strategy Thresholds
  static const int normalUploadThreshold = 100 * 1024 * 1024; // 100MB
  static const int parallelUploadThreshold = 1024 * 1024 * 1024; // 1GB
  static const int defaultChunkSize = 100 * 1024 * 1024; // 100MB
  static const int maxUploadThreads = 5;
  static const int maxRetryAttempts = 3;

  // Storage Orchestrator Weights
  static const double freeSpaceWeight = 0.6;
  static const double apiHealthWeight = 0.3;
  static const double usageBalanceWeight = 0.1;

  // Google Drive API
  static const String driveApiScope = 'https://www.googleapis.com/auth/drive';
  static const String driveApiBase = 'https://www.googleapis.com/drive/v3';
  static const String uploadApiBase =
      'https://www.googleapis.com/upload/drive/v3';

  // OAuth
  static const String oauthAuthEndpoint =
      'https://accounts.google.com/o/oauth2/v2/auth';
  static const String oauthTokenEndpoint =
      'https://oauth2.googleapis.com/token';
  static const String loopbackRedirectUri = 'http://127.0.0.1:8085';
  // Web OAuth: after deploying to Vercel, update this to your actual domain
  static const String webRedirectPath = '/auth/callback';

  // Setup Wizard
  static const String setupWizardPath = '/setup/';

  // Default Storage (15 GB in bytes, safe for all platforms)
  static const int defaultStorageBytes = 16106127360; // 15 * 1024^3

  // Hive Box Names
  static const String settingsBox = 'settings';
  static const String cacheBox = 'file_cache';
  static const String accountsBox = 'accounts';
  static const String chunkMetaBox = 'chunk_metadata';
  static const String vaultBox = 'vault_metadata';

  // Secure Storage Keys
  static const String clientIdKey = 'client_id';
  static const String clientSecretKey = 'client_secret';
  static const String usernameKey = 'username';
  static const String chunkSizeKey = 'chunk_size';
  static const String maxThreadsKey = 'max_threads';
  static const String themeKey = 'theme_mode';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 250);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  static const Duration splashDuration = Duration(seconds: 3);

  // File Categories
  static const Map<String, List<String>> fileCategories = {
    'Images': [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      'svg',
      'ico',
      'tiff'
    ],
    'Videos': ['mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v'],
    'Documents': [
      'pdf',
      'doc',
      'docx',
      'txt',
      'rtf',
      'odt',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'csv'
    ],
    'Archives': ['zip', 'rar', '7z', 'tar', 'gz', 'bz2'],
    'Audio': ['mp3', 'wav', 'flac', 'aac', 'ogg', 'wma', 'm4a'],
    'Code': [
      'dart',
      'py',
      'js',
      'ts',
      'java',
      'kt',
      'swift',
      'c',
      'cpp',
      'h',
      'html',
      'css',
      'json',
      'xml',
      'yaml'
    ],
  };
}
