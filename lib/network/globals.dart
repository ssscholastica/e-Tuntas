import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
const String baseURL = 'http://192.168.11.97:8000/api/';
const String baseURLStorage = 'http://192.168.11.97:8000/';

Future<Map<String, String>> getHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token') ?? '';
  final tokenType = prefs.getString('token_type') ?? 'Bearer';

  debugPrint("Using token: $tokenType $token");

  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
