// lib/network/pengajuan_santunan_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PengajuanSantunanService {
  static const String baseUrl =
      'http://10.0.2.2:8000/api/';

  static Future<bool> submitPengajuanSantunan({
    required String email,
    required String tanggalMeninggal,
    required String lokasiMeninggal,
    required File suratKematian,
    required File kartuKeluarga,
    required File ktpPensiunanDanAnak,
    required File bukuRekeningAnak,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}pengajuan-santunan'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      request.fields['email'] = email;
      request.fields['tanggal_meninggal'] = tanggalMeninggal;
      request.fields['lokasi_meninggal'] = lokasiMeninggal;

      // Add file uploads
      request.files.add(await http.MultipartFile.fromPath(
        'surat_kematian',
        suratKematian.path,
        contentType: MediaType('application', 'octet-stream'),
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'kartu_keluarga',
        kartuKeluarga.path,
        contentType: MediaType('application', 'octet-stream'),
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'ktp_pensiunan_dan_anak',
        ktpPensiunanDanAnak.path,
        contentType: MediaType('application', 'octet-stream'),
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'buku_rekening_anak',
        bukuRekeningAnak.path,
        contentType: MediaType('application', 'octet-stream'),
      ));

      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      print('Status code: ${response.statusCode}');
      print('Response body: ${responseBody.body}');

      // Check if the request was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to submit data: ${responseBody.body}');
        return false;
      }
    } catch (e) {
      print('Error submitting pengajuan santunan: $e');
      if (e is SocketException) {
        print('Network error: Could not connect to server');
      } else if (e is http.ClientException) {
        print('HTTP client error: ${e.message}');
      }
      return false;
    }
  }
}
