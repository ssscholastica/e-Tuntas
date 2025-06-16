import 'dart:convert';

import 'package:etuntas/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../network/globals.dart';

class PertanyaanUmum extends StatefulWidget {
  const PertanyaanUmum({super.key});

  @override
  State<PertanyaanUmum> createState() => _PertanyaanUmumState();
}

class _PertanyaanUmumState extends State<PertanyaanUmum> {
  Map<String, bool> _expandedStatus = {};

  Future<List<Map<String, dynamic>>> fetchFAQ() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final headers = await getHeaders();

    final response = await http.get(
      Uri.parse('${baseURL}faqs'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal memuat data FAQ');
    }
  }

  Widget buildImageBox(String title, String content) {
    bool isExpanded = _expandedStatus[title] ?? false;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedStatus[title] = !isExpanded;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              width: MediaQuery.of(context).size.width * 0.88,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 5, bottom: 10),
              width: MediaQuery.of(context).size.width * 0.88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                content,
                style: const TextStyle(fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(
                      top: 60, left: 20, right: 20, bottom: 10),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Home()),
                          );
                        },
                        child: Image.asset(
                          'assets/simbol back.png',
                          width: 28,
                          height: 28,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Pertanyaan Umum",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0XFF000000),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              Stack(
                children: [
                  Positioned.fill(
                    child: Center(
                      child: Image.asset('assets/background pertanyaan.png'),
                    ),
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchFAQ(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child:
                              Text('Gagal memuat data FAQ: ${snapshot.error}'),
                        );
                      }

                      final data = snapshot.data!;
                      if (data.isEmpty) {
                        return const Center(child: Text('Tidak ada FAQ.'));
                      }

                      return Column(
                        children: data.map((faq) {
                          final pertanyaan = faq['pertanyaan'] ?? '';
                          final jawaban = faq['jawaban'] ?? '';
                          return buildImageBox(pertanyaan, jawaban);
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
