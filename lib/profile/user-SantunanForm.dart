import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:etuntas/models/comment_model.dart';
import 'package:etuntas/network/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool statusChanged = false;
  bool isSubmittingReply = false;
  late Future<List<Comment>> commentsFuture;
  Map<int, TextEditingController> replyControllers = {};

  String? selectedStatus;
  List<String> statusOptions = ['Terkirim', 'Diproses', 'Ditolak', 'Selesai'];
  TextEditingController replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.pengaduanData['status'] ?? 'Terkirim';
    if (!statusOptions.contains(selectedStatus)) {
      statusOptions.add(selectedStatus!);
      commentsFuture = fetchCommentByNoPendaftaran();
    }
  }

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  Future<Comment> fetchCommentDetail() async {
    final url = '${baseURL}comments/${widget.pengaduanId}';
    print('Fetching comment from: $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Comment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load comment: ${response.statusCode}');
    }
  }

  Future<List<Comment>> fetchCommentByNoPendaftaran() async {
    final noPendaftaran = widget.pengaduanData['no_pendaftaran'];

    if (noPendaftaran == null) {
      throw Exception('No pendaftaran tidak ditemukan');
    }

    final url = '${baseURL}comments/registration/$noPendaftaran';
    print('Fetching comment from: $url');
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
        print('Komentar belum ada untuk no_pendaftaran ini');
        return [];
      } else {
        throw Exception('Gagal mengambil komentar: ${response.statusCode}');
      }
    } catch (e) {
      print('Error detail: $e');
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

  Future<void> submitReply(int commentId, String replyText) async {
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
      final url = '${baseURL}comments/$commentId/reply';
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
          commentsFuture = fetchCommentByNoPendaftaran();
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

  void _refreshSession() async {
    try {
      print('Session redirect detected, refreshing session silently');
    } catch (e) {
      print('Failed to refresh session: $e');
    }
  }

  Future<void> updateStatus() async {
    if (selectedStatus == null) return;
    setState(() {
      isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
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

      final csrfToken = await getCsrfToken();
      if (csrfToken != null) {
        headers['X-CSRF-TOKEN'] = csrfToken;
      }

      String apiEndpoint;
      if (widget.pengaduanData.containsKey('source_table') &&
          widget.pengaduanData['source_table'] != null) {
        String sourceTable = widget.pengaduanData['source_table'];
        apiEndpoint = '${baseURL}${sourceTable}/${widget.pengaduanId}/status';
      } else {
        String tableNumber = '';
        if (widget.pengaduanData.containsKey('table_number') &&
            widget.pengaduanData['table_number'] != null) {
          tableNumber = widget.pengaduanData['table_number'];
        }
        apiEndpoint =
            '${baseURL}pengajuan-santunan${tableNumber}/${widget.pengaduanId}/status';
      }
      apiEndpoint = apiEndpoint.replaceAll(RegExp(r'([^:])//'), r'$1/');

      print('Making PUT request to: $apiEndpoint');
      print('Using headers: $headers');

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
        if (response.body.contains('Redirecting')) {
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
    debugPrint('source_table: $sourceTable');

    switch (sourceTable) {
      case 'pengajuan-santunan1':
        dokumen = [
          {'label': 'Surat Kematian', 'key': 'surat_kematian'},
          {'label': 'Kartu Keluarga', 'key': 'kartu_keluarga'},
          {'label': 'KTP Pensiunan dan Anak', 'key': 'ktp_pensiunan_dan_anak'},
          {'label': 'Buku Rekening Anak', 'key': 'buku_rekening_anak'},
        ];
        break;

      case 'pengajuan-santunan2':
        dokumen = [
          {'label': 'Surat Kematian', 'key': 'surat_kematian'},
          {'label': 'Kartu Keluarga', 'key': 'kartu_keluarga'},
          {'label': 'Surat Nikah', 'key': 'surat_nikah'},
          {'label': 'KTP Suami Istri', 'key': 'ktp_suami_istri'},
          {'label': 'Buku Rekening Istri', 'key': 'buku_rekening_istri'},
        ];
        break;

      case 'pengajuan-santunan3':
        dokumen = [
          {'label': 'Surat Kematian', 'key': 'surat_kematian'},
          {'label': 'Kartu Keluarga', 'key': 'kartu_keluarga'},
          {'label': 'Surat Kuasa', 'key': 'surat_kuasa'},
          {'label': 'KTP Pensiunan Anak', 'key': 'ktp_pensiunan_anak'},
          {'label': 'Buku Rekening Anak', 'key': 'buku_rekening_anak'},
        ];
        break;

      case 'pengajuan-santunan4':
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
        dokumen = [
          {'label': 'Dokumen tidak dikenali', 'key': ''},
        ];
    }

    return dokumen.map((doc) {
      final filePath = widget.pengaduanData[doc['key']] ?? '';
      final fileName = filePath.split('/').last;
      final fileUrl = '${baseURLStorage}$filePath';

      if (filePath.isEmpty) {
        return buildInfoField(doc['label']!, '-');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(doc['label']!, style: TextStyle(fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () async {
              final url = Uri.parse(fileUrl);
              try {
                bool launched = await launchUrl(
                  url,
                  mode: LaunchMode.externalNonBrowserApplication,
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
                      content: Text('Tidak dapat membuka dokumen: $fileName')),
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
          const SizedBox(height: 8),
        ],
      );
    }).toList();
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
              Navigator.pop(context, statusChanged);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 10),
              ...buildDokumenList(),
              const SizedBox(height: 10),
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
                      ? const CircularProgressIndicator(
                          color: Color(0xFF2F2F9D))
                      : const Text(
                          'Update Status',
                          style:
                              TextStyle(color: Color(0xFF2F2F9D), fontSize: 14),
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
              FutureBuilder(
                future: fetchCommentByNoPendaftaran(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Gagal memuat komentar: ${snapshot.error}');
                  } else {
                    final comments = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        // Inisialisasi controller jika belum ada
                        replyControllers.putIfAbsent(
                            comment.id, () => TextEditingController());

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment.comment),
                              const SizedBox(height: 5),
                              ...comment.replies.map((reply) => Padding(
                                    padding:
                                        const EdgeInsets.only(left: 20, top: 3),
                                    child: Text("- ${reply.comment}"),
                                  )),
                              const SizedBox(height: 10),
                              TextField(
                                controller: replyControllers[comment.id],
                                decoration: const InputDecoration(
                                  labelText: 'Balas komentar',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 5),
                              ElevatedButton(
                                onPressed: () {
                                  final replyText =
                                      replyControllers[comment.id]!.text.trim();
                                  if (replyText.isNotEmpty) {
                                    submitReply(comment.id, replyText);
                                    replyControllers[comment.id]!
                                        .clear(); // Kosongkan form
                                  }
                                },
                                child: const Text('Kirim Balasan'),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
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
