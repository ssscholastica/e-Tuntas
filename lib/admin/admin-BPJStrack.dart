import 'dart:convert';

import 'package:etuntas/network/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/admin/admin-BPJSform.dart';

class TrackBPJS extends StatefulWidget {
  const TrackBPJS({Key? key}) : super(key: key);
  @override
  State<TrackBPJS> createState() => _TrackBPJSState();
}

class _TrackBPJSState extends State<TrackBPJS> {
  bool showFilterDropdown = false;
  bool isFilterApplied = false;
  String searchQuery = "";
  String selectedFilterType = "";
  bool isLoading = true;
  String errorMessage = "";
  bool sortByDate = false;
  List<String> selectedCategories = [];
  List<String> selectedStatus = [];
  DateTime? startDate;
  DateTime? endDate;

  final List<String> categoryOptions = [
    'BPJS Non Aktif',
    'Pindah Faskes',
    'Klaim BPJS Bermasalah',
    'Lain-lain'
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
    final bool? statusUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => formBPJS(
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
      fetchPengaduanBPJSData();
    }
  }

  List<Map<String, dynamic>> trackBPJSList = [];

  @override
  void initState() {
    super.initState();
    fetchPengaduanBPJSData();
  }

  @override
  void dispose() {
    _removeFilterOverlay();
    super.dispose();
  }

  Future<void> fetchPengaduanBPJSData() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });
    try {
      final response = await http.get(
        Uri.parse('${baseURL}pengaduan-bpjs/'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          trackBPJSList = jsonData.map<Map<String, dynamic>>((item) {
            return {
              "text":
                  "Nomor BPJS/NIK: ${item['nomor_bpjs_nik']}\nKategori: ${item['kategori_bpjs']}",
              "id": item['id'].toString(),
              "nomor_bpjs_nik": item['nomor_bpjs_nik'],
              "category": item['kategori_bpjs'],
              "date": DateTime.parse(item['tanggal_ajuan']),
              "status": item['status'] ?? "Terkirim",
              "full_data": item,
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              "Failed to load data. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error: $e";
      });
    }
  }

  List<Map<String, dynamic>> getFilteredList() {
    List<Map<String, dynamic>> result = List.from(trackBPJSList);
    if (searchQuery.isNotEmpty) {
      result = result
          .where((item) => item["text"]
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }
    if (selectedCategories.isNotEmpty) {
      result = result
          .where((item) => selectedCategories.contains(item["category"]))
          .toList();
    }
    if (selectedStatus.isNotEmpty) {
      result = result
          .where((item) => selectedStatus.contains(item["status"]))
          .toList();
    }
    if (startDate != null && endDate != null) {
      result = result
          .where((item) =>
              (item["date"] as DateTime)
                  .isAfter(startDate!.subtract(const Duration(days: 1))) &&
              (item["date"] as DateTime)
                  .isBefore(endDate!.add(const Duration(days: 1))))
          .toList();
    } else if (startDate != null) {
      result = result
          .where((item) => (item["date"] as DateTime)
              .isAfter(startDate!.subtract(const Duration(days: 1))))
          .toList();
    } else if (endDate != null) {
      result = result
          .where((item) => (item["date"] as DateTime)
              .isBefore(endDate!.add(const Duration(days: 1))))
          .toList();
    }
    if (sortByDate) {
      result.sort((a, b) => b["date"].compareTo(a["date"]));
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
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(-330, 35),
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(8),
            child: Container(
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
                    "Filter Berdasarkan Kategori:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categoryOptions.map((category) {
                      return FilterChip(
                        label: Text(category),
                        selected: selectedCategories.contains(category),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedCategories.add(category);
                            } else {
                              selectedCategories.remove(category);
                            }
                            isFilterApplied = selectedCategories.isNotEmpty ||
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
                            isFilterApplied = selectedCategories.isNotEmpty ||
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
                      const Text(
                        "Urut Berdasarkan Tanggal:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: sortByDate,
                        onChanged: (value) {
                          setState(() {
                            sortByDate = value;
                            isFilterApplied = selectedCategories.isNotEmpty ||
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
                            selectedCategories = [];
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
                      ElevatedButton(
                        onPressed: () {
                          _removeFilterOverlay();
                          setState(() {
                            isFilterApplied = selectedCategories.isNotEmpty ||
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

  Widget _getDocumentIcon(String category, String status) {
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

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Track BPJS"),
          backgroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Track BPJS"),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchPengaduanBPJSData,
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
          "Track BPJS",
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Cari berdasarkan nomor atau kategori",
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
                    CompositedTransformTarget(
                      link: _layerLink,
                      child: IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: isFilterApplied ? Colors.blue : Colors.black,
                        ),
                        onPressed: _toggleFilterOverlay,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text("Tidak ada data ditemukan"))
                : RefreshIndicator(
                    onRefresh: fetchPengaduanBPJSData,
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: _getDocumentIcon(
                                item['category'], item['status']),
                            title: Text(
                              "Nomor BPJS/NIK: ${item['nomor_bpjs_nik']}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Kategori: ${item['category']}"),
                                Text(
                                    "Status: ${(item['status'] ?? 'Terkirim')}"),
                                Text("Tanggal: ${_formatDate(item['date'])}"),
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
