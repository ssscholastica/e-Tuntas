import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class formSantunan extends StatefulWidget {
  final String pengaduanId;
  final Map<String, dynamic> pengaduanData;
  final Function onStatusUpdated;

  const formSantunan({
    Key? key,
    required this.pengaduanId,
    required this.pengaduanData,
    required this.onStatusUpdated,
  }) : super(key: key);

  @override
  State<formSantunan> createState() => _formSantunanState();
}

class _formSantunanState extends State<formSantunan> {
  final Dio _dio = Dio();
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  bool statusChanged = false;

  String? selectedStatus;
  List<String> statusOptions = ['Terkirim', 'Diproses', 'Ditolak', 'Selesai'];

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.pengaduanData['status'] ?? 'Terkirim';
    if (!statusOptions.contains(selectedStatus)) {
      statusOptions.add(selectedStatus!);
    }
  }

  Future<void> setAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
  }

  Future<void> updateStatus() async {
    if (selectedStatus == null) return;
    setState(() {
      isLoading = true;
    });
    try {
      await setAuthToken();
      print('Auth token set');
      String apiEndpoint;
      if (widget.pengaduanData.containsKey('source_table')) {
        apiEndpoint =
            'http://10.0.2.2:8000/api/${widget.pengaduanData['source_table']}/${widget.pengaduanId}/status';
      } else {
        String tableNumber = '';
        if (widget.pengaduanData.containsKey('table_number')) {
          tableNumber = widget.pengaduanData['table_number'];
        }
        apiEndpoint =
            'http://10.0.2.2:8000/api/pengajuan-santunan${tableNumber}/${widget.pengaduanId}/status';
      }

      print('Making request to: $apiEndpoint');
      final response = await _dio.put(
        apiEndpoint,
        data: {'status': selectedStatus},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully')),
        );
        setState(() {
          statusChanged = true;
        });
        widget.onStatusUpdated();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status')),
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
