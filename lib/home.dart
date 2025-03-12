import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:etuntas/bpjs/aduan-bpjs.dart';
import 'package:etuntas/cara-pangajuan/caraPengajuan.dart';
import 'package:etuntas/cek-status-pengajuan/trackingAwal.dart';
import 'package:etuntas/navbar.dart';
import 'package:etuntas/notifikasi.dart';
import 'package:etuntas/pengajuan-santunan/alurPengajuan1.dart';
import 'package:etuntas/persyaratan/persyaratan.dart';
import 'package:etuntas/pertanyaan-umum/pertanyaan-umum.dart';
import 'package:etuntas/rekening/bank.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:etuntas/network/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String name= "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

   Future<void> fetchUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email') ?? '';

    if (userEmail.isEmpty) {
      debugPrint("No user email found in SharedPreferences.");
      setState(() {
        name = "No User Logged In";
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

        if (data.containsKey('name')) {
          setState(() {
            name = data['name'];
          });
        } else {
          setState(() {
            name = "Name field not found";
          });
        }
      } else {
        setState(() {
          name = "User Not Found";
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      setState(() {
        name = "Error Fetching Data";
      });
    }
  }



  Widget buildImageBox(String imagePath, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEDEFF3),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Image.asset(
            imagePath,
            width: 28,
            height: 28.566787719726562,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF6F6FB9),
                  Color(0xFF2F2F9D),
                  Color(0xFF26267E)
                ],
              ).createShader(bounds),
              child: const Text(
                'E-Tuntas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            margin:
                const EdgeInsets.only(left: 16, right: 20, top: 25, bottom: 25),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/profile.png",
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: Text(
                    name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotifPage()),
                      );
                    },
                  child: badges.Badge(
                      badgeContent: const Text(
                        '3',
                        style: TextStyle(color: Colors.white),
                      ),
                      position: badges.BadgePosition.topEnd(top: -8, end: -7),
                      badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
                      child: const Icon(
                        Icons.notifications_outlined,
                        size: 28,
                      )),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 30),
            child: const Text(
              "Informasi",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CaraPengajuan()),
                      );
                    },
                    child: buildImageBox(
                        "assets/cara pengajuan.png", "Cara \nPengajuan")),
                const SizedBox(width: 35),
                InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Persyaratan()),
                      );
                    },
                    child: buildImageBox(
                        "assets/persyaratan.png", "Persyaratan \n")),
                const SizedBox(width: 35),
                InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PertanyaanUmum()),
                      );
                    },
                    child: buildImageBox(
                        "assets/faq.png", "Pertanyaan \nUmum / FAQ")),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.only(left: 30),
            child: const Text(
              "Pengajuan",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const alurPengajuan1()),
                  );
                },
                child: buildImageBox(
                    "assets/pengajuan santunan.png", "Pengajuan \nSantunan"),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const aduanBPJS()),
                  );
                },
                child: buildImageBox("assets/pengajuan bpjs.png", "Pengaduan \nBPJS"),
              ),
                            InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TrackingAwal()),
                  );
                },
                child: buildImageBox("assets/cek status pengajuan.png",
                    "Cek Status \nPengajuan"),
              ),
              InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Bank()),
                    );
                  },
                  child: buildImageBox(
                      "assets/rekening bank.png", "Rekening \nBank")),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
