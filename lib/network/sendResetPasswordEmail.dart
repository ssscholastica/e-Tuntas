import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:etuntas/network/globals.dart';

Future<void> sendResetPasswordEmail(String email) async {
  final url = Uri.parse("${baseURL}password/forgot");
  try {
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode != 200) {
      Map<String, dynamic> errorData;
      try {
        errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Failed to send reset email");
      } catch (e) {
        throw Exception("Error: ${response.body}");
      }
    }
  } catch (e) {
    throw Exception("Network error: ${e.toString()}");
  }
}
