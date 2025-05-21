import 'dart:convert';
import 'dart:math';

import 'package:etuntas/admin/admin-santunanForm.dart';
import 'package:etuntas/network/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TrackSantunan extends StatefulWidget {
  const TrackSantunan({Key? key}) : super(key: key);
  @override
  State<TrackSantunan> createState() => _TrackSantunanState();
}

class _TrackSantunanState extends State<TrackSantunan> {
  bool showFilterDropdown = false;
  bool isFilterApplied = false;
  String searchQuery = "";
  String selectedFilterType = "";
  bool isLoading = true;
  String errorMessage = "";
  bool sortByDate = false;
  List<String> selectedPTPNs = [];
  List<String> selectedStatus = [];
  DateTime? startDate;
  DateTime? endDate;

  final List<String> ptpnOptions = [
    'PTPN 10',
    'PTPN 11',
  ];

  final List<String> statusOptions = [
    'Terkirim',
    'Diproses',
    'Ditolak',
    'Selesai'
  ];

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _navigateToDetailForm(
      BuildContext context, Map<String, dynamic> pengaduanData) async {
    if (pengaduanData['source_table'] != null &&
        !pengaduanData['full_data'].containsKey('source_table')) {
      pengaduanData['full_data']['source_table'] =
          pengaduanData['source_table'];
    }
    if (pengaduanData['table_number'] != null &&
        !pengaduanData['full_data'].containsKey('table_number')) {
      pengaduanData['full_data']['table_number'] =
          pengaduanData['table_number'];
    }

    final bool? statusUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => formSantunan(
          pengaduanId: pengaduanData['id'],
          pengaduanData: pengaduanData['full_data'],
          onStatusUpdated: () {
            print("Status updated callback triggered");
          },
        ),
      ),
    );
    if (statusUpdated == true) {
      print("Status was updated, refreshing data...");
      fetchPengajuanSantunanData();
    }
  }

  List<Map<String, dynamic>> trackSantunanList = [];

  @override
  void initState() {
    super.initState();
    fetchPengajuanSantunanData();
  }

  @override
  void dispose() {
    _removeFilterOverlay();
    super.dispose();
  }

  Future<void> fetchPengajuanSantunanData() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });
    try {
      List<Map<String, dynamic>> allSantunanData = [];
      final headers = await getHeaders();
      final mainResponse = await http.get(
        Uri.parse('${baseURL}pengajuan-santunan/'),
        headers: headers,
      );

      if (mainResponse.statusCode == 200) {
        final List<dynamic> mainData = json.decode(mainResponse.body);
        for (var item in mainData) {
          if (item is Map<String, dynamic>) {
            item['source_table'] = 'pengajuan-santunan';
            item['table_number'] = '';
          }
        }
        allSantunanData.addAll(mainData.cast<Map<String, dynamic>>());
      }

      for (int i = 1; i <= 5; i++) {
        final additionalResponse = await http.get(
          Uri.parse('${baseURL}pengajuan-santunan$i/'),
          headers: headers,
        );

        print(
            'Status code for pengajuan-santunan$i: ${additionalResponse.statusCode}');
        print(
            'Response body for pengajuan-santunan$i: ${additionalResponse.body}');

        if (additionalResponse.statusCode == 200) {
          final List<dynamic> additionalData =
              json.decode(additionalResponse.body);
          for (var item in additionalData) {
            if (item is Map<String, dynamic>) {
              item['source_table'] = 'pengajuan-santunan$i';
              item['table_number'] = '$i';
            }
          }
          allSantunanData.addAll(additionalData.cast<Map<String, dynamic>>());
        }
      }

      setState(() {
        trackSantunanList = allSantunanData.map<Map<String, dynamic>>((item) {
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

          return {
            "id": item['id'].toString(),
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
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error: $e";
      });
    }
  }

  List<Map<String, dynamic>> getFilteredList() {
    List<Map<String, dynamic>> result = List.from(trackSantunanList);
    if (searchQuery.isNotEmpty) {
      result = result
          .where((item) =>
              item["no_pendaftaran"]
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              item["ptpn"]
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              item["lokasi"]
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }
    if (selectedPTPNs.isNotEmpty) {
      result =
          result.where((item) => selectedPTPNs.contains(item["ptpn"])).toList();
    }
    if (selectedStatus.isNotEmpty) {
      result = result
          .where((item) => selectedStatus.contains(item["status"]))
          .toList();
    }
    if (startDate != null && endDate != null) {
      result = result
          .where((item) =>
              (item["date"] as DateTime?)
                      ?.isAfter(startDate!.subtract(const Duration(days: 1))) ==
                  true &&
              (item["date"] as DateTime?)
                      ?.isBefore(endDate!.add(const Duration(days: 1))) ==
                  true)
          .toList();
    } else if (startDate != null) {
      result = result
          .where((item) =>
              (item["date"] as DateTime?)
                  ?.isAfter(startDate!.subtract(const Duration(days: 1))) ==
              true)
          .toList();
    } else if (endDate != null) {
      result = result
          .where((item) =>
              (item["date"] as DateTime?)
                  ?.isBefore(endDate!.add(const Duration(days: 1))) ==
              true)
          .toList();
    }
    if (sortByDate) {
      result.sort((a, b) {
        final DateTime? dateA = a["date"] as DateTime?;
        final DateTime? dateB = b["date"] as DateTime?;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });
    }
    return result;
  }

  void _toggleFilterOverlay() {
    if (_overlayEntry != null) {
      _removeFilterOverlay();
    } else {
      _showFilterOverlay();
    }
  }

  void _showFilterOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeFilterOverlay,
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            top: position.dy + 35,
            right: max(10.0, min(position.dx - 8, screenSize.width - 340)),
            width: min(340.0, screenSize.width - 32),
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: screenSize.height * 0.7,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _removeFilterOverlay,
                          )
                        ],
                      ),
                      const Divider(),
                      const Text(
                        "Filter Berdasarkan PTPN:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ptpnOptions.map((ptpn) {
                          return FilterChip(
                            label: Text(ptpn),
                            selected: selectedPTPNs.contains(ptpn),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedPTPNs.add(ptpn);
                                } else {
                                  selectedPTPNs.remove(ptpn);
                                }
                                isFilterApplied = selectedPTPNs.isNotEmpty ||
                                    selectedStatus.isNotEmpty ||
                                    startDate != null ||
                                    endDate != null ||
                                    sortByDate;
                              });
                              _rebuildFilterOverlay();
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Filter Berdasarkan Status:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: statusOptions.map((status) {
                          return FilterChip(
                            label: Text(status),
                            selected: selectedStatus.contains(status),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedStatus.add(status);
                                } else {
                                  selectedStatus.remove(status);
                                }
                                isFilterApplied = selectedPTPNs.isNotEmpty ||
                                    selectedStatus.isNotEmpty ||
                                    startDate != null ||
                                    endDate != null ||
                                    sortByDate;
                              });
                              _rebuildFilterOverlay();
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Urut Berdasarkan Tanggal:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Switch(
                            value: sortByDate,
                            onChanged: (value) {
                              setState(() {
                                sortByDate = value;
                                isFilterApplied = selectedPTPNs.isNotEmpty ||
                                    selectedStatus.isNotEmpty ||
                                    startDate != null ||
                                    endDate != null ||
                                    sortByDate;
                              });
                              _rebuildFilterOverlay();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedPTPNs = [];
                                selectedStatus = [];
                                startDate = null;
                                endDate = null;
                                sortByDate = false;
                                isFilterApplied = false;
                              });
                              _rebuildFilterOverlay();
                            },
                            child: const Text("Reset"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              _removeFilterOverlay();
                              setState(() {
                                isFilterApplied = selectedPTPNs.isNotEmpty ||
                                    selectedStatus.isNotEmpty ||
                                    startDate != null ||
                                    endDate != null ||
                                    sortByDate;
                              });
                            },
                            child: const Text("Terapkan"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _rebuildFilterOverlay() {
    _removeFilterOverlay();
    _showFilterOverlay();
  }

  void _removeFilterOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _getDocumentIcon(String status) {
    IconData iconData;
    Color iconColor;
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
          title: const Text("Track Santunan"),
          backgroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Track Santunan"),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchPengajuanSantunanData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    final filteredList = getFilteredList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track Santunan",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari berdasarkan No. Pendaftaran atau PTPN",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: isFilterApplied ? Colors.blue : Colors.black,
                  ),
                  onPressed: _toggleFilterOverlay,
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text("Tidak ada data ditemukan"))
                : RefreshIndicator(
                    onRefresh: fetchPengajuanSantunanData,
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: _getDocumentIcon(item['status']),
                            title: Text(
                              "No. Pendaftaran: ${item['no_pendaftaran']}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Status: ${item['status']}"),
                                if (item['updated_at'] != null)
                                  Text(
                                      "Tanggal Pengajuan: ${_formatDate(item['updated_at'])}"),
                              ],
                            ),
                            onTap: () => _navigateToDetailForm(context, item),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
