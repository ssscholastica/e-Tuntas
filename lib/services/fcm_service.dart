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
        body: jsonEncode(bodyData), // This was correct in your original code
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
