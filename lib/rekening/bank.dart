import 'dart:convert';

import 'package:etuntas/network/globals.dart';
import 'package:etuntas/rekening/addBank.dart';
import 'package:etuntas/rekening/editBank.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Bank extends StatefulWidget {
  const Bank({super.key});

  @override
  State<Bank> createState() => _BankState();
}

class _BankState extends State<Bank> {
  List<Map<String, String>> bankAccounts = [];

  @override
  void initState() {
    super.initState();
    fetchBankAccounts();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> fetchBankAccounts() async {
    final token = await getToken();
    print("Token: $token");

    final url = Uri.parse('${baseURL}rekening-bank');

    try {
      final headers = await getHeaders();
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          bankAccounts = data.map<Map<String, String>>((item) {
            return {
              'Nama Bank': item['nama_bank']?.toString() ?? '',
              'Nama Pemilik': item['nama_pemilik']?.toString() ?? '',
              'Nomor Rekening': item['nomor_rekening']?.toString() ?? '',
              'Buku Tabungan': item['buku_tabungan']?.toString() ?? '',
            };
          }).toList();
        });
      } else {
        print('Gagal mengambil data rekening: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan saat mengambil data rekening: $e');
    }
  }


  void _navigateToAddBank() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const addBank()),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        bankAccounts.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 60, left: 20, right: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/simbol back.png',
                      width: 28,
                      height: 28,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Akun Bank",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0XFF000000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(left: 30, right: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        "Rekening Saya",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        " (Maksimal 3)",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.black),
                        onPressed: _navigateToAddBank,
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bankAccounts.length,
                    itemBuilder: (context, index) {
                      final bank = bankAccounts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 25),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xAACFE2FF),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => editBank(bankAccounts: bank),
                                    ),
                                  );

                                  if (result != null &&
                                      result is Map<String, String>) {
                                    setState(() {
                                      bankAccounts[index] = result;
                                    });
                                  }
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          bank['Nama Bank'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        Text(
                                          bank['Nama Pemilik'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: -2,
                              top: -25,
                              child: Image.asset(
                                'assets/tambahBank.png',
                                width: 140,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
