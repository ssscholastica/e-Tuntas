import 'dart:convert';

import 'package:etuntas/network/globals.dart';
import 'package:http/http.dart' as http;

class AuthServices {
  static Future<http.Response> register(
      String name,
      String email,
      String alamat,
      String tanggalLahir,
      String nomorHP,
      String pgUnit,
      String noPensiunan,
      String nik,
      String namaBersangkutan,
      String status) async {
    Map data = {
      'Nama': name,
      'Email': email,
      'Alamat': alamat,
      'Tanggal Lahir': tanggalLahir,
      'Nomor HP': nomorHP,
      'PG Unit': pgUnit,
      'Nomor Pensiunan': noPensiunan,
      'NIK': nik,
      'Nama Bersangkutan': namaBersangkutan,
      'Status': status
    };
    var body = json.encode(data);
    var url = Uri.parse('${baseURL}auth/register');
    final headers = await getHeaders();
    http.Response response = await http.post(url, headers: headers, body: body);
    print(response.body);
    return response;
  }

  static Future<http.Response> login(String email, String password) async {
    Map data = {'email': email, 'password': password};
    var body = json.encode(data);
    var url = Uri.parse('${baseURL}auth/login');
    final headers = await getHeaders();
    http.Response response = await http.post(url, headers: headers, body: body);
    print(response.body);
    return response;
  }
}