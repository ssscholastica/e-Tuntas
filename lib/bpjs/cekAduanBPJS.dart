import 'dart:convert';

import 'package:etuntas/network/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  List<Map<String, String>> trackingInfo = [];
  List<Map<String, dynamic>> comments = [];

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
    'Terkirim': 'Silakan lakukan pengecekan berkala pada aplikasi untuk memantau proses aduan BPJS Anda.',
    'Diproses': 'Silakan lakukan pengecekan berkala pada aplikasi dan menunggu informasi selanjutnya terkait aduan yang sedang diproses',
    'Ditolak': 'Catatan Kesalahan: \n- Dokumen yang anda unggah tidak dapat terbaca dengan baik',
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
      _showFailureDialog("Nomor BPJS tidak boleh kosong!");
      return;
    }

    setState(() {
      isLoading = true;
      isTrackingPressed = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${baseURL}pengaduan-bpjs/'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        
        final matchingData = jsonData.where((item) => 
          item['nomor_bpjs_nik'].toString() == nomorBPJS
        ).toList();

        setState(() {
          isLoading = false;
          
          if (matchingData.isNotEmpty) {
            isTrackingSuccess = true;
            final pengaduan = matchingData.first;
            final status = pengaduan['status'] ?? 'Terkirim';
            final tanggalAjuan = DateTime.parse(pengaduan['tanggal_ajuan']);
            final kategori = pengaduan['kategori_bpjs'];
            trackingInfo = _generateTrackingInfo(status, tanggalAjuan);
          } else {
            isTrackingSuccess = false;
            trackingInfo = [];
          }
        });
      } else {
        setState(() {
          isLoading = false;
          isTrackingSuccess = false;
          _showFailureDialog("Gagal terhubung ke server. Coba lagi nanti.");
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isTrackingSuccess = false;
        _showFailureDialog("Terjadi kesalahan: $e");
      });
    }
  }

  List<Map<String, String>> _generateTrackingInfo(String currentStatus, DateTime tanggalAjuan) {
    List<Map<String, String>> result = [];
    List<String> allStatus = ['Terkirim', 'Diproses', 'Ditolak', 'Selesai'];
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');
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
          'color': statusColors[status]!
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
  final Map<String, String> item;
  const RejectedStatusWidget({super.key, required this.item});

  @override
  _RejectedStatusWidgetState createState() => _RejectedStatusWidgetState();
}

class _RejectedStatusWidgetState extends State<RejectedStatusWidget> {
  List<Map<String, dynamic>> comments = [];
  final TextEditingController _commentController = TextEditingController();

  void _addComment(String text) {
    setState(() {
      comments.add({"author": "Anda", "text": text, "replies": []});
      _commentController.clear();
    });
  }

  void _addReply(int index, String replyText) {
    setState(() {
      comments[index]['replies'].add({"author": "Admin", "text": replyText});
    });
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

          if (comments.isNotEmpty) ...[
            const Divider(),
            const Text("Komentar:", style: TextStyle(fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(child: Text(comments[index]['author'][0])),
                      title: Text(comments[index]['author']),
                      subtitle: Text(comments[index]['text']),
                    ),
                    ...comments[index]['replies'].map<Widget>((reply) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: ListTile(
                          leading: CircleAvatar(child: Text(reply['author'][0])),
                          title: Text(reply['author']),
                          subtitle: Text(reply['text']),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],

          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: "Tambahkan komentar...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    _addComment(_commentController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F2F9D),
                ),
                child: const Icon(Icons.send, color: Colors.white,),
              ),
            ],
          ),
        ],
      ),
    );
  }
}