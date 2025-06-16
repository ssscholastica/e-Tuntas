import 'dart:convert';
import 'package:etuntas/admin/admin-santunanForm.dart';
import 'package:etuntas/admin/admin-bpjsForm.dart'; // Pastikan ada form untuk BPJS
import 'package:etuntas/network/globals.dart';
import 'package:etuntas/profile/user-BPJSForm.dart';
import 'package:etuntas/profile/user-SantunanForm.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoriPengajuan extends StatefulWidget {
  const HistoriPengajuan({Key? key}) : super(key: key);
  @override
  State<HistoriPengajuan> createState() => _HistoriPengajuanState();
}

class _HistoriPengajuanState extends State<HistoriPengajuan> {
  bool isLoading = true;
  String errorMessage = "";
  String? currentUserEmail;
  List<Map<String, dynamic>> historiList = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currentUserEmail = prefs.getString('user_email');
      if (currentUserEmail != null) {
        fetchHistoriData();
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "User tidak ditemukan. Silakan login kembali.";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error getting user data: $e";
      });
    }
  }

  void _navigateToDetailForm(
      BuildContext context, Map<String, dynamic> itemData) async {
    bool? statusUpdated;

    if (itemData['type'] == 'santunan') {
      // Navigate to Santunan form
      statusUpdated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => formSantunanUser(
            pengaduanId: itemData['id'],
            pengaduanData: itemData['full_data'],
            onStatusUpdated: () {
              print("Santunan status updated callback triggered");
            },
          ),
        ),
      );
    } else if (itemData['type'] == 'bpjs') {
      // Navigate to BPJS form (pastikan form ini ada)
      statusUpdated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => formBPJSUser(
            // Sesuaikan dengan nama form BPJS Anda
            pengaduanId: itemData['id'],
            pengaduanData: itemData['full_data'],
            onStatusUpdated: () {
              print("BPJS status updated callback triggered");
            },
          ),
        ),
      );
    }

    if (statusUpdated == true) {
      print("Status was updated, refreshing data...");
      fetchHistoriData();
    }
  }

  Future<void> fetchHistoriData() async {
    if (currentUserEmail == null) return;

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      List<Map<String, dynamic>> allHistoriData = [];
      final headers = await getHeaders();

      // Fetch semua jenis pengajuan santunan (1 sampai 5)
      await _fetchSantunanData(allHistoriData, headers);

      // Fetch pengaduan BPJS
      await _fetchBPJSData(allHistoriData, headers);

      // Urutkan berdasarkan tanggal terbaru
      allHistoriData.sort((a, b) {
        final DateTime? dateA = a["date"] as DateTime?;
        final DateTime? dateB = b["date"] as DateTime?;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });

      setState(() {
        historiList = allHistoriData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error: $e";
      });
    }
  }

  Future<void> _fetchSantunanData(
    List<Map<String, dynamic>> allHistoriData,
    Map<String, String> headers,
  ) async {
    for (int i = 1; i <= 5; i++) {
      final suffix = (i == 1) ? '' : '$i';
      final endpoint = 'histori-pengajuan-santunan$suffix/$currentUserEmail';

      try {
        final response = await http.get(
          Uri.parse('$baseURL$endpoint'),
          headers: headers,
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              allHistoriData.add(_formatSantunanItem(
                  item, 'pengajuan-santunan$suffix', suffix));
            }
          }
        } else {
          print('Failed to fetch santunan$suffix: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching santunan$suffix: $e');
      }
    }
  }


  Future<void> _fetchBPJSData(
    List<Map<String, dynamic>> allHistoriData,
    Map<String, String> headers,
  ) async {
    final endpoint = 'histori-pengaduan-bpjs/$currentUserEmail';

    try {
      final response = await http.get(
        Uri.parse('$baseURL$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            allHistoriData.add(_formatBPJSItem(item));
          }
        }
      } else {
        print('Failed to fetch BPJS data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching BPJS data: $e');
    }
  }


  Map<String, dynamic> _formatSantunanItem(
      Map<String, dynamic> item, String sourceTable, String tableNumber) {
    DateTime? tanggalMeninggal;
    if (item['tanggal_meninggal'] != null &&
        item['tanggal_meninggal'].toString().isNotEmpty) {
      try {
        tanggalMeninggal = DateTime.parse(item['tanggal_meninggal']);
      } catch (e) {
        print('Error parsing tanggal_meninggal: ${e.toString()}');
      }
    }

    DateTime? updatedAt;
    if (item['updated_at'] != null &&
        item['updated_at'].toString().isNotEmpty) {
      try {
        updatedAt = DateTime.parse(item['updated_at']);
      } catch (e) {
        print('Error parsing updated_at: ${e.toString()}');
      }
    }

    // Add source info to full_data
    item['source_table'] = sourceTable;
    item['table_number'] = tableNumber;

    return {
      "id": item['id'].toString(),
      "type": "santunan",
      "title": "Pengajuan Santunan",
      "no_pendaftaran": item['no_pendaftaran'] ?? '-',
      "lokasi": item['lokasi'] ?? '-',
      "ptpn": item['ptpn'] ?? '-',
      "tanggal_meninggal": tanggalMeninggal,
      "lokasi_meninggal": item['lokasi_meninggal'] ?? '-',
      "status": item['status'] ?? "Terkirim",
      "updated_at": updatedAt,
      "date": updatedAt ?? DateTime.now(),
      "full_data": item,
    };
  }

  Map<String, dynamic> _formatBPJSItem(Map<String, dynamic> item) {
    DateTime? createdAt;
    if (item['created_at'] != null &&
        item['created_at'].toString().isNotEmpty) {
      try {
        createdAt = DateTime.parse(item['created_at']);
      } catch (e) {
        print('Error parsing created_at: ${e.toString()}');
      }
    }

    DateTime? updatedAt;
    if (item['updated_at'] != null &&
        item['updated_at'].toString().isNotEmpty) {
      try {
        updatedAt = DateTime.parse(item['updated_at']);
      } catch (e) {
        print('Error parsing updated_at: ${e.toString()}');
      }
    }

    return {
      "id": item['id'].toString(),
      "type": "bpjs",
      "title": "Pengaduan BPJS",
      "no_pendaftaran": item['no_pengaduan'] ?? item['nomor_pengaduan'] ?? '-',
      "subjek": item['subjek'] ?? item['subject'] ?? '-',
      "kategori": item['kategori'] ?? item['category'] ?? '-',
      "status": item['status'] ?? "Terkirim",
      "created_at": createdAt,
      "updated_at": updatedAt,
      "date": updatedAt ?? createdAt ?? DateTime.now(),
      "full_data": item,
    };
  }

  Widget _getDocumentIcon(String status, String type) {
    IconData iconData;
    Color iconColor;

    // Different icons for different types
    if (type == 'bpjs') {
      switch (status) {
        case 'Diproses':
          iconData = Icons.hourglass_top;
          iconColor = Colors.orange;
          break;
        case 'Ditolak':
          iconData = Icons.cancel;
          iconColor = Colors.red;
          break;
        case 'Selesai':
          iconData = Icons.check_circle;
          iconColor = Colors.green;
          break;
        case 'Terkirim':
        default:
          iconData = Icons.description;
          iconColor = Colors.blue;
          break;
      }
    } else {
      // Santunan icons
      switch (status) {
        case 'Diproses':
          iconData = Icons.hourglass_top;
          iconColor = Colors.orange;
          break;
        case 'Ditolak':
          iconData = Icons.cancel;
          iconColor = Colors.red;
          break;
        case 'Selesai':
          iconData = Icons.check_circle;
          iconColor = Colors.green;
          break;
        case 'Terkirim':
        default:
          iconData = Icons.description;
          iconColor = Colors.blue;
          break;
      }
    }
    return Icon(iconData, color: iconColor, size: 40);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Histori Pengajuan & Pengaduan"),
          backgroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Histori Pengajuan & Pengaduan"),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchHistoriData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Histori Pengajuan & Pengaduan",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: historiList.isEmpty
          ? const Center(child: Text("Tidak ada data histori ditemukan"))
          : RefreshIndicator(
              onRefresh: fetchHistoriData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: historiList.length,
                itemBuilder: (context, index) {
                  final item = historiList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ListTile(
                      leading: _getDocumentIcon(item['status'], item['type']),
                      title: Text(
                        item['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            "No. ${item['type'] == 'bpjs' ? 'Pengaduan' : 'Pendaftaran'}: ${item['no_pendaftaran']}",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          if (item['type'] == 'bpjs')
                            Text("Subjek: ${item['subjek']}")
                          else
                            Text("PTPN: ${item['ptpn']}"),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(item['status']),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item['status'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(item['date']),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                      onTap: () => _navigateToDetailForm(context, item),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Diproses':
        return Colors.orange;
      case 'Ditolak':
        return Colors.red;
      case 'Selesai':
        return Colors.green;
      case 'Terkirim':
      default:
        return Colors.blue;
    }
  }
}
