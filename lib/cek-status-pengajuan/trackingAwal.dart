import 'dart:convert';
import 'dart:io';

import 'package:etuntas/home.dart';
import 'package:etuntas/network/globals.dart';
import 'package:etuntas/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:etuntas/models/comment_model.dart';
import 'package:etuntas/network/comment_service.dart';

class TrackingAwal extends StatefulWidget {
  const TrackingAwal({super.key});

  @override
  State<TrackingAwal> createState() => _TrackingAwalState();
}

class _TrackingAwalState extends State<TrackingAwal> {
  final TextEditingController _controller = TextEditingController();
  bool isTrackingPressed = false;
  bool isTrackingSuccess = false;
  List<Map<String, dynamic>> trackingInfo = [];
  List<Map<String, dynamic>> comments = [];
  bool isLoading = false;
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
        'Silakan lakukan pengecekan berkala pada aplikasi untuk memantau proses pengajuan santunan Anda.',
    'Diproses':
        'Silakan lakukan pengecekan berkala pada aplikasi dan menunggu informasi selanjutnya terkait pengajuan yang sedang diproses',
    'Ditolak':
        'Catatan Kesalahan: \n- Dokumen yang anda unggah tidak dapat terbaca dengan baik',
    'Selesai': 'Pengajuan Santunan Anda telah selesai diproses.',
  };

  final Map<String, String> statusTitles = {
    'Terkirim': 'Pengajuan Santunan berhasil terkirim',
    'Diproses': 'Pengajuan Santunan sedang diproses',
    'Ditolak': 'Pengajuan Santunan gagal',
    'Selesai': 'Pengajuan Santunan berhasil terselesaikan',
  };

  Future<void> _fetchTrackingData() async {
    String nomorPendaftaran = _controller.text.trim();

    if (nomorPendaftaran.isEmpty) {
      _showFailureDialog("Nomor Pendaftaran/NIK tidak boleh kosong!");
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
      print("Searching for nomor pendaftaran: $nomorPendaftaran");

      final bool isAuthorized = await _isUserAuthorized(nomorPendaftaran);
      print("User authorization result: $isAuthorized");

      if (!isAuthorized) {
        setState(() {
          isLoading = false;
          errorMessage =
              "Anda hanya dapat melacak pengajuan dengan nomor pendaftaran Anda sendiri!";
        });
        _showFailureDialog(
            "Anda hanya dapat melacak pengajuan dengan nomor pendaftaran Anda sendiri!");
        return;
      }

      List<String> tableOptions = ["1", "2", "3", "4", "5"];
      bool found = false;
      Map<String, dynamic>? foundData;

      for (String tableNumber in tableOptions) {
        if (found) break;

        final exactMatchResponse =
            await _searchData(nomorPendaftaran, tableNumber, false);
        if (exactMatchResponse != null) {
          foundData = exactMatchResponse;
          found = true;
          break;
        }
        final likeMatchResponse =
            await _searchData(nomorPendaftaran, tableNumber, true);
        if (likeMatchResponse != null) {
          foundData = likeMatchResponse;
          found = true;
          break;
        }
      }

      if (found && foundData != null) {
        _processSearchResults(foundData);
      } else {
        setState(() {
          isTrackingSuccess = false;
          errorMessage = "Data tidak ditemukan";
        });
        _showFailureDialog(
            "Data dengan nomor pendaftaran tersebut tidak ditemukan.");
      }
    } catch (e) {
      print("Error fetching tracking data: $e");
      setState(() {
        errorMessage = e.toString();
        isTrackingSuccess = false;
      });
      _showFailureDialog("Terjadi kesalahan: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _isUserAuthorized(String nomorPendaftaran) async {
    try {
      final currentUser = await _getCurrentUserData();
      print("Current user data: $currentUser");

      if (currentUser == null) {
        print("No user logged in");
        return false;
      }

      if (currentUser['is_admin'] == 1 || currentUser['is_admin'] == true) {
        print("User is admin, authorization granted");
        return true;
      }

      final String userEmail = currentUser['email'] ?? '';
      print(
          "User email: $userEmail, checking ownership for nomor pendaftaran: $nomorPendaftaran");

      final bool isUserOwnApplication =
          await _checkPendaftaranOwnership(nomorPendaftaran, userEmail);
      print("Ownership check result: $isUserOwnApplication");
      return isUserOwnApplication;
    } catch (e) {
      print("Error checking user authorization: $e");
      return false;
    }
  }

  Future<bool> _checkPendaftaranOwnership(
      String nomorPendaftaran, String userEmail) async {
    try {
      if (nomorPendaftaran.isEmpty || userEmail.isEmpty) {
        print("Empty nomor pendaftaran or email");
        return false;
      }

      print(
          "Checking pendaftaran ownership for: $nomorPendaftaran and email: $userEmail");

      List<String> tableOptions = ["1", "2", "3", "4", "5"];

      for (String tableNumber in tableOptions) {
        final exactMatchResponse =
            await _searchData(nomorPendaftaran, tableNumber, false);
        print(
            "Search result for table $tableNumber (exact): $exactMatchResponse");

        if (exactMatchResponse != null) {
          String dataEmail = exactMatchResponse['email'] ?? '';
          print("Comparing emails - Data: $dataEmail vs User: $userEmail");

          if (dataEmail.isNotEmpty &&
              dataEmail.toLowerCase() == userEmail.toLowerCase()) {
            print("Email match found, authorization granted");
            return true;
          }
        }

        final likeMatchResponse =
            await _searchData(nomorPendaftaran, tableNumber, true);
        print(
            "Search result for table $tableNumber (like): $likeMatchResponse");

        if (likeMatchResponse != null) {
          String dataEmail = likeMatchResponse['email'] ?? '';
          print("Comparing emails - Data: $dataEmail vs User: $userEmail");

          if (dataEmail.isNotEmpty &&
              dataEmail.toLowerCase() == userEmail.toLowerCase()) {
            print("Email match found, authorization granted");
            return true;
          }
        }
      }

      print("No ownership match found, authorization denied");
      return false;
    } catch (e) {
      print("Error checking pendaftaran ownership: $e");
      return false;
    }
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

      return {
        'email': userEmail,
        'is_admin': false, 
        'name': 'User'
      };
    } catch (e) {
      print("Error in _getCurrentUserData: $e");
      return null; 
    }
  }

  Future<Map<String, dynamic>?> _searchData(
      String nomorPendaftaran, String tableNumber, bool useLikeSearch) async {
    try {
      final String endpoint = useLikeSearch
          ? '${baseURL}pengajuan-santunan_$tableNumber/search-like?no_pendaftaran=$nomorPendaftaran'
          : '${baseURL}pengajuan-santunan_$tableNumber/search?no_pendaftaran=$nomorPendaftaran';

      final Uri uri = Uri.parse(endpoint);

      print('Making request to: ${uri.toString()}');

      final headers = await getHeaders();
      final response = await http.get(
        uri,
        headers: headers,
      );

      print('Response status: ${response.statusCode} for ${uri.toString()}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Decoded response data: $responseData');

        if (responseData is Map<String, dynamic> &&
            (responseData.containsKey('id') ||
                responseData.containsKey('no_pendaftaran'))) {
          return responseData;
        }

        if (responseData is List && responseData.isNotEmpty) {
          return responseData[0];
        }

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('status') &&
            responseData.containsKey('data')) {
          if (responseData['status'] == 'success' &&
              responseData['data'] != null) {
            if (responseData['data'] is List &&
                responseData['data'].isNotEmpty) {
              return responseData['data'][0];
            }
            return responseData['data'];
          }
        }
      } else if (response.statusCode == 404) {
        print("Data not found: ${response.body}");
      } else {
        print("Error response: ${response.statusCode} - ${response.body}");
      }

      return null;
    } catch (e) {
      print("Error in _searchData: $e");
      return null;
    }
  }

  void _processSearchResults(Map<String, dynamic> data) {
    setState(() {
      isTrackingSuccess = true;
      String status = data['status'] ?? 'Terkirim';

      DateTime? updatedAt;
      if (data['updated_at'] != null &&
          data['updated_at'].toString().isNotEmpty) {
        try {
          updatedAt = DateTime.parse(data['updated_at']);
        } catch (e) {
          print('Error parsing date: ${e.toString()}');
          updatedAt = DateTime.now();
        }
      } else {
        updatedAt = DateTime.now();
      }

      final dateFormatter = DateFormat('d MMM yyyy');
      String formattedDate =
          updatedAt != null ? dateFormatter.format(updatedAt) : "-";

      List<String> orderedStatuses = [
        'Terkirim',
        'Diproses',
        'Ditolak',
        'Selesai'
      ];
      int currentIndex = orderedStatuses.indexOf(status);
      trackingInfo = [];

      for (int i = 0; i <= currentIndex; i++) {
        String currentStatus = orderedStatuses[i];
        trackingInfo.add({
          'icon': statusIcons[currentStatus]!,
          'status': currentStatus,
          'date': formattedDate,
          'title': statusTitles[currentStatus]!,
          'description': statusDescriptions[currentStatus]!,
          'color': statusColors[currentStatus]!,
          'id': data['id']?.toString() ?? '',
          'no_pendaftaran': data['no_pendaftaran']?.toString() ?? '',
        });
      }
    });
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

  void openWhatsApp() async {
    String contact = "6282141788021";
    String text = Uri.encodeComponent(
        "Halo, saya ingin bertanya tentang status pengajuan santunan saya...");

    String androidUrl = "whatsapp://send?phone=$contact&text=$text";
    String iosUrl = "https://wa.me/$contact?text=$text";
    String webUrl = "https://web.whatsapp.com/send?phone=$contact&text=$text";

    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(Uri.parse(iosUrl))) {
          await launchUrl(Uri.parse(iosUrl));
        } else {
          throw "Tidak bisa membuka WhatsApp di iOS";
        }
      } else {
        if (await canLaunchUrl(Uri.parse(androidUrl))) {
          await launchUrl(Uri.parse(androidUrl));
        } else {
          throw "Tidak bisa membuka WhatsApp di Android";
        }
      }
    } catch (e) {
      print("WhatsApp tidak terinstal, membuka Web WhatsApp...");
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _onCheckPressed() {
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _fetchTrackingData();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                _buildInputField(),
                _buildCheckButton(),
                _buildTrackingResult(),
                const SizedBox(height: 80)
              ],
            ),
          ),
          LoadingWidget(isLoading: isLoading),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openWhatsApp,
        backgroundColor: Colors.green,
        icon: Image.asset('assets/logo wa.png', width: 24, height: 24),
        label: const Text(
          "Chat Bantuan",
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(top: 60, left: 20, right: 20),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => const Home())),
            child: Image.asset('assets/simbol back.png', width: 28, height: 28),
          ),
          const Spacer(),
          const Text(
            "Cek Status Pengajuan Santunan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
        ],
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
            'Nomor Pendaftaran/NIK',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Nomor Pendaftaran/NIK',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            keyboardType: TextInputType.text,
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
          onPressed: isLoading ? null : _onCheckPressed,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/simbol trackimg awal.png',
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tentang Nomor Pendaftaran",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Nomor Pendaftaran didapatkan setelah berhasil melakukan upload data pengajuan santunan. Silakan cek email untuk melihat nomor pendaftaran Anda.",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.justify,
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red),
        ),
        child: Text(
          "Error: $errorMessage",
          textAlign: TextAlign.center,
          style:
              const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (!isTrackingSuccess && !isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red),
        ),
        child: const Text(
          "Nomor Pendaftaran/NIK tidak ditemukan! Coba Isi Kembali!",
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
                  Image.asset(item['icon']!, width: 16, height: 16),
                  const SizedBox(width: 5),
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

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final nomorPendaftaran = widget.item['no_pendaftaran'];
      if (nomorPendaftaran == null || nomorPendaftaran.toString().isEmpty) {
        print('Error: no_pendaftaran is null or empty');
        setState(() {
          isLoading = false;
        });
        return;
      }
      final commentsData =
          await _commentService.getCommentsByNomorPendaftaran(nomorPendaftaran);

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
      final pengajuanId = int.parse(widget.item['id']);
      final noPendaftaran = widget.item['no_pendaftaran'];

      final comment = await _commentService.submitComment(
        pengajuanId: pengajuanId,
        noPendaftaran: noPendaftaran,
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
        const SnackBar(
            content: Text('Gagal mengirim komentar. Silakan coba lagi.')),
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

          // Comments section
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
                        // Main comment
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

                        // Replies
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

          // Add comment section
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
