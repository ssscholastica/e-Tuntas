import 'package:badges/badges.dart' as badges;
import 'package:etuntas/admin/admin-trackBPJS.dart';
import 'package:etuntas/cara-pangajuan/caraPengajuan.dart';
import 'package:etuntas/navbar.dart';
import 'package:etuntas/notifikasi.dart';
import 'package:flutter/material.dart';

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
                  child: const Text(
                    // name,
                    'Admin',
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
                      MaterialPageRoute(builder: (context) => NotifPage()),
                    );
                  },
                  child: badges.Badge(
                      badgeContent: const Text(
                        '3',
                        style: TextStyle(color: Colors.white),
                      ),
                      position: badges.BadgePosition.topEnd(top: -8, end: -7),
                      badgeStyle:
                          const badges.BadgeStyle(badgeColor: Colors.red),
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
                            builder: (context) => const CaraPengajuan()),
                      );
                    },
                    child: buildImageBox("assets/pengajuan santunan.png", "Tracking \nSantunan")),
                const SizedBox(width: 35),
                InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TrackBPJS()),
                      );
                    },
                    child: buildImageBox(
                        "assets/pengajuan bpjs.png", "Tracking \nBPJS")),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
