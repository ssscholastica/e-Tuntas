import 'dart:convert';

import 'package:etuntas/navbar.dart';
import 'package:etuntas/network/globals.dart';
import 'package:etuntas/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileBersangkutan extends StatefulWidget {
  const ProfileBersangkutan({super.key});

  @override
  State<ProfileBersangkutan> createState() => _ProfileBersangkutanState();
}

class _ProfileBersangkutanState extends State<ProfileBersangkutan> {
  String namaBersangkutan = '-';
  String pgUnit = '-';
  String nik = '-';
  String nomorPensiunan = '-';
  String status = '-';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email') ?? '';

    if (userEmail.isEmpty) {
      debugPrint("No user email found in SharedPreferences.");
      setState(() {
        namaBersangkutan = '-';
        pgUnit = '-';
        nik = '-';
        nomorPensiunan = '-';
        status = '-';
      });
      return;
    }

    final url = Uri.parse("${baseURL}user/email/$userEmail");
    debugPrint("Fetching user data from: $url");

    try {
      final response = await http.get(url, headers: headers);
      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          namaBersangkutan = data['nama_bersangkutan'] ?? "-";
          pgUnit = data['pg_unit'] ?? "-";
          nik = data['nik'] ?? "-";
          nomorPensiunan = data['nomor_pensiunan'] ?? "-";
          status = data['status'] ?? "-";
        });
      } else {
        setState(() {
          namaBersangkutan = '-';
          pgUnit = '-';
          nik = '-';
          nomorPensiunan = '-';
          status = '-';
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      setState(() {
        namaBersangkutan = '-';
        pgUnit = '-';
        nik = '-';
        nomorPensiunan = '-';
        status = '-';
      });
    }
  }


  Widget buildTemplate(String judul, String isiJudul) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            judul,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0XFF8C8C8C),
                fontWeight: FontWeight.w400),
          ),
          Text(
            isiJudul,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0XFF000000),
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget buildTemplateBawah(
      String imagePath, String namaImage, String? imagePathKanan) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 24,
            height: 24,
          ),
          const SizedBox(
            width: 20,
          ),
          Text(
            namaImage,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0XFF000000),
                fontWeight: FontWeight.w400),
          ),
          const Spacer(),
          if (imagePathKanan != null)
            Image.asset(
              imagePathKanan,
              width: 24,
              height: 24,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(
                  top: 80, left: 20, right: 20, bottom: 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Profile()),
                      );
                    },
                    child: Image.asset(
                      'assets/simbol back.png',
                      width: 28,
                      height: 28,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Profile Bersangkutan",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0XFF000000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 510,
            child: Stack(
              children: [
                Image.asset(
                  "assets/background data bersangkutan.png",
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 80,
                  left: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(top: 20, left: 20, right: 20),
                          child: Center(
                            child: Text(
                              "Informasi Data Bersangkutan",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0XFF000000),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            buildTemplate('Nama Lengkap', namaBersangkutan),
                            buildTemplate(
                                'Unit Terakhir Dinas', pgUnit),
                            buildTemplate('NIK', nik),
                            buildTemplate('Nomor Pensiunan', nomorPensiunan),
                            buildTemplate('Status', status),
                            const SizedBox(
                              height: 20,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
