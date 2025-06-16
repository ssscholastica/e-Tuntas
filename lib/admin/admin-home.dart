import 'dart:convert';

import 'package:etuntas/admin/admin-BPJStrack.dart';
import 'package:etuntas/admin/admin-faq.dart';
import 'package:etuntas/admin/admin-santunanTrack.dart';
import 'package:etuntas/login-signup/login.dart';
import 'package:etuntas/network/globals.dart';
import 'package:etuntas/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String name = "";

  @override
  void initState() {
    super.initState();
    fetchUserName();
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
            content:
                const Text("Your session has expired. Please login again."),
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
      MaterialPageRoute(builder: (context) => const Login()),
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
                    'Admin E-Tuntas',
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
                              builder: (context) => const SplashScreen()),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo logout.png',
                            height: 25,
                            width: 25,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 30),
                child: const Text(
                  "Tracking",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TrackSantunan()),
                          );
                        },
                        child: buildImageBox("assets/pengajuan santunan.png",
                            "Tracking \nSantunan")),
                    const SizedBox(width: 35),
                    InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TrackBPJS()),
                          );
                        },
                        child: buildImageBox(
                            "assets/pengajuan bpjs.png", "Tracking \nBPJS")),
                    const SizedBox(width: 35),
                    InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DaftarFAQ()),
                          );
                        },
                        child: buildImageBox(
                            "assets/faq.png", "Tambah \nFAQ")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 79,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0XFF2F2F9D),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.home_outlined,
                    color: Color(0xFFFFFFFF),
                    size: 24,
                  ),
                ),
                const Text(
                  "Home",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
