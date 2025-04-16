import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class formBPJS extends StatefulWidget {
  final int pageIndex;
  
  const formBPJS({Key? key, required this.pageIndex}) : super(key: key);

  @override
  _formBPJSState createState() => _formBPJSState();
}

class _formBPJSState extends State<formBPJS> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  
  final TextEditingController _kategoriBpjsController = TextEditingController();
  final TextEditingController _tanggalAjuanController = TextEditingController();
  final TextEditingController _nomorBpjsNikController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _dataPendukungController = TextEditingController();
  
  String _selectedStatus = 'terkirim';
  List<String> statusOptions = ['terkirim', 'diproses', 'selesai', 'ditolak'];
  
  Map<String, dynamic>? pengaduanData;

  @override
  void initState() {
    super.initState();
    fetchPengaduanData();
  }

  @override
  void dispose() {
    _kategoriBpjsController.dispose();
    _tanggalAjuanController.dispose();
    _nomorBpjsNikController.dispose();
    _deskripsiController.dispose();
    _dataPendukungController.dispose();
    super.dispose();
  }

  Future<void> fetchPengaduanData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/pengaduan-bpjs/${widget.pageIndex + 1}'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pengaduanData = data;
          _kategoriBpjsController.text = data['kategori_bpjs'] ?? '';
          _tanggalAjuanController.text = data['tanggal_ajuan'] ?? '';
          _nomorBpjsNikController.text = data['nomor_bpjs_nik'] ?? '';
          _deskripsiController.text = data['deskripsi'] ?? '';
          _dataPendukungController.text = data['data_pendukung'] ?? '';
          _selectedStatus = data['status'] ?? 'terkirim';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Failed to load data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> updateStatus() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/api/pengaduan-bpjs/${widget.pageIndex + 1}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'status': _selectedStatus,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status berhasil diperbarui')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchPengaduanData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategori BPJS
          TextFormField(
            controller: _kategoriBpjsController,
            decoration: const InputDecoration(
              labelText: 'Kategori BPJS',
              border: OutlineInputBorder(),
            ),
            readOnly: true, // Data from database, read-only
          ),
          const SizedBox(height: 16),
          
          // Tanggal Ajuan
          TextFormField(
            controller: _tanggalAjuanController,
            decoration: const InputDecoration(
              labelText: 'Tanggal Ajuan',
              border: OutlineInputBorder(),
            ),
            readOnly: true, // Data from database, read-only
          ),
          const SizedBox(height: 16),
          
          // Nomor BPJS/NIK
          TextFormField(
            controller: _nomorBpjsNikController,
            decoration: const InputDecoration(
              labelText: 'Nomor BPJS/NIK',
              border: OutlineInputBorder(),
            ),
            readOnly: true, // Data from database, read-only
          ),
          const SizedBox(height: 16),
          
          // Deskripsi
          TextFormField(
            controller: _deskripsiController,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            readOnly: true, // Data from database, read-only
          ),
          const SizedBox(height: 16),
          
          // Data Pendukung
          TextFormField(
            controller: _dataPendukungController,
            decoration: InputDecoration(
              labelText: 'Data Pendukung',
              border: const OutlineInputBorder(),
              suffixIcon: _dataPendukungController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        // Logic to view the file
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Melihat file: ${_dataPendukungController.text}')),
                        );
                      },
                    )
                  : null,
            ),
            readOnly: true, // Data from database, read-only
          ),
          const SizedBox(height: 24),
          
          // Status Dropdown
          const Text('Status:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButton<String>(
              value: _selectedStatus,
              isExpanded: true,
              underline: const SizedBox(), // Remove the default underline
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                }
              },
              items: statusOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.capitalize()),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          
          // Update Button
          Center(
            child: ElevatedButton(
              onPressed: updateStatus,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Update Status',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}