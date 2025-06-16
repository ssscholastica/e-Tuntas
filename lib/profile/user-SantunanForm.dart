import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etuntas/models/comment_model.dart';
import 'package:etuntas/network/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

class formSantunanUser extends StatefulWidget {
  final String pengaduanId;
  final Map<String, dynamic> pengaduanData;
  final Function onStatusUpdated;

  const formSantunanUser({
    Key? key,
    required this.pengaduanId,
    required this.pengaduanData,
    required this.onStatusUpdated,
  }) : super(key: key);

  @override
  State<formSantunanUser> createState() => _formSantunanUserState();
}

class _formSantunanUserState extends State<formSantunanUser> {
  final Dio _dio = Dio();
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  // Map untuk menyimpan file yang dipilih per kolom
  Map<String, PlatformFile?> _pickedFiles = {};
  // Map untuk menyimpan status loading per dokumen
  Map<String, bool> _loadingStates = {};

  @override
  void initState() {
    super.initState();
  }

  // Fungsi untuk memilih file dari perangkat untuk kolom spesifik
  Future<void> _pickFile(String documentKey) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _pickedFiles[documentKey] = result.files.first;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'File "${_pickedFiles[documentKey]!.name}" berhasil dipilih untuk ${documentKey.replaceAll('_', ' ').toUpperCase()}.'),
            backgroundColor: Colors.blueAccent,
          ),
        );
      } else {
        setState(() {
          _pickedFiles.remove(documentKey);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pemilihan dokumen dibatalkan.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saat memilih file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih dokumen: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _pickedFiles.remove(documentKey);
      });
    }
  }

  // Fungsi untuk upload dokumen individual
  Future<void> _uploadSingleDocument(String documentKey) async {
    final file = _pickedFiles[documentKey];
    if (file == null) return;

    setState(() {
      _loadingStates[documentKey] = true;
    });

    try {
      String? authToken = await getStoredAuthToken();

      if (authToken == null) {
        throw Exception('No authentication token found');
      }

      FormData formData = FormData();
      formData.files.add(MapEntry(
        documentKey,
        await MultipartFile.fromFile(file.path!, filename: file.name),
      ));

      final sourceTable = widget.pengaduanData['source_table'];
      final pengajuanId = widget.pengaduanData['id'];

      // Updated URL construction logic
      String urlSourceTable = _getUrlSourceTable(sourceTable);
      final url = '${baseURL}update-pengajuan/$urlSourceTable/$pengajuanId';

      debugPrint('Uploading single document: $documentKey to URL: $url');

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('Upload dokumen $documentKey sukses');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Dokumen ${documentKey.replaceAll('_', ' ').toUpperCase()} berhasil diupdate.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _pickedFiles.remove(documentKey);
          // Update dokumen path di pengaduanData jika response mengembalikan path baru
          if (response.data != null && response.data[documentKey] != null) {
            widget.pengaduanData[documentKey] = response.data[documentKey];
          }
        });
        widget.onStatusUpdated();
      } else {
        debugPrint('Gagal upload dokumen $documentKey: ${response.statusCode}');
        debugPrint('Response body: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal mengupdate dokumen ${documentKey.replaceAll('_', ' ').toUpperCase()}. Status: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error upload dokumen $documentKey: $e');

      String errorMsg =
          'Terjadi kesalahan saat mengupdate dokumen ${documentKey.replaceAll('_', ' ').toUpperCase()}';
      if (e is DioException) {
        debugPrint('DioException response: ${e.response?.data}');
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
        _loadingStates[documentKey] = false;
      });
    }
  }

  Future<String?> getStoredAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Fungsi untuk upload semua dokumen sekaligus
  Future<void> submitForm() async {
  if (_pickedFiles.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Silakan pilih setidaknya satu dokumen baru untuk diunggah.'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    String? authToken = await getStoredAuthToken();

    if (authToken == null) {
      throw Exception('No authentication token found');
    }

    FormData formData = FormData();

    for (var entry in _pickedFiles.entries) {
      final documentKey = entry.key;
      final file = entry.value;
      if (file != null) {
        formData.files.add(MapEntry(
          documentKey,
          await MultipartFile.fromFile(file.path!, filename: file.name),
        ));
      }
    }

    final sourceTable = widget.pengaduanData['source_table'];
    final pengajuanId = widget.pengaduanData['id'];

    // Updated URL construction logic
    String urlSourceTable = _getUrlSourceTable(sourceTable);
    final url = '${baseURL}update-pengajuan/$urlSourceTable/$pengajuanId';
    
    debugPrint('Calling URL: $url');
    debugPrint('Uploading files with keys: ${_pickedFiles.keys.toList()}');

    final response = await _dio.post(
      url,
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        followRedirects: false,
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode == 200) {
      debugPrint('Upload sukses');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semua dokumen berhasil diupdate.'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        // Update semua dokumen path di pengaduanData jika response mengembalikan path baru
        if (response.data != null && response.data is Map) {
          response.data.forEach((key, value) {
            if (widget.pengaduanData.containsKey(key)) {
              widget.pengaduanData[key] = value;
            }
          });
        }
        _pickedFiles.clear();
      });
      widget.onStatusUpdated();
    } else {
      debugPrint('Gagal upload: ${response.statusCode}');
      debugPrint('Response: ${response.data}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupdate dokumen. Status: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    debugPrint('Error upload: $e');

    String errorMsg = 'Terjadi kesalahan saat mengupdate dokumen';
    if (e is DioException) {
      debugPrint('DioException details: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
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

// Add this helper method to your class
String _getUrlSourceTable(String sourceTable) {
  final normalizedSourceTable = sourceTable.trim().toLowerCase();
  
  switch (normalizedSourceTable) {
    case 'pengajuan-santunan':
    case 'pengajuan_santunan':
    case 'pengajuan-santunan1':
    case 'pengajuan_santunan1':
    case 'santunan1':
      return 'pengajuan-santunan';
      
    case 'pengajuan-santunan2':
    case 'pengajuan_santunan2':
    case 'santunan2':
      return 'pengajuan-santunan2';
      
    case 'pengajuan-santunan3':
    case 'pengajuan_santunan3':
    case 'santunan3':
      return 'pengajuan-santunan3';
      
    case 'pengajuan-santunan4':
    case 'pengajuan_santunan4':
    case 'santunan4':
      return 'pengajuan-santunan4';
      
    case 'pengajuan-santunan5':
    case 'pengajuan_santunan5':
    case 'santunan5':
      return 'pengajuan-santunan5';
      
    default:
      debugPrint('Unknown source table: $sourceTable, using default: pengajuan-santunan');
      return 'pengajuan-santunan';
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
      debugPrint('Error getting CSRF token: $e');
      return null;
    }
  }

  void _refreshSession() async {
    try {
      debugPrint('Session redirect detected, refreshing session silently');
    } catch (e) {
      debugPrint('Failed to refresh session: $e');
    }
  }

  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '-';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  List<Widget> buildDokumenList() {
    List<Map<String, String>> dokumen = [];
    final sourceTable = widget.pengaduanData['source_table'] ?? '';

    debugPrint('=== DEBUG PENGADUAN DATA ===');
    debugPrint('Semua data pengaduan: ${widget.pengaduanData}');
    debugPrint('source_table: "$sourceTable"');
    debugPrint('source_table type: ${sourceTable.runtimeType}');
    debugPrint('source_table length: ${sourceTable.length}');
    debugPrint('================================');

    final normalizedSourceTable = sourceTable.trim().toLowerCase();
    debugPrint('Normalized source_table: "$normalizedSourceTable"');

    switch (normalizedSourceTable) {
      case 'pengajuan-santunan': 
      case 'pengajuan_santunan': 
      case 'pengajuan-santunan1':
      case 'pengajuan_santunan1':
      case 'santunan1':
        debugPrint('Masuk ke case santunan1');
        dokumen = [
          {'label': 'Surat Kematian', 'key': 'surat_kematian'},
          {'label': 'Kartu Keluarga', 'key': 'kartu_keluarga'},
          {'label': 'KTP Pensiunan dan Anak', 'key': 'ktp_pensiunan_dan_anak'},
          {'label': 'Buku Rekening Anak', 'key': 'buku_rekening_anak'},
        ];
        break;

      case 'pengajuan-santunan2':
      case 'pengajuan_santunan2':
      case 'santunan2':
        debugPrint('Masuk ke case santunan2');
        dokumen = [
          {'label': 'Surat Kematian', 'key': 'surat_kematian'},
          {'label': 'Kartu Keluarga', 'key': 'kartu_keluarga'},
          {'label': 'Surat Nikah', 'key': 'surat_nikah'},
          {'label': 'KTP Suami Istri', 'key': 'ktp_suami_istri'},
          {'label': 'Buku Rekening Istri', 'key': 'buku_rekening_istri'},
        ];
        break;

      case 'pengajuan-santunan3':
      case 'pengajuan_santunan3':
      case 'santunan3':
        debugPrint('Masuk ke case santunan3');
        dokumen = [
          {'label': 'Surat Kematian', 'key': 'surat_kematian'},
          {'label': 'Kartu Keluarga', 'key': 'kartu_keluarga'},
          {'label': 'Surat Kuasa', 'key': 'surat_kuasa'},
          {'label': 'KTP Pensiunan Anak', 'key': 'ktp_pensiunan_anak'},
          {'label': 'Buku Rekening Anak', 'key': 'buku_rekening_anak'},
        ];
        break;

      case 'pengajuan-santunan4':
      case 'pengajuan_santunan4':
      case 'santunan4':
        debugPrint('Masuk ke case santunan4');
        dokumen = [
          {'label': 'Surat Kematian', 'key': 'surat_kematian'},
          {'label': 'Surat Keterangan', 'key': 'surat_keterangan'},
          {'label': 'Surat Kuasa', 'key': 'surat_kuasa'},
          {'label': 'Kartu Keluarga', 'key': 'kartu_keluarga'},
          {'label': 'KTP Pensiunan Anak', 'key': 'ktp_pensiunan_anak'},
          {'label': 'Buku Rekening Anak', 'key': 'buku_rekening_anak'},
        ];
        break;

      case 'pengajuan-santunan5':
      case 'pengajuan_santunan5':
      case 'santunan5':
        debugPrint('Masuk ke case santunan5');
        dokumen = [
          {'label': 'Surat Kematian', 'key': 'surat_kematian'},
          {'label': 'Kartu Keluarga', 'key': 'kartu_keluarga'},
          {'label': 'KTP Pensiunan Anak', 'key': 'ktp_pensiunan_anak'},
          {'label': 'Surat Keterangan', 'key': 'surat_keterangan'},
          {'label': 'Surat Kuasa', 'key': 'surat_kuasa'},
          {'label': 'Buku Rekening Anak', 'key': 'buku_rekening_anak'},
        ];
        break;

      default:
        debugPrint('Masuk ke default case - source_table tidak dikenali');
        debugPrint('Nilai source_table: "$sourceTable"');
        debugPrint('Nilai normalized: "$normalizedSourceTable"');

        List<String> possibleDocKeys = [];
        widget.pengaduanData.keys.forEach((key) {
          if (key.contains('surat') ||
              key.contains('ktp') ||
              key.contains('kartu') ||
              key.contains('buku')) {
            possibleDocKeys.add(key);
          }
        });

        if (possibleDocKeys.isNotEmpty) {
          debugPrint('Dokumen yang ditemukan: $possibleDocKeys');
          dokumen = possibleDocKeys
              .map((key) =>
                  {'label': key.replaceAll('_', ' ').toUpperCase(), 'key': key})
              .toList();
        } else {
          dokumen = [
            {
              'label': 'Dokumen tidak dikenali (source: $sourceTable)',
              'key': ''
            },
          ];
        }
    }

    debugPrint('Dokumen yang akan ditampilkan: $dokumen');

    return dokumen.map((doc) {
      final filePath = widget.pengaduanData[doc['key']] ?? '';
      final fileName = filePath.split('/').last;
      final fileUrl = '${baseURLStorage}$filePath';
      final currentPickedFile = _pickedFiles[doc['key']];
      final isDocumentLoading = _loadingStates[doc['key']] ?? false;

      debugPrint(
          'Processing dokumen: ${doc['label']}, key: ${doc['key']}, filePath: $filePath');

      return Card(
        margin: EdgeInsets.only(bottom: 16),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc['label']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),

              // Dokumen yang sudah ada
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      filePath.isNotEmpty
                          ? Icons.file_present
                          : Icons.file_copy_outlined,
                      color: filePath.isNotEmpty ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: filePath.isNotEmpty
                          ? GestureDetector(
                              onTap: () async {
                                final url = Uri.parse(fileUrl);
                                try {
                                  bool launched = await launchUrl(
                                    url,
                                    mode: LaunchMode
                                        .externalNonBrowserApplication,
                                  );
                                  if (!launched) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                } catch (e) {
                                  debugPrint('Could not launch $fileUrl: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Tidak dapat membuka dokumen: $fileName'),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                fileName,
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : Text(
                              'Belum ada dokumen',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // File yang baru dipilih
              if (currentPickedFile != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file,
                          color: Colors.green[700], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'File baru: ${currentPickedFile.name}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear, size: 18, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _pickedFiles.remove(doc['key']);
                          });
                        },
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 12),

              // Tombol aksi
              Row(
                children: [
                  // Tombol pilih file
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isDocumentLoading
                          ? null
                          : () => _pickFile(doc['key']!),
                      icon: Icon(Icons.upload_file, size: 18),
                      label: Text(
                        currentPickedFile != null ? "Ganti File" : "Pilih File",
                        style: TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 8),

                  // Tombol update individual
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: currentPickedFile != null && !isDocumentLoading
                          ? () => _uploadSingleDocument(doc['key']!)
                          : null,
                      icon: isDocumentLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.cloud_upload, size: 18),
                      label: Text(
                        isDocumentLoading ? "Upload..." : "Update",
                        style: TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentPickedFile != null
                            ? Colors.green
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Map<String, String>> getDokumenByPattern(Map<String, dynamic> data) {
    List<Map<String, String>> foundDokumen = [];

    final docPatterns = {
      'surat_kematian': 'Surat Kematian',
      'kartu_keluarga': 'Kartu Keluarga',
      'surat_nikah': 'Surat Nikah',
      'surat_kuasa': 'Surat Kuasa',
      'surat_keterangan': 'Surat Keterangan',
      'ktp_pensiunan_dan_anak': 'KTP Pensiunan dan Anak',
      'ktp_suami_istri': 'KTP Suami Istri',
      'ktp_pensiunan_anak': 'KTP Pensiunan Anak',
      'buku_rekening_anak': 'Buku Rekening Anak',
      'buku_rekening_istri': 'Buku Rekening Istri',
    };

    data.keys.forEach((key) {
      if (docPatterns.containsKey(key)) {
        foundDokumen.add({
          'label': docPatterns[key]!,
          'key': key,
        });
      }
    });

    return foundDokumen;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Detail Pengajuan Santunan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info fields
              buildInfoField('No Pendaftaran',
                  widget.pengaduanData['no_pendaftaran'] ?? '-'),
              buildInfoField('PTPN', widget.pengaduanData['ptpn'] ?? '-'),
              buildInfoField('Lokasi', widget.pengaduanData['lokasi'] ?? '-'),
              buildInfoField('Tanggal Meninggal',
                  widget.pengaduanData['tanggal_meninggal'] ?? '-'),
              buildInfoField('Lokasi Meninggal',
                  widget.pengaduanData['lokasi_meninggal'] ?? '-'),
              buildInfoField('Tanggal Pengajuan',
                  formatDateTime(widget.pengaduanData['updated_at'])),
              buildInfoField('Status', widget.pengaduanData['status'] ?? '-'),

              const SizedBox(height: 20),

              // Section header untuk dokumen
              Text(
                'Dokumen Persyaratan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),

              // Daftar dokumen
              ...buildDokumenList(),

              const SizedBox(height: 20),

              // Tombol "Update Semua Dokumen" - hanya muncul jika ada file yang dipilih
              if (_pickedFiles.isNotEmpty)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: !isLoading ? submitForm : null,
                    icon: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(isLoading
                        ? "Mengunggah Semua..."
                        : "Update Semua Dokumen"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
}
