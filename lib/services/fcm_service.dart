import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:etuntas/network/globals.dart';
import 'dart:convert';

class FCMService {
  static Future<void> saveTokenToServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      final accessToken = prefs.getString('access_token');

      debugPrint('=== FCM Token Save Debug ===');
      debugPrint('Email from prefs: $email');
      debugPrint('Access token exists: ${accessToken != null}');

      if (email == null) {
        debugPrint('ERROR: Email is null in SharedPreferences');
        return;
      }

      if (accessToken == null) {
        debugPrint('ERROR: Access token is null in SharedPreferences');
        return;
      }

      // Get FCM token
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM Token: ${token?.substring(0, 20)}...');

      if (token == null) {
        debugPrint('ERROR: FCM token is null');
        return;
      }

      // Use JSON method (your backend supports both JSON and form-data)
      await _saveTokenAsJSON(email, token, accessToken);

      // Alternative: Use Form-Data method if needed
      // await _saveTokenAsFormData(email, token, accessToken);
    } catch (e, stackTrace) {
      debugPrint('ERROR in saveTokenToServer: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // FIXED: Method with proper JSON body
  static Future<void> _saveTokenAsJSON(
      String email, String token, String accessToken) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final bodyData = {
        'email': email,
        'device_token': token,
      };

      debugPrint('=== Sending JSON Request ===');
      debugPrint('Headers: $headers');
      debugPrint('Body: $bodyData');

      final response = await http.post(
        Uri.parse('${baseURL}save-token'),
        headers: headers,
        body: jsonEncode(bodyData), 
      );

      debugPrint('=== JSON API Response ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('SUCCESS: Token saved - ${responseData['message']}');
      } else {
        debugPrint('ERROR: API call failed with status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in _saveTokenAsJSON: $e');
    }
  }

  // Method with Form-Data body (alternative approach)
  static Future<void> _saveTokenAsFormData(
      String email, String token, String accessToken) async {
    try {
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final body = {
        'email': email,
        'device_token': token,
      };

      debugPrint('=== Sending Form-Data Request ===');
      debugPrint('Headers: $headers');
      debugPrint('Body: $body');

      final response = await http.post(
        Uri.parse('${baseURL}save-token'),
        headers: headers,
        body: body, // Map is fine for form-data
      );

      debugPrint('=== Form-Data API Response ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('SUCCESS: Token saved - ${responseData['message']}');
      } else {
        debugPrint('ERROR: API call failed with status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in _saveTokenAsFormData: $e');
    }
  }

  // Alternative method without auth (for testing)
  static Future<void> saveTokenToServerNoAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      final token = await FirebaseMessaging.instance.getToken();

      if (email != null && token != null) {
        final response = await http.post(
          Uri.parse('${baseURL}save-token-public'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
          body: {
            'email': email,
            'device_token': token,
          },
        );

        debugPrint(
            'No-Auth FCM Response: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in saveTokenToServerNoAuth: $e');
    }
  }

  // Method to check stored data
  static Future<void> debugStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('=== Stored Data Debug ===');
    debugPrint('Email: ${prefs.getString('user_email')}');
    debugPrint('NIK: ${prefs.getString('user_nik')}');
    debugPrint(
        'Access Token exists: ${prefs.getString('access_token') != null}');
    debugPrint(
        'Access Token preview: ${prefs.getString('access_token')?.substring(0, 20)}...');
  }
}

class FCMTokenManager {
  static const String _tokenKey = 'fcm_token';
  static const String _lastSyncKey = 'fcm_last_sync';
  
  static Future<void> initializeAndSync() async {
    print("=== FCM TOKEN SYNC DEBUG ===");
    
    // 1. Dapatkan token saat ini dari Firebase
    String? currentToken = await FirebaseMessaging.instance.getToken();
    print("FCM DEBUG: Current Firebase token: $currentToken");
    
    // 2. Dapatkan token yang tersimpan lokal
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString(_tokenKey);
    String? lastSync = prefs.getString(_lastSyncKey);
    
    print("FCM DEBUG: Saved local token: $savedToken");
    print("FCM DEBUG: Last sync: $lastSync");
    
    // 3. Bandingkan token
    bool tokenChanged = currentToken != savedToken;
    print("FCM DEBUG: Token changed: $tokenChanged");
    
    // 4. Sync ke server jika berbeda atau belum pernah sync
    if (tokenChanged || lastSync == null) {
      await _syncTokenToServer(currentToken);
      
      // Simpan token baru ke local storage
      if (currentToken != null) {
        await prefs.setString(_tokenKey, currentToken);
        await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      }
    }
    
    // 5. Listen token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) {
      print("FCM DEBUG: Token refreshed to: $newToken");
      _syncTokenToServer(newToken);
      
      // Update local storage
      prefs.setString(_tokenKey, newToken);
      prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    });
    
    // 6. Setup message listeners dengan debug
    _setupMessageListeners();
  }
  
  static Future<void> _syncTokenToServer(String? token) async {
    if (token == null) return;
    
    try {
      print("FCM DEBUG: Syncing token to server...");
      
      // Ambil email user (sesuaikan dengan sistem auth Anda)
      String userEmail = await _getCurrentUserEmail(); // Implement sesuai kebutuhan
      
      final response = await http.post(
        Uri.parse('YOUR_LARAVEL_DOMAIN/api/update-fcm-token'), // Sesuaikan URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_AUTH_TOKEN', // Jika pakai auth
        },
        body: jsonEncode({
          'email': userEmail,
          'fcm_token': token,
          'device_info': {
            'platform': 'flutter',
            'timestamp': DateTime.now().toIso8601String(),
          }
        }),
      );
      
      if (response.statusCode == 200) {
        print("FCM DEBUG: ✓ Token synced successfully");
        print("FCM DEBUG: Server response: ${response.body}");
      } else {
        print("FCM DEBUG: ✗ Token sync failed: ${response.statusCode}");
        print("FCM DEBUG: Error: ${response.body}");
      }
    } catch (e) {
      print("FCM DEBUG: ✗ Token sync exception: $e");
    }
  }
  
  static void _setupMessageListeners() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("FCM DEBUG: ✓ FOREGROUND MESSAGE RECEIVED!");
      print("FCM DEBUG: Title: ${message.notification?.title}");
      print("FCM DEBUG: Body: ${message.notification?.body}");
      print("FCM DEBUG: Data: ${message.data}");
      
      // Tampilkan notifikasi lokal jika diperlukan
      _showLocalNotification(message);
    });
    
    // Background/terminated app messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("FCM DEBUG: ✓ NOTIFICATION TAPPED!");
      print("FCM DEBUG: Data: ${message.data}");
    });
  }
  
  static void _showLocalNotification(RemoteMessage message) {
    // Implementasi show local notification untuk foreground
    // Gunakan flutter_local_notifications package
    print("FCM DEBUG: Showing local notification...");
  }
  
  static Future<String> _getCurrentUserEmail() async {
    // Implement sesuai sistem auth Anda
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email') ?? 'nzaahiya@gmail.com'; // Default untuk testing
  }
  
  // Method untuk manual test
  static Future<void> testCurrentToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM TEST: Current token: $token");
    
    if (token != null) {
      await _syncTokenToServer(token);
    }
  }
}
