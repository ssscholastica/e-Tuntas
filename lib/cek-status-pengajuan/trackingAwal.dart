import 'dart:convert';
import 'dart:io';

import 'package:etuntas/home.dart';
import 'package:etuntas/network/globals.dart';
import 'package:etuntas/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  bool isLoading = false;
  String errorMessage = "";
  
  // Grouped status mappings
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
    'Terkirim': 'Silakan lakukan pengecekan berkala pada aplikasi untuk memantau proses pengajuan santunan Anda.',
    'Diproses': 'Silakan lakukan pengecekan berkala pada aplikasi dan menunggu informasi selanjutnya terkait pengajuan yang sedang diproses',
    'Ditolak': 'Catatan Kesalahan: \n- Dokumen yang anda unggah tidak dapat terbaca dengan baik',
    'Selesai': '',
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
    });

    try {
      print("Searching for nomor pendaftaran: $nomorPendaftaran");
      
      // Try main table first
      bool found = await _tryFetchFromTable(nomorPendaftaran, "");
      
      // If not found, try numbered tables
      if (!found) {
        for (int i = 1; i <= 5; i++) {
          print("Trying table $i...");
          found = await _tryFetchFromTable(nomorPendaftaran, "$i");
          if (found) {
            print("Found in table $i!");
            break;
          }
        }
      }
      
      // If still not found, show not found message
      if (!found) {
        print("No data found in any table for: $nomorPendaftaran");
        setState(() {
          isTrackingPressed = true;
          isTrackingSuccess = false;
          trackingInfo = [];
        });
      }
    } catch (e) {
      print("Error fetching tracking data: $e");
      setState(() {
        errorMessage = e.toString();
        isTrackingPressed = true;
        isTrackingSuccess = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _tryFetchFromTable(String nomorPendaftaran, String tableNumber) async {
  try {
    // Try both exact match and a more flexible search
    final String endpoint = '${baseURL}pengajuan-santunan$tableNumber/search?no_pendaftaran=$nomorPendaftaran';
    final Uri uri = Uri.parse(endpoint);
    
    print('Making request to: ${uri.toString()}');
    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    // If exact match fails, try a LIKE search (this requires backend support)
    if (response.statusCode == 404 || (response.statusCode == 200 && json.decode(response.body).isEmpty)) {
      final String likeEndpoint = '${baseURL}pengajuan-santunan$tableNumber/search-like?no_pendaftaran=$nomorPendaftaran';
      final Uri likeUri = Uri.parse(likeEndpoint);
      
      print('Trying LIKE search: ${likeUri.toString()}');
      final likeResponse = await http.get(
        likeUri,
        headers: {'Accept': 'application/json'},
      );
      
      if (likeResponse.statusCode == 200) {
        final data = json.decode(likeResponse.body);
        if (data != null && data.isNotEmpty) {
          _processSearchResults(data);
          return true;
        }
      }
      return false;
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data.isNotEmpty) {
        _processSearchResults(data);
        return true;
      }
    }
    
    return false;
  } catch (e) {
    print("Error in _tryFetchFromTable: $e");
    return false;
  }
}

// Helper method to process the search results
void _processSearchResults(dynamic data) {
  setState(() {
    isTrackingPressed = true;
    isTrackingSuccess = true;
    // Make sure we get the status properly, default to 'Terkirim' if missing
    String status = data[0]['status'] ?? 'Terkirim';
    
    DateTime? updatedAt;
    if (data[0]['updated_at'] != null && data[0]['updated_at'].toString().isNotEmpty) {
      try {
        updatedAt = DateTime.parse(data[0]['updated_at']);
      } catch (e) {
        print('Error parsing date: ${e.toString()}');
      }
    }
    
    // Get individual status properties from the maps
    trackingInfo = [{
      'icon': statusIcons[status] ?? statusIcons['Terkirim']!,
      'status': status,
      'date': updatedAt != null 
          ? "${updatedAt.day} ${_getMonthName(updatedAt.month)} ${updatedAt.year}, ${updatedAt.hour}:${updatedAt.minute.toString().padLeft(2, '0')}" 
          : "-",
      'title': statusTitles[status] ?? statusTitles['Terkirim']!,
      'description': statusDescriptions[status] ?? statusDescriptions['Terkirim']!,
      'color': statusColors[status] ?? statusColors['Terkirim']!,
    }];
  });
}

  String _getMonthName(int month) {
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return monthNames[month - 1];
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
    String text = Uri.encodeComponent("Halo, saya ingin bertanya...");

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
    Future.delayed(const Duration(milliseconds: 300), () {
      _fetchTrackingData();
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
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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
          onPressed: _onCheckPressed,
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
            const SizedBox(width: 0),
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
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
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
          "Nomor Pendaftaran/NIK tidak ditemukan!",
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
                      style: const TextStyle(fontSize: 12, color: Color(0XFF474747))),
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