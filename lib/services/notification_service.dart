import 'dart:convert';
import 'package:etuntas/models/notification_model.dart';
import 'package:etuntas/network/globals.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {

  static Future<String?> getLoggedInEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  static Future<List<NotificationModel>> fetchNotifications(
      String token) async {
    final email = await getLoggedInEmail();
    print('📧 Email dari SharedPreferences: $email');
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('${baseURL}notifications?email=$email'),
      headers: headers,
    );

    print('STATUS CODE: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final decoded = json.decode(response.body);
        print('DECODED JSON: $decoded');

        final List data = decoded['notifications'];
        print('PARSED DATA: $data');
        print('DATA LENGTH: ${data.length}');

        return data.map((e) => NotificationModel.fromJson(e)).toList();
      } catch (e) {
        print('JSON PARSE ERROR: $e');
        throw Exception('Gagal parsing notifikasi');
      }
    } else {
      print('FAILED REQUEST: ${response.body}');
      throw Exception('Gagal memuat notifikasi');
    }
  }

  static Future<void> markAsRead(int id, String token) async {
    final email = await getLoggedInEmail();

    if (email == null) {
      throw Exception('Email pengguna tidak ditemukan');
    }

    final headers = await getHeaders();
    final response = await http.patch(
      Uri.parse('${baseURL}notifications/$id'),
      headers: headers,
      body: json.encode({
        'email': email,
      }),
    );

    print('MARK AS READ STATUS: ${response.statusCode}');
    print('MARK AS READ RESPONSE: ${response.body}');

    if (response.statusCode != 200) {
      final errorBody = json.decode(response.body);
      print('ERROR DETAILS: $errorBody');
      throw Exception(
          'Gagal menandai sebagai dibaca: ${errorBody['message'] ?? 'Unknown error'}');
    }
  }
}
