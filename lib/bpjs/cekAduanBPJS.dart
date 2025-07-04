import 'dart:convert';

import 'package:etuntas/models/comment_bpjs_model.dart';
import 'package:etuntas/network/comment_bpjs_service.dart';
import 'package:etuntas/network/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class CekAduanBPJS extends StatefulWidget {
  const CekAduanBPJS({super.key});

  @override
  State<CekAduanBPJS> createState() => _CekAduanBPJSState();
}

class _CekAduanBPJSState extends State<CekAduanBPJS> {
  final TextEditingController _controller = TextEditingController();
  bool isTrackingPressed = false;
  bool isTrackingSuccess = false;
  bool isLoading = false;
  List<Map<String, dynamic>> trackingInfo = [];
  List<Map<String, dynamic>> comments = [];
  Map<String, dynamic>? currentPengaduan;
  String errorMessage = "";

  final Map<String, String> statusIcons = {
    'Terkirim': 'assets/icon terkirim.png',
    'Diproses': 'assets/icon diproses.png',
    'Ditolak': 'assets/icon ditolak.png',
    'Selesai': 'assets/icon selesai.png',
  };

  final Map<String, String> statusColors = {
    'Terkirim': '#007bff',
    'Diproses': '#FFA500',
    'Ditolak': '#DC3545',
    'Selesai': '#198754',
  };

  final Map<String, String> statusDescriptions = {
    'Terkirim':
        'Silakan lakukan pengecekan berkala pada aplikasi untuk memantau proses aduan BPJS Anda.',
    'Diproses':
        'Silakan lakukan pengecekan berkala pada aplikasi dan menunggu informasi selanjutnya terkait aduan yang sedang diproses',
    'Ditolak':
        'Catatan Kesalahan: \n- Dokumen yang anda unggah tidak dapat terbaca dengan baik',
    'Selesai': '',
  };

  final Map<String, String> statusTitles = {
    'Terkirim': 'Aduan BPJS berhasil terkirim',
    'Diproses': 'Aduan BPJS sedang diproses',
    'Ditolak': 'Pengajuan Santunan gagal',
    'Selesai': 'Aduan BPJS Berhasil Terselesaikan',
  };

  Future<void> _cekTrackingData() async {
    String nomorBPJS = _controller.text.trim();
    if (nomorBPJS.isEmpty) {
      _showFailureDialog("Nomor BPJS/NIK tidak boleh kosong!");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = "";
      isTrackingPressed = true;
      isTrackingSuccess = false;
      trackingInfo = [];
    });

    try {
      print("Searching for nomor BPJS: $nomorBPJS");

      final headers = await getHeaders();
      print("Using token: ${headers['Authorization']}");

      print("URL: ${baseURL}pengaduan-bpjs/by-nomor/$nomorBPJS");

      final response = await http.get(
        Uri.parse('${baseURL}pengaduan-bpjs/by-nomor/$nomorBPJS'),
        headers: headers,
      );

      print("Response status: ${response.statusCode}");
      if (response.statusCode >= 400) {
        print("Response body: ${response.body}");
      }

      if (response.statusCode == 200) {
        try {
          final dynamic decodedResponse = json.decode(response.body);

          if (decodedResponse is List) {
            if (decodedResponse.isNotEmpty) {
              _processTrackingResults(decodedResponse);
            } else {
              _handleNoData();
            }
          } else if (decodedResponse is Map<String, dynamic>) {
            if (decodedResponse.containsKey('data') &&
                decodedResponse['data'] is List &&
                decodedResponse['data'].isNotEmpty) {
              _processTrackingResults(decodedResponse['data']);
            } else {
              if (decodedResponse.containsKey('id') ||
                  decodedResponse.containsKey('nomor_bpjs_nik') ||
                  decodedResponse.containsKey('status')) {
                _processTrackingSingleResult(decodedResponse);
              } else {
                _handleNoData();
              }
            }
          } else {
            _handleNoData();
          }
        } catch (e) {
          print("Error parsing response data: $e");
          _showFailureDialog("Format data tidak valid: ${e.toString()}");
          setState(() {
            isLoading = false;
            errorMessage = "Format data tidak valid: ${e.toString()}";
          });
        }
      }
      else if (response.statusCode == 500) {
        String errorMsg =
            "Terjadi kesalahan pada server. Silakan coba lagi nanti.";
        try {
          final errorData = json.decode(response.body);
          if (errorData.containsKey('message')) {
            errorMsg = errorData['message'];
          }
          if (errorData.containsKey('error')) {
            print("Server error: ${errorData['error']}");
          }
        } catch (_) {}

        setState(() {
          isLoading = false;
          errorMessage = errorMsg;
        });
        _showFailureDialog(errorMsg);

        _tryAlternativeSearch(nomorBPJS, headers);
      }
      else if (response.statusCode == 403 || response.statusCode == 404) {
        _tryAlternativeSearch(nomorBPJS, headers);
      } else {
        _handleErrorResponse(response.statusCode);
      }
    } catch (e) {
      print("Error fetching tracking data: $e");
      setState(() {
        isLoading = false;
        isTrackingSuccess = false;
        errorMessage = e.toString();
      });
      _showFailureDialog("Terjadi kesalahan: ${e.toString()}");
    }
  }

  Future<void> _tryAlternativeSearch(
      String query, Map<String, String> headers) async {
    try {
      print("Trying alternative search with query: $query");
      final searchResponse = await http.get(
        Uri.parse('${baseURL}pengaduan-bpjs/search?query=$query'),
        headers: headers,
      );
      print("Alternative search response status: ${searchResponse.statusCode}");
      if (searchResponse.statusCode == 200) {
        try {
          final dynamic searchData = json.decode(searchResponse.body);
          if (searchData is List && searchData.isNotEmpty) {
            _processTrackingResults(searchData);
          } else if (searchData is Map<String, dynamic>) {
            if (searchData.containsKey('data') &&
                searchData['data'] is List &&
                searchData['data'].isNotEmpty) {
              _processTrackingResults(searchData['data']);
            }
            else if (searchData.containsKey('id') ||
                searchData.containsKey('nomor_bpjs_nik') ||
                searchData.containsKey('status')) {
              _processTrackingSingleResult(searchData);
            } else {
              _handleNoData();
            }
          } else {
            _handleNoData();
          }
        } catch (e) {
          print("Error parsing alternative search data: $e");
          _handleNoData();
        }
      } else {
        _handleErrorResponse(searchResponse.statusCode);
      }
    } catch (e) {
      print("Error in alternative search: $e");
    }
  }

  void _processTrackingResults(List<dynamic> jsonData) {
    setState(() {
      isLoading = false;
      if (jsonData.isNotEmpty) {
        isTrackingSuccess = true;
        currentPengaduan = jsonData.first;
        if (currentPengaduan!.containsKey('status') &&
            currentPengaduan!.containsKey('tanggal_ajuan')) {
          final status = currentPengaduan!['status'] ?? 'Terkirim';
          DateTime tanggalAjuan;
          try {
            tanggalAjuan = DateTime.parse(currentPengaduan!['tanggal_ajuan']);
          } catch (e) {
            print("Error parsing date: $e");
            tanggalAjuan = DateTime.now();
          }
          trackingInfo = _generateTrackingInfo(status, tanggalAjuan);
        } else {
          trackingInfo = _generateTrackingInfo('Terkirim', DateTime.now());
        }
      } else {
        _handleNoData();
      }
    });
  }

  void _processTrackingSingleResult(Map<String, dynamic> data) {
    setState(() {
      isLoading = false;
      isTrackingSuccess = true;
      currentPengaduan = data;
      String status = data['status'] ?? 'Terkirim';
      DateTime tanggalAjuan;
      if (data.containsKey('tanggal_ajuan')) {
        try {
          tanggalAjuan = DateTime.parse(data['tanggal_ajuan']);
        } catch (e) {
          print("Error parsing date: $e");
          tanggalAjuan = DateTime.now();
        }
      } else {
        tanggalAjuan = DateTime.now();
      }
      trackingInfo = _generateTrackingInfo(status, tanggalAjuan);
    });
  }

  void _handleNoData() {
    setState(() {
      isLoading = false;
      isTrackingSuccess = false;
      trackingInfo = [];
      currentPengaduan = null;
      errorMessage = "Data tidak ditemukan.";
    });
    _showFailureDialog("Data tidak ditemukan.");
  }

  void _handleErrorResponse(int statusCode) {
    String errorMsg;
    if (statusCode == 403) {
      errorMsg = "Anda tidak berhak mengakses data ini.";
    } else if (statusCode == 401) {
      errorMsg = "Anda belum login. Silakan login terlebih dahulu.";
    } else if (statusCode == 500) {
      errorMsg = "Terjadi kesalahan pada server. Silakan coba lagi nanti.";
    } else {
      errorMsg = "Gagal mengambil data dari server.";
    }

    setState(() {
      isLoading = false;
      errorMessage = errorMsg;
    });
    _showFailureDialog(errorMsg);
  }

  Future<Map<String, dynamic>?> _getCurrentUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print("Available SharedPreferences keys: ${prefs.getKeys()}");

      final String? userEmail = prefs.getString('user_email') ??
          prefs.getString('email') ??
          prefs.getString('userEmail');

      final String? userData = prefs.getString('user_data') ??
          prefs.getString('userData') ??
          prefs.getString('user');

      print(
          "Retrieved from SharedPreferences - userEmail: $userEmail, userData: $userData");

      if (userData != null && userData.isNotEmpty) {
        try {
          final Map<String, dynamic> parsedUserData = json.decode(userData);
          print("Parsed user data from SharedPreferences: $parsedUserData");
          return parsedUserData;
        } catch (e) {
          print("Error parsing user data from SharedPreferences: $e");
        }
      }

      if (userEmail == null || userEmail.isEmpty) {
        print("No user email found in SharedPreferences");
        return null;
      }

      return {'email': userEmail, 'is_admin': false, 'name': 'User'};
    } catch (e) {
      print("Error in _getCurrentUserData: $e");
      return null;
    }
  }

  List<Map<String, dynamic>> _generateTrackingInfo(
      String currentStatus, DateTime tanggalAjuan) {
    List<Map<String, dynamic>> result = [];
    List<String> allStatus = ['Terkirim', 'Diproses', 'Ditolak', 'Selesai'];
    final dateFormatter = DateFormat('d MMM yyyy');
    final currentStatusIndex = allStatus.indexOf(currentStatus);
    if (currentStatusIndex == -1) return result;

    if (currentStatus == 'Ditolak') {
      allStatus = ['Terkirim', 'Diproses', 'Ditolak'];
    }

    if (currentStatus == 'Selesai') {
      allStatus = ['Terkirim', 'Diproses', 'Selesai'];
    }

    for (int i = 0; i < allStatus.length; i++) {
      final status = allStatus[i];

      if (i <= currentStatusIndex ||
          (currentStatus == 'Selesai' && status != 'Ditolak')) {
        DateTime statusDate = tanggalAjuan.add(Duration(days: i));

        final now = DateTime.now();
        if (statusDate.isAfter(now)) {
          statusDate = now;
        }

        result.add({
          'icon': statusIcons[status]!,
          'status': status,
          'date': dateFormatter.format(statusDate),
          'title': statusTitles[status]!,
          'description': statusDescriptions[status]!,
          'color': statusColors[status]!,
          'pengaduan': currentPengaduan,
        });
      }
    }

    return result;
  }

  void _showFailureDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Gagal"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _addComment(String text) {
    setState(() {
      comments.add({"author": "Anda", "text": text, "replies": []});
    });
  }

  void _addReply(int index, String replyText) {
    setState(() {
      comments[index]['replies'].add({"author": "Admin", "text": replyText});
    });
  }

  void _showReplyDialog(int index) {
    TextEditingController replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Reply"),
          content: TextField(
            controller: replyController,
            decoration: const InputDecoration(hintText: "Masukkan reply"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                if (replyController.text.isNotEmpty) {
                  _addReply(index, replyController.text);
                }
                Navigator.pop(context);
              },
              child: const Text("Kirim"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 20),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Silahkan masukkan nomor BPJS',
                    style: TextStyle(fontSize: 16),
                  )),
            ),
            _buildInputField(),
            _buildCheckButton(),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _buildTrackingResult(),
            const SizedBox(height: 80)
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Nomor BPJS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Nomor BPJS',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: isLoading ? null : _cekTrackingData,
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: const Color(0xFF2F2F9D),
          ),
          child: const Text("Cek/Tracking Data",
              style: TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildTrackingResult() {
    if (!isTrackingPressed) {
      return Container(
        padding: const EdgeInsets.only(left: 5, right: 25, top: 10),
        child: const Row(),
      );
    }
    if (!isTrackingSuccess) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red),
        ),
        child: const Text(
          "Nomor BPJS tidak ditemukan, Coba Isi Kembali!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trackingInfo.length,
      itemBuilder: (context, index) {
        var item = trackingInfo[index];
        if (item["status"] == "Ditolak") {
          return RejectedStatusWidget(item: item);
        }
        return Container(
          margin: const EdgeInsets.only(right: 20, left: 20, bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border(
                left: BorderSide(
                    color: Color(
                        int.parse(item["color"]!.replaceAll("#", "0xff"))),
                    width: 4)),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    item['icon']!,
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(item["status"]!,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text(item["date"]!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0XFF474747))),
                ],
              ),
              const SizedBox(height: 8),
              Text(item["title"]!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(item["description"]!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        );
      },
    );
  }
}

class RejectedStatusWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  const RejectedStatusWidget({super.key, required this.item});

  @override
  _RejectedStatusWidgetState createState() => _RejectedStatusWidgetState();
}

class _RejectedStatusWidgetState extends State<RejectedStatusWidget> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  bool isLoading = false;
  List<Comment> comments = [];
  bool hasNewComment = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _setupNotificationListener();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _setupNotificationListener() {
    // Listener untuk notifikasi saat app aktif
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;

      // Cek apakah notifikasi adalah komentar untuk item ini
      if ((data['type'] == 'admin_comment_bpjs') &&
          (data['nomor_bpjs_nik'] == widget.item['nomor_bpjs_nik'])) {
        // Refresh comments otomatis
        _loadComments();

        // Show snackbar untuk memberi tahu user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ada komentar baru dari admin'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Lihat',
                textColor: Colors.white,
                onPressed: () {
                  // Scroll ke bagian komentar atau lakukan aksi lain
                },
              ),
            ),
          );
        }
      }
    });

    // Listener untuk notifikasi saat app dibuka dari background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data;

      if ((data['type'] == 'admin_comment' ||
              data['type'] == 'admin_comment_bpjs') &&
          (data['no_pendaftaran'] == widget.item['no_pendaftaran'] ||
              data['nomor_bpjs_nik'] == widget.item['nomor_bpjs_nik'])) {
        // Refresh comments
        _loadComments();
      }
    });
  }

  Future<void> _loadComments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final pengaduan = widget.item['pengaduan'];
      if (pengaduan == null) {
        print('Error: pengaduan data is null');
        setState(() {
          isLoading = false;
        });
        return;
      }

      final nomorBPJS = pengaduan['nomor_bpjs_nik'];
      if (nomorBPJS == null || nomorBPJS.toString().isEmpty) {
        print('Error: nomor_bpjs_nik is null or empty');
        setState(() {
          isLoading = false;
        });
        return;
      }

      final commentsData =
          await _commentService.getCommentsByNomorBPJS(nomorBPJS);

      setState(() {
        comments = commentsData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading comments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final pengaduan = widget.item['pengaduan'];
      if (pengaduan == null) {
        throw Exception('Pengaduan data is null');
      }

      final pengajuanBPJSId = pengaduan['id'];
      final nomorBPJS = pengaduan['nomor_bpjs_nik'];

      if (pengajuanBPJSId == null) {
        throw Exception('Pengajuan ID is null');
      }

      if (nomorBPJS == null) {
        throw Exception('Nomor BPJS is null');
      }

      final comment = await _commentService.submitComment(
        pengajuanBPJSId: pengajuanBPJSId is int
            ? pengajuanBPJSId
            : int.parse(pengajuanBPJSId.toString()),
        nomorBPJS: nomorBPJS.toString(),
        commentText: _commentController.text,
      );

      if (comment != null) {
        setState(() {
          comments.insert(0, comment);
          _commentController.clear();
        });
      }
    } catch (e) {
      print('Error submitting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim komentar: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color:
                Color(int.parse(widget.item["color"]!.replaceAll("#", "0xff"))),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                widget.item['icon']!,
                width: 16,
                height: 16,
              ),
              const SizedBox(width: 5),
              Text(
                widget.item['status']!,
                style: const TextStyle(color: Colors.red),
              ),
              const Spacer(),
              Text(
                widget.item["date"]!,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.item["title"]!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            widget.item["description"]!,
            style: const TextStyle(fontSize: 14, color: Colors.red),
          ),
          const SizedBox(height: 10),
          const Divider(),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (comments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    "Belum ada komentar. Tambahkan komentar untuk klarifikasi."),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    "Komentar:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final Comment comment = comments[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: comment.authorType == 'user'
                                  ? Colors.blue
                                  : Colors.green,
                              child: Text(
                                comment.authorType == 'user' ? 'U' : 'A',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  comment.authorType == 'user'
                                      ? 'Anda'
                                      : 'Admin',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Text(
                                  _formatDate(comment.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(comment.comment),
                            ),
                          ),
                        ),
                        if (comment.replies.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comment.replies.length,
                              itemBuilder: (context, replyIndex) {
                                final reply = comment.replies[replyIndex];
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          reply.authorType == 'user'
                                              ? Colors.blue
                                              : Colors.green,
                                      child: Text(
                                        reply.authorType == 'user' ? 'U' : 'A',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(
                                          reply.authorType == 'user'
                                              ? 'Anda'
                                              : 'Admin',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _formatDate(reply.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(reply.comment),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "Tambahkan komentar...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: isLoading ? null : _submitComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F2F9D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
