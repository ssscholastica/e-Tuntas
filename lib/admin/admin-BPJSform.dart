import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:etuntas/network/globals.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:etuntas/network/comment_bpjs_service.dart';
import 'package:etuntas/models/comment_bpjs_model.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class formBPJS extends StatefulWidget {
  final String pengaduanId;
  final Map<String, dynamic> pengaduanData;
  final Function onStatusUpdated;

  const formBPJS({
    Key? key,
    required this.pengaduanId,
    required this.pengaduanData,
    required this.onStatusUpdated,
  }) : super(key: key);

  @override
  State<formBPJS> createState() => _formBPJSState();
}

class _formBPJSState extends State<formBPJS> {
  final Dio _dio = Dio();
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  bool statusChanged = false;
  bool isSubmittingReply = false;
  late Future<List<Comment>> commentsFuture;

  String? selectedStatus;
  List<String> statusOptions = ['Terkirim', 'Diproses', 'Ditolak', 'Selesai'];
  TextEditingController replyController = TextEditingController();


  @override
  void initState() {
    super.initState();
    selectedStatus = widget.pengaduanData['status'] ?? 'Terkirim';
    if (!statusOptions.contains(selectedStatus)) {
      statusOptions.add(selectedStatus!);
      commentsFuture = fetchCommentByNoBPJS();
    }
  }

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  Future<Comment> fetchCommentDetail() async {
    final url = '${baseURL}commentsbpjs/${widget.pengaduanData}';
    print('Fetching comment from: $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Comment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load comment: ${response.statusCode}');
    }
  }

  Future<List<Comment>> fetchCommentByNoBPJS() async {
    final nomorBPJS = widget.pengaduanData['nomor_bpjs_nik'];

    if (nomorBPJS == null) {
      throw Exception('Nomor BPJS tidak ditemukan');
    }

    final url = '${baseURL}commentsbpjs/registration/$nomorBPJS';
    print('Fetching comments from: $url');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((json) => Comment.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        print('Tidak ada komentar ditemukan');
        return []; // list kosong
      } else {
        throw Exception('Gagal mengambil komentar: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetchCommentByNoBPJS: $e');
      rethrow;
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

  Future<void> submitReplyBPJS(int commentId, String replyText) async {
    if (replyText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Balasan tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      isSubmittingReply = true;
    });

    try {
      final csrfToken = await getCsrfToken();
      final url = '${baseURL}commentsbpjs/$commentId/reply';
      print('Submitting reply to: $url');

      final headers = await getHeaders();

      if (csrfToken != null) {
        headers['X-CSRF-TOKEN'] = csrfToken;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'comment': replyText.trim(),
          'author_type': 'admin',
        }),
      );

      print('Reply response status: ${response.statusCode}');
      print('Reply response body: ${response.body}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          (response.statusCode == 302 &&
              response.body.contains('Redirecting'))) {
        setState(() {
          commentsFuture = fetchCommentByNoBPJS();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Balasan berhasil dikirim')),
        );

        if (response.statusCode == 302) {
          _refreshSession();
        }
      } else if (response.statusCode == 302) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sesi telah berakhir. Silakan login kembali.')),
        );
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Terjadi kesalahan';
        } catch (e) {
          errorMessage = 'Terjadi kesalahan saat mengirim balasan';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim balasan: $errorMessage')),
        );
      }
    } catch (e) {
      print('Error submitting reply: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isSubmittingReply = false;
      });
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

  Future<void> updateStatus() async {
    if (selectedStatus == null) return;
    setState(() {
      isLoading = true;
    });
    try {
      // Gunakan cara yang sama seperti di fungsi fetchCommentByNoPendaftaran dan submitReply
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(
          'access_token'); // Menggunakan access_token bukan auth_token

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sesi telah berakhir. Silakan login kembali')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Tambahkan CSRF token jika diperlukan
      final csrfToken = await getCsrfToken();
      if (csrfToken != null) {
        headers['X-CSRF-TOKEN'] = csrfToken;
      }

      String apiEndpoint;
      apiEndpoint ='${baseURL}pengaduan-bpjs/${widget.pengaduanId}/status';
      apiEndpoint = apiEndpoint.replaceAll(RegExp(r'([^:])//'), r'$1/');

      print('Making PUT request to: $apiEndpoint');
      print('Using headers: $headers');

      // Gunakan http.put alih-alih _dio.put
      final response = await http.put(
        Uri.parse(apiEndpoint),
        headers: headers,
        body: jsonEncode({'status': selectedStatus}),
      );

      print('Update status response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully')),
        );
        setState(() {
          statusChanged = true;
        });
        widget.onStatusUpdated();
      } else if (response.statusCode == 302) {
        // Tangani redirect seperti pada fungsi submitReply
        if (response.body.contains('Redirecting')) {
          // Mungkin operasi berhasil sebelum redirect
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status berhasil diperbarui')),
          );
          setState(() {
            statusChanged = true;
          });
          widget.onStatusUpdated();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Sesi telah berakhir. Silakan login kembali')),
          );
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sesi telah berakhir. Silakan login kembali')),
        );
        // Di sini bisa ditambahkan navigasi ke halaman login
        // Navigator.of(context).pushReplacementNamed('/login');
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Terjadi kesalahan';
        } catch (e) {
          errorMessage = 'Gagal memperbarui status';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $errorMessage')),
        );
      }
    } catch (e) {
      print('Error saat update: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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
          title: const Text('Detail Pengaduan BPJS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),),
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
              buildInfoField(
                  'Kategori BPJS', widget.pengaduanData['kategori_bpjs'] ?? '-'),
              buildInfoField(
                  'Deskripsi', widget.pengaduanData['deskripsi'] ?? '-'),
              if (widget.pengaduanData['data_pendukung'] != null)
                buildDataPendukung(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.bottomLeft,
                    margin: const EdgeInsets.only(top: 10, left: 10),
                    child: const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0XFF000000),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedStatus,
                          isExpanded: true,
                          items: statusOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedStatus = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateStatus,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF2F2F9D))
                      : const Text(
                          'Update Status',
                          style: TextStyle(color: Color(0xFF2F2F9D), fontSize: 14),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Komentar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FutureBuilder<List<Comment>>(
                future: fetchCommentByNoBPJS(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Gagal memuat komentar: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Belum ada komentar.');
                  } else {
                    final comments = snapshot.data!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: comments.map((comment) {
                        final replyController =
                            TextEditingController(); // per komentar
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment.comment,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              ...comment.replies.map((reply) => Padding(
                                    padding:
                                        const EdgeInsets.only(left: 20, top: 5),
                                    child: Text("- ${reply.comment}"),
                                  )),
                              const SizedBox(height: 10),
                              TextField(
                                controller: replyController,
                                decoration: const InputDecoration(
                                  labelText: 'Balas komentar',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 5),
                              ElevatedButton(
                                onPressed: () => submitReplyBPJS(
                                    comment.id, replyController.text),
                                child: const Text('Kirim Balasan'),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              )

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
    final dataPendukung = widget.pengaduanData['data_pendukung'];

    // Jika hanya berupa teks biasa
    if (dataPendukung is String && !dataPendukung.contains('dokumen/')) {
      return buildInfoField('Data Pendukung', dataPendukung);
    }

    // Jika berupa file path (misal: dokumen/namafile.pdf)
    if (dataPendukung is String && dataPendukung.contains('dokumen/')) {
      final filePath = dataPendukung;
      final fileName = filePath.split('/').last;
      final fileUrl =
          '${baseURLStorage}$filePath'; // sesuaikan base URL Laravel-mu

      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Pendukung',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            TextButton(
              onPressed: () async {
                final url = Uri.parse(fileUrl);
                try {
                  bool launched = await launchUrl(
                    url,
                    mode: LaunchMode.externalNonBrowserApplication,
                  );

                  if (!launched) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                } catch (e) {
                  debugPrint('Could not launch $fileUrl: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Tidak dapat membuka dokumen: $fileName')),
                  );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.file_present, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                      child: Text(fileName, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Jika tidak cocok formatnya
    return buildInfoField('Data Pendukung', '-');
  }

}