import 'package:etuntas/network/globals.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  static Future<void> saveTokenToServer() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final token = await FirebaseMessaging.instance.getToken();

    if (email != null && token != null) {
      try {
        final headers = await getHeaders(); // Pastikan sudah termasuk Authorization: Bearer
        final response = await http.post(
          Uri.parse('${baseURL}save-token'), // Ganti sesuai endpoint Laravel
          headers: headers,
          body: {
            'email': email,
            'token': token, // sesuaikan dengan Laravel
          },
        );

        if (response.statusCode == 200) {
          debugPrint('✅ FCM token sent to server.');
        } else {
          debugPrint('⚠️ Failed to send FCM token: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        debugPrint('❌ Exception while saving FCM token: $e');
      }
    } else {
      debugPrint('⚠️ Email or FCM token is null. Cannot send token.');
    }
  }
}
