import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:cassiel_drive/core/constants/app_constants.dart';

/// Desktop/mobile OAuth flow using loopback server on 127.0.0.1
/// Uses a dynamic port and inAppBrowserView to keep the app alive on Android.
Future<Map<String, String>?> performOAuthFlow({
  required String clientId,
  required String clientSecret,
  required List<String> scopes,
}) async {
  // Start a temporary local HTTP server to catch the redirect
  // Use port 0 to let the OS assign an available port (avoids conflicts)
  HttpServer? server;
  try {
    server = await HttpServer.bind('127.0.0.1', 0);
  } catch (e) {
    debugPrint('Failed to bind local server: $e');
    return null;
  }

  final port = server.port;
  final redirectUri = 'http://127.0.0.1:$port';
  debugPrint('OAuth loopback server started on port $port');

  final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
    'client_id': clientId,
    'redirect_uri': redirectUri,
    'response_type': 'code',
    'scope': scopes.join(' '),
    'access_type': 'offline',
    'prompt': 'consent',
  });

  // Try inAppBrowserView first (keeps the app alive on Android),
  // fall back to externalApplication if that fails.
  bool launched = false;
  try {
    launched =
        await launchUrl(authUrl, mode: LaunchMode.externalApplication);
  } catch (_) {
    launched = false;
  }
  if (!launched) {
    try {
      launched = await launchUrl(authUrl, mode: LaunchMode.inAppBrowserView);
    } catch (_) {
      launched = false;
    }
  }

  if (!launched) {
    debugPrint('Failed to launch browser for OAuth');
    await server.close();
    return null;
  }

  // Wait for the redirect with the authorization code
  try {
    final request = await server.first.timeout(const Duration(minutes: 5));
    final code = request.uri.queryParameters['code'];
    final error = request.uri.queryParameters['error'];

    if (error != null) {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..write(
            '<html><body style="font-family:sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;background:#0a0a0a;color:white;">'
            '<div style="text-align:center"><h1>✗ Authentication Failed</h1><p>Error: $error</p><p>Please close this tab and try again.</p></div>'
            '</body></html>');
      await request.response.close();
      await server.close();
      return null;
    }

    // Send a nice HTML response to the browser
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..write(
          '<html><body style="font-family:sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;background:#0a0a0a;color:white;">'
          '<div style="text-align:center">'
          '<div style="width:64px;height:64px;margin:0 auto 20px;background:linear-gradient(135deg,#25A7DA,#3CC6F5);border-radius:16px;display:flex;align-items:center;justify-content:center;font-size:28px;">✓</div>'
          '<h1 style="margin:0 0 8px;">Success!</h1>'
          '<p style="color:#999;">You can close this tab and return to Cassiel Drive.</p></div>'
          '</body></html>');
    await request.response.close();
    await server.close();

    if (code == null || code.isEmpty) return null;

    // Exchange the code for tokens
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
    debugPrint('OAuth flow error: $e');
    await server.close();
    return null;
  }
}
