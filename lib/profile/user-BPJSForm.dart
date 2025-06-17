import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:etuntas/network/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

class formBPJSUser extends StatefulWidget {
  final String pengaduanId;
  final Map<String, dynamic> pengaduanData;
  final Function onStatusUpdated;

  const formBPJSUser({
    Key? key,
    required this.pengaduanId,
    required this.pengaduanData,
    required this.onStatusUpdated,
  }) : super(key: key);

  @override
  State<formBPJSUser> createState() => _formBPJSUserState();
}

class _formBPJSUserState extends State<formBPJSUser> {
  final Dio _dio = Dio();
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  bool statusChanged = false;
  PlatformFile? _pickedFile;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> submitForm() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get the stored auth token
      String? authToken = await getStoredAuthToken();

      if (authToken == null) {
        throw Exception('No authentication token found');
      }

      FormData formData = FormData();

      if (_pickedFile != null) {
        formData.files.add(MapEntry(
          'data_pendukung',
          await MultipartFile.fromFile(_pickedFile!.path!,
              filename: _pickedFile!.name),
        ));
      }

      // Fixed URL - added 'api/' prefix
      final url =
          '${baseURL}update-pengaduan/${widget.pengaduanData['id']}';
      print('Calling URL: $url'); // Debug line

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $authToken',
            // Don't set Content-Type for multipart - let Dio handle it
          },
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        print('Upload sukses');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dokumen berhasil diupdate.'),
            backgroundColor: Colors.green,
          ),
        );

        widget.onStatusUpdated();
      } else {
        print('Gagal upload: ${response.statusCode}');
        print('Response: ${response.data}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal mengupdate dokumen. Status: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error upload: $e');

      String errorMsg = 'Terjadi kesalahan saat mengupdate dokumen';
      if (e is DioException) {
        print('DioException details: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');

        if (e.response?.statusCode == 401) {
          errorMsg = 'Sesi telah berakhir. Silakan login kembali.';
        } else if (e.response?.statusCode == 404) {
          errorMsg = 'Endpoint tidak ditemukan. Periksa URL server.';
        } else if (e.response?.statusCode == 422) {
          errorMsg = 'Data tidak valid. Periksa file yang diupload.';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

// You need to implement this method based on how you store auth tokens
  Future<String?> getStoredAuthToken() async {
    // Example using SharedPreferences:
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');

    // Or if you're using a global variable or state management:
    // return GlobalData.authToken;

  }



  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  Future<String?> getCsrfToken() async {
    try {
      final response =
          await http.get(Uri.parse('${baseURL}sanctum/csrf-cookie'));

      String? csrfToken;
      if (response.headers['set-cookie'] != null) {
        final cookies = response.headers['set-cookie']!;
        final xsrfCookie = cookies.split(';').firstWhere(
              (cookie) => cookie.trim().startsWith('XSRF-TOKEN='),
              orElse: () => '',
            );

        if (xsrfCookie.isNotEmpty) {
          csrfToken = xsrfCookie.split('=')[1];
          csrfToken = Uri.decodeComponent(csrfToken);
        }
      }

      return csrfToken;
    } catch (e) {
      print('Error getting CSRF token: $e');
      return null;
    }
  }

// Function to refresh session or token silently
  void _refreshSession() async {
    try {
      // Implement your token refresh logic here
      // This could be a silent refresh of the token without interrupting the user
      print('Session redirect detected, refreshing session silently');

      // Example:
      // final refreshedToken = await refreshAuthToken();
      // await saveAuthToken(refreshedToken);
    } catch (e) {
      print('Failed to refresh session: $e');
      // You might want to queue a delayed login prompt if this fails repeatedly
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, statusChanged);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Detail Pengaduan BPJS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, statusChanged);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInfoField('Nomor BPJS/NIK',
                  widget.pengaduanData['nomor_bpjs_nik'] ?? '-'),
              buildInfoField('Kategori BPJS',
                  widget.pengaduanData['kategori_bpjs'] ?? '-'),
              buildInfoField(
                  'Deskripsi', widget.pengaduanData['deskripsi'] ?? '-'),
              if (widget.pengaduanData['data_pendukung'] != null)
                buildDataPendukung(),
              buildInfoField('Status', widget.pengaduanData['status'] ?? '-'),
              SizedBox(height: 20,),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickedFile != null ? submitForm : null,
                  icon: const Icon(Icons.save),
                  label: const Text("Update Dokumen"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(top: 10, left: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0XFF000000),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          child: Container(
            height: 50,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDataPendukung() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Data Pendukung',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        if (_pickedFile != null)
          Text(_pickedFile!.name)
        else if (widget.pengaduanData['data_pendukung'] != null)
          GestureDetector(
            onTap: () {
              final url =
                  '${baseURLStorage}storage/${widget.pengaduanData['data_pendukung']}';
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
            child: const Text(
              "Lihat File",
              style: TextStyle(
                color: Colors.purple,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: pickFile,
          icon: const Icon(Icons.upload_file),
          label: const Text("Upload Ulang File"),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
