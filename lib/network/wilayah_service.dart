import 'dart:convert';
import 'package:etuntas/network/globals.dart';
import 'package:http/http.dart' as http;

class WilayahService {

  static Future<List<String>> fetchKota() async {
    final response = await http.get(Uri.parse(baseURL + 'api/kota'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((kota) => kota['nama_kota'] as String).toList();
    } else {
      throw Exception('Gagal memuat data kota');
    }
  }
}
