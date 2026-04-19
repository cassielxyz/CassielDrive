import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;
import 'package:cassiel_drive/core/constants/app_constants.dart';

/// Web OAuth flow using popup window
Future<Map<String, String>?> performOAuthFlow({
  required String clientId,
  required String clientSecret,
  required List<String> scopes,
}) async {
  // Build redirect URI from current origin
  final origin = web.window.location.origin;
  final redirectUri = '$origin${AppConstants.webRedirectPath}';

  final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
    'client_id': clientId,
    'redirect_uri': redirectUri,
    'response_type': 'code',
    'scope': scopes.join(' '),
    'access_type': 'offline',
    'prompt': 'consent',
  });

  // Open popup window for OAuth
  final completer = Completer<String?>();

  final popup = web.window.open(
    authUrl.toString(),
    'cassiel_oauth',
    'width=500,height=700,scrollbars=yes,resizable=yes',
  );

  // Listen for postMessage from the callback page
  void handleMessage(web.MessageEvent event) {
    final data = event.data;
    // Convert JSAny to Dart Map
    if (data != null) {
      try {
        final dartObj = data.dartify();
        if (dartObj is Map && dartObj.containsKey('cassiel_oauth_code')) {
          final code = dartObj['cassiel_oauth_code'] as String?;
          if (!completer.isCompleted) {
            completer.complete(code);
          }
        }
      } catch (_) {
        // Not a valid message, ignore
      }
    }
  }

  web.EventHandler jsListener = handleMessage.toJS;
  web.window.addEventListener('message', jsListener);

  // Also poll for popup close (user cancelled)
  Timer.periodic(const Duration(milliseconds: 500), (timer) {
    final isClosed = popup?.closed ?? true;
    if (isClosed) {
      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      web.window.removeEventListener('message', jsListener);
    }
  });

  // Wait for the code
  String? code;
  try {
    code = await completer.future.timeout(const Duration(minutes: 3));
  } catch (e) {
    debugPrint('OAuth timeout or error: $e');
    web.window.removeEventListener('message', jsListener);
    return null;
  }

  web.window.removeEventListener('message', jsListener);

  if (code == null || code.isEmpty) return null;

  // Exchange code for tokens
  try {
    final tokenResponse = await http.post(
      Uri.parse(AppConstants.oauthTokenEndpoint),
      body: {
        'code': code,
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
      },
    );

    if (tokenResponse.statusCode == 200) {
      final tokenData = jsonDecode(tokenResponse.body);
      return {
        'access_token': tokenData['access_token'] ?? '',
        'refresh_token': tokenData['refresh_token'] ?? '',
      };
    } else {
      debugPrint('Token exchange failed: ${tokenResponse.body}');
      return null;
    }
  } catch (e) {
    debugPrint('Token exchange error: $e');
    return null;
  }
}
