import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:etuntas/network/globals.dart';

class FCMService {
  static Future<void> saveTokenToServer() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final token = await FirebaseMessaging.instance.getToken();

    if (email != null && token != null) {
      try {
        final accessToken = prefs.getString('access_token');
        final headers = await getHeaders();
        final response = await http.post(
          Uri.parse(
              '${baseURL}save-token'), // GANTI ke URL endpoint Laravel kamu
          headers: headers,
          body: {
            'email': email,
            'device_token': token,
          },
        );

        debugPrint('FCM token sent: ${response.statusCode} - ${response.body}');
      } catch (e) {
        debugPrint('Error saving FCM token: $e');
      }
    }
  }
}
