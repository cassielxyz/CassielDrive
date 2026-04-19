import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:cassiel_drive/models/user_model.dart';
import 'package:cassiel_drive/models/drive_account.dart';
import 'package:cassiel_drive/core/constants/app_constants.dart';

// Conditional imports for platform-specific code
import 'auth_service_io.dart' if (dart.library.html) 'auth_service_web.dart'
    as platform_auth;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final List<DriveAccount> _accounts = [];
  UserModel? _currentUser;
  String _currentUsername = 'User';

  List<DriveAccount> get accounts => List.unmodifiable(_accounts);
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null && _accounts.isNotEmpty;
  String get currentUsername => _currentUsername;

  static const _scopes = [
    'email',
    'profile',
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/drive.file',
  ];

  // ── Initialize ──────────────────────────────────────────────────────
  Future<void> initialize(String username) async {
    _currentUsername = username;
    await _loadAccounts();

    // If we have accounts, set currentUser from the first one
    if (_accounts.isNotEmpty) {
      final first = _accounts.first;
      _currentUser = UserModel(
        id: first.id,
        email: first.email,
        displayName: first.displayName,
        avatarUrl: first.avatarUrl,
      );
    }
  }

  // ── Load / Save ─────────────────────────────────────────────────────
  Future<void> _loadAccounts() async {
    try {
      final String? accountsJson =
          await _secureStorage.read(key: '${_currentUsername}_accounts');
      _accounts.clear();
      if (accountsJson != null && accountsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(accountsJson);
        for (var item in decoded) {
          _accounts.add(DriveAccount.fromJson(item));
        }
      }
    } catch (e) {
      debugPrint('Error loading accounts for $_currentUsername: $e');
    }
  }

  Future<void> saveAccounts() async {
    try {
      final String accountsJson =
          jsonEncode(_accounts.map((a) => a.toJson()).toList());
      await _secureStorage.write(
          key: '${_currentUsername}_accounts', value: accountsJson);
    } catch (e) {
      debugPrint('Error saving accounts for $_currentUsername: $e');
    }
  }

  // ── OAuth 2.0 Flow ──────────────────────────────────────────────────
  /// Performs the OAuth flow using the platform-appropriate method.
  Future<Map<String, String>?> _performOAuthFlow(
      String clientId, String clientSecret) async {
    return platform_auth.performOAuthFlow(
      clientId: clientId,
      clientSecret: clientSecret,
      scopes: _scopes,
    );
  }

  /// Fetches the user's Google profile using the access token.
  Future<Map<String, dynamic>?> _fetchUserProfile(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
    return null;
  }

  /// Refreshes an access token using the stored refresh token.
  Future<String?> _refreshAccessToken(
      String refreshToken, String clientId, String clientSecret) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.oauthTokenEndpoint),
        body: {
          'refresh_token': refreshToken,
          'client_id': clientId,
          'client_secret': clientSecret,
          'grant_type': 'refresh_token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      } else {
        debugPrint(
            'Token refresh failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
    }
    return null;
  }

  // ── Sign In / Add Account ─────────────────────────────────────────
  Future<bool> signIn() async {
    final clientId = await _secureStorage.read(key: AppConstants.clientIdKey);
    final clientSecret =
        await _secureStorage.read(key: AppConstants.clientSecretKey);

    if (clientId == null ||
        clientId.isEmpty ||
        clientSecret == null ||
        clientSecret.isEmpty) {
      debugPrint('Client ID or Secret not configured');
      return false;
    }

    final tokens = await _performOAuthFlow(clientId, clientSecret);
    if (tokens == null) return false;

    final profile = await _fetchUserProfile(tokens['access_token']!);
    if (profile == null) return false;

    final email = profile['email'] ?? '';
    final name = profile['name'] ?? email;
    final picture = profile['picture'];
    final id = profile['id'] ?? email;

    final driveAccount = DriveAccount(
      id: id,
      email: email,
      displayName: name,
      avatarUrl: picture,
      accessToken: tokens['access_token'],
      tokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      storageUsed: 0,
      storageTotal: AppConstants.defaultStorageBytes,
    );

    _currentUser = UserModel(
      id: id,
      email: email,
      displayName: name,
      avatarUrl: picture,
    );

    // Check if already exists
    final existingIdx = _accounts.indexWhere((a) => a.email == email);
    if (existingIdx >= 0) {
      _accounts[existingIdx] = driveAccount.copyWith(
        storageUsed: _accounts[existingIdx].storageUsed,
        storageTotal: _accounts[existingIdx].storageTotal,
        healthScore: _accounts[existingIdx].healthScore,
      );
    } else {
      _accounts.add(driveAccount);
    }

    // Store tokens securely
    await _secureStorage.write(
        key: 'token_$id', value: tokens['access_token']);
    if (tokens['refresh_token'] != null &&
        tokens['refresh_token']!.isNotEmpty) {
      await _secureStorage.write(
          key: 'refresh_token_$id', value: tokens['refresh_token']);
    }
    await saveAccounts();
    return true;
  }

  Future<bool> addAccount() async {
    final clientId = await _secureStorage.read(key: AppConstants.clientIdKey);
    final clientSecret =
        await _secureStorage.read(key: AppConstants.clientSecretKey);

    if (clientId == null ||
        clientId.isEmpty ||
        clientSecret == null ||
        clientSecret.isEmpty) {
      debugPrint('Client ID or Secret not configured');
      return false;
    }

    final tokens = await _performOAuthFlow(clientId, clientSecret);
    if (tokens == null) return false;

    final profile = await _fetchUserProfile(tokens['access_token']!);
    if (profile == null) return false;

    final email = profile['email'] ?? '';
    final name = profile['name'] ?? email;
    final picture = profile['picture'];
    final id = profile['id'] ?? email;

    // Check duplicate
    if (_accounts.any((a) => a.email == email)) {
      debugPrint('Account $email already added');
      return false;
    }

    final driveAccount = DriveAccount(
      id: id,
      email: email,
      displayName: name,
      avatarUrl: picture,
      accessToken: tokens['access_token'],
      tokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      storageUsed: 0,
      storageTotal: AppConstants.defaultStorageBytes,
    );

    _accounts.add(driveAccount);

    await _secureStorage.write(
        key: 'token_$id', value: tokens['access_token']);
    if (tokens['refresh_token'] != null &&
        tokens['refresh_token']!.isNotEmpty) {
      await _secureStorage.write(
          key: 'refresh_token_$id', value: tokens['refresh_token']);
    }
    await saveAccounts();
    return true;
  }

  // ── Token Management ───────────────────────────────────────────────
  Future<String?> getAccessToken(String accountId) async {
    final account = _accounts.firstWhere(
      (a) => a.id == accountId,
      orElse: () => DriveAccount(id: '', email: '', displayName: ''),
    );

    if (account.id.isEmpty) return null;
    if (account.isTokenValid) return account.accessToken;

    // Try to refresh using stored refresh token
    final clientId = await _secureStorage.read(key: AppConstants.clientIdKey);
    final clientSecret =
        await _secureStorage.read(key: AppConstants.clientSecretKey);
    final refreshToken =
        await _secureStorage.read(key: 'refresh_token_$accountId');

    if (clientId != null && clientSecret != null && refreshToken != null) {
      final newToken =
          await _refreshAccessToken(refreshToken, clientId, clientSecret);
      if (newToken != null) {
        final idx = _accounts.indexWhere((a) => a.id == accountId);
        if (idx >= 0) {
          _accounts[idx] = _accounts[idx].copyWith(
            accessToken: newToken,
            tokenExpiry: DateTime.now().add(const Duration(hours: 1)),
          );
          await _secureStorage.write(key: 'token_$accountId', value: newToken);
          await saveAccounts();
        }
        return newToken;
      }
    }
    return null;
  }

  // ── Remove / Sign Out ──────────────────────────────────────────────
  Future<void> removeAccount(String accountId) async {
    _accounts.removeWhere((a) => a.id == accountId);
    await _secureStorage.delete(key: 'token_$accountId');
    await _secureStorage.delete(key: 'refresh_token_$accountId');

    if (_accounts.isEmpty) {
      _currentUser = null;
    }
    await saveAccounts();
  }

  Future<void> signOut() async {
    for (final account in _accounts) {
      await _secureStorage.delete(key: 'token_${account.id}');
      await _secureStorage.delete(key: 'refresh_token_${account.id}');
    }
    _accounts.clear();
    _currentUser = null;
    await _secureStorage.delete(key: '${_currentUsername}_accounts');
  }

  void updateAccountStorage(String accountId,
      {int? storageUsed, int? storageTotal, double? healthScore}) {
    final idx = _accounts.indexWhere((a) => a.id == accountId);
    if (idx >= 0) {
      _accounts[idx] = _accounts[idx].copyWith(
        storageUsed: storageUsed,
        storageTotal: storageTotal,
        healthScore: healthScore,
      );
      saveAccounts();
    }
  }
}
