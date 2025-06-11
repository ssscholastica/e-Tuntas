import 'dart:convert';
import 'dart:core';

import 'package:etuntas/navbar.dart';
import 'package:etuntas/network/globals.dart';
import 'package:etuntas/profile/editProfile.dart';
import 'package:etuntas/profile/profileBersangkutan.dart';
import 'package:etuntas/profile/ubahSandi.dart';
import 'package:etuntas/splashScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = "-";
  String email = "-";
  String nomorHp = "-";
  String tanggalLahir = "-";
  String alamat = "-";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email') ?? '';

    if (userEmail.isEmpty) {
      setState(() {
        name = "No User Logged In";
        email = "-";
        nomorHp = "-";
        tanggalLahir = "-";
        alamat = "-";
      });
      return;
    }

    final url = Uri.parse("${baseURL}user/email/$userEmail");

    try {
      final headers = await getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          name = data['name'] ?? "No Name";
          email = data['email'] ?? "-";
          nomorHp = data['nomor_hp'] ?? "-";
          tanggalLahir = data['tanggal_lahir'] ?? "-";
          alamat = data['alamat'] ?? "-";
        });
      } else {
        setState(() {
          name = "User Not Found";
          email = "-";
          nomorHp = "-";
          tanggalLahir = "-";
          alamat = "-";
        });
      }
    } catch (e) {
      setState(() {
        name = "Error Fetching Data";
        email = "-";
        nomorHp = "-";
        tanggalLahir = "-";
        alamat = "-";
      });
    }
  }

  Future<void> removeFcmTokenFromServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      final token = await FirebaseMessaging.instance.getToken();

      debugPrint('=== FLUTTER DEBUG START ===');
      debugPrint('Email: $email');
      debugPrint('FCM Token: $token');
      debugPrint('Base URL: $baseURL');
      debugPrint('Full URL: ${baseURL}remove-token-logout');

      if (email != null && token != null) {
        debugPrint('Sending request...');

        final response = await http.post(
          Uri.parse('${baseURL}remove-token-logout'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'device_token': token,
          }),
        );

        debugPrint('Response Status: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
        debugPrint('Response Headers: ${response.headers}');
      } else {
        debugPrint('Missing data - Email: $email, Token: $token');
      }

      debugPrint('=== FLUTTER DEBUG END ===');
    } catch (e, stackTrace) {
      debugPrint('Error removing FCM token: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }


  Widget buildTemplate(String judul, String isiJudul) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              judul,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0XFF8C8C8C),
                  fontWeight: FontWeight.w400),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              isiJudul,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0XFF000000),
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTemplateBawah(
      String imagePath, String namaImage, String? imagePathKanan) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              namaImage,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0XFF000000),
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
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
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final topPadding = MediaQuery.of(context).padding.top;
    final screenHeight = size.height -
        topPadding -
        (isLandscape ? 0 : kBottomNavigationBarHeight);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight,
            ),
            child: Column(
              children: [
                SizedBox(height: isLandscape ? 10 : 20),
                const Text(
                  "Akun Pengguna",
                  style: TextStyle(
                      fontSize: 18,
                      color: Color(0XFF000000),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: isLandscape ? 10 : 30),
                Container(
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        width: double.infinity,
                        height: isLandscape ? 100 : 180,
                        child: Image.asset(
                          "assets/background profile.png",
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: isLandscape ? 40 : 80,
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        child: Container(
                          width: double.infinity,
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
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 40, left: 20, right: 20),
                                child: Row(
                                  children: [
                                    const Text(
                                      "Profile",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0XFF000000),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const EditProfile()),
                                        );
                                      },
                                      child: const Text(
                                        "Edit",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0XFF2F2F9D),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  buildTemplate('Nama Lengkap', name),
                                  buildTemplate('Email', email),
                                  buildTemplate('Nomor HP', nomorHp),
                                  buildTemplate('Tanggal Lahir', tanggalLahir),
                                  buildTemplate('Alamat', alamat),
                                  const SizedBox(height: 20)
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: isLandscape ? 10 : 40,
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage("assets/profile.png"),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(left: 20, bottom: 10),
                  child: const Text(
                    'Lainnya',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0XFF000000),
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const UbahSandi()),
                            );
                          },
                          child: buildTemplateBawah('assets/logo sandi.png',
                              'Ganti Kata Sandi', 'assets/simbol next.png'),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfileBersangkutan()),
                            );
                          },
                          child: buildTemplateBawah(
                              'assets/logo informasi.png',
                              'Informasi Data Bersangkutan',
                              'assets/simbol next.png'),
                        ),
                        InkWell(
                            onTap: () async {
                              try {
                                // Remove FCM token first before clearing preferences
                                await removeFcmTokenFromServer();

                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('user_email');
                                await prefs.remove('user_token');
                                await prefs.remove(
                                    'access_token'); // Tambahkan ini juga
                                await prefs.clear();

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SplashScreen()),
                                  (route) => false,
                                );
                              } catch (e) {
                                debugPrint('Logout error: $e');
                                // Tetap logout meski ada error
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.clear();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SplashScreen()),
                                  (route) => false,
                                );
                              }
                            },
                            child: buildTemplateBawah(
                                'assets/logo logout.png', 'Keluar', null))
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
