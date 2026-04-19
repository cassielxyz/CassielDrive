import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cassiel_drive/core/constants/app_constants.dart';
import 'package:cassiel_drive/models/user_model.dart';
import 'package:cassiel_drive/models/drive_account.dart';
import 'package:cassiel_drive/services/auth_service.dart';
import 'package:cassiel_drive/services/drive_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DriveService _driveService = DriveService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  String? _error;
  String _username = 'User';

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _username.isNotEmpty;
  UserModel? get currentUser => _authService.currentUser ??
      UserModel(id: 'local', email: '', displayName: _username);
  String get username => _username;
  List<DriveAccount> get accounts => _authService.accounts;
  String? get error => _error;

  Future<void> setUsername(String username) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _username = trimmed;
    await _storage.write(key: AppConstants.usernameKey, value: _username);
    await _authService.initialize(_username);
    notifyListeners();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Load username from storage
    final savedUsername = await _storage.read(key: AppConstants.usernameKey);
    if (savedUsername != null && savedUsername.isNotEmpty) {
      _username = savedUsername;
    }

    await _authService.initialize(_username);

    // Fetch storage info for all accounts
    for (final account in _authService.accounts) {
      await _refreshAccountStorage(account.id);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _authService.signIn();

    if (success) {
      for (final account in _authService.accounts) {
        await _refreshAccountStorage(account.id);
      }
    } else {
      _error = 'Sign in failed. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> addAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _authService.addAccount();

    if (success) {
      final latestAccount = _authService.accounts.last;
      await _refreshAccountStorage(latestAccount.id);
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> removeAccount(String accountId) async {
    await _authService.removeAccount(accountId);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }

  Future<void> refreshAccounts() async {
    _isLoading = true;
    notifyListeners();

    for (final account in _authService.accounts) {
      await _refreshAccountStorage(account.id);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _refreshAccountStorage(String accountId) async {
    try {
      final quota = await _driveService.getStorageQuota(accountId);
      _authService.updateAccountStorage(
        accountId,
        storageUsed: quota['used'],
        storageTotal: quota['total'],
      );
    } catch (e) {
      debugPrint('Failed to refresh storage for $accountId: $e');
    }
  }
}
