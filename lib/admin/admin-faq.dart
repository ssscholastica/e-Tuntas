import 'dart:convert';

import 'package:etuntas/network/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'admin-editFAQ.dart'; // Import halaman edit
import 'admin-formFAQ.dart';

class FaqModel {
  final int id;
  final String pertanyaan;
  final String jawaban;
  final String createdAt;
  final String updatedAt;

  FaqModel({
    required this.id,
    required this.pertanyaan,
    required this.jawaban,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'],
      pertanyaan: json['pertanyaan'],
      jawaban: json['jawaban'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class DaftarFAQ extends StatefulWidget {
  const DaftarFAQ({Key? key}) : super(key: key);

  @override
  State<DaftarFAQ> createState() => _DaftarFAQState();
}

class _DaftarFAQState extends State<DaftarFAQ> {
  List<FaqModel> faqList = [];
  List<FaqModel> filteredFaqList = [];
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFAQs();
    searchController.addListener(_filterFAQs);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterFAQs() {
    setState(() {
      if (searchController.text.isEmpty) {
        filteredFaqList = List.from(faqList);
      } else {
        filteredFaqList = faqList
            .where((faq) => faq.pertanyaan
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _fetchFAQs() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${baseURL}faqs'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          faqList = data.map((json) => FaqModel.fromJson(json)).toList();
          filteredFaqList = List.from(faqList);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat data FAQ: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daftar FAQ",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Cari pertanyaan...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          // FAQ List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              errorMessage,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchFAQs,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : filteredFaqList.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada FAQ ditemukan',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: filteredFaqList.length,
                            itemBuilder: (context, index) {
                              final faq = filteredFaqList[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12.0),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditFAQ(faq: faq),
                                      ),
                                    );
                                    if (result == true) {
                                      _fetchFAQs();
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                faq.pertanyaan,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          faq.jawaban,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8)
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormTambahFAQ(),
            ),
          );
          if (result == true) {
            _fetchFAQs();
          }
        },
        backgroundColor: const Color(0XFF2F2F9D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}