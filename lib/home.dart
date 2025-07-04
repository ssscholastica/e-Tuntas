import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:etuntas/bpjs/aduan-bpjs.dart';
import 'package:etuntas/cara-pangajuan/caraPengajuan.dart';
import 'package:etuntas/cek-status-pengajuan/trackingAwal.dart';
import 'package:etuntas/login-signup/login.dart';
import 'package:etuntas/models/notification_model.dart';
import 'package:etuntas/navbar.dart';
import 'package:etuntas/network/globals.dart';
import 'package:etuntas/notifikasi.dart';
import 'package:etuntas/pengajuan-santunan/alurPengajuan1.dart';
import 'package:etuntas/persyaratan/persyaratan.dart';
import 'package:etuntas/pertanyaan-umum/pertanyaan-umum.dart';
import 'package:etuntas/rekening/bank.dart';
import 'package:etuntas/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String name= "";
  List<NotificationModel> notifications = [];
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    loadNotifications();
  }

  void loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ??'';
      final notifData = await NotificationService.fetchNotifications(token);
      final unread = notifData.where((n) => !n.isRead).length;

      setState(() {
        notifications = notifData;
        unreadCount = unread;
      });
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }

   Future<void> fetchUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email') ?? '';
    final token = prefs.getString('access_token') ?? '';
    final storedName = prefs.getString('user_name') ?? '';

    debugPrint("Stored email: $userEmail");
    debugPrint("Stored token: $token");

    if (storedName.isNotEmpty) {
      setState(() {
        name = storedName;
      });
    }

    if (userEmail.isEmpty || token.isEmpty) {
      debugPrint("No user email or token found in SharedPreferences.");
      setState(() {
        name = "Please login";
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        navigateToLogin(context);
      });
      return;
    }

    final url = Uri.parse("${baseURL}user/email/$userEmail");
    debugPrint("Fetching user data from: $url");

    try {
      final url = Uri.parse("${baseURL}user/email/$userEmail");
      debugPrint("Fetching user data from: $url");
      final headers = await getHeaders();
      final response = await http.get(url, headers: headers);
      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('name')) {
          setState(() {
            name = data['name'] ?? userEmail;
          });
          await prefs.setString('user_name', name);
          
        } else {
          setState(() {
            name = "Name field not found";
          });
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        setState(() {
          name = "Please login again";
        });
        await prefs.remove('access_token');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Your session has expired. Please login again."),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Login',
              onPressed: () {
                navigateToLogin(context);
              },
            ),
          ),
        );

        Future.delayed(Duration(seconds: 3), () {
          navigateToLogin(context);
        });
      } else {
        setState(() {
          name = "User Not Found";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Error: Could not fetch user data. Status: ${response.statusCode}"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      setState(() {
        name = "Error Fetching Data";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: $e"),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const Login()),
    );
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                        style: const TextStyle(
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
                                builder: (context) => NotificationPage()),
                          );
                        },
                      child: badges.Badge(
                          badgeContent: Text(
                            unreadCount.toString(),
                            style: const TextStyle(color: Colors.white),
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
                child: Wrap(
                  spacing: -4,
                  runSpacing: 20,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Wrap(
                  spacing: 30,
                  runSpacing: 40,
                  alignment: WrapAlignment.start,
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
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
