import 'package:etuntas/admin/admin-BPJStrack.dart';
import 'package:etuntas/admin/admin-santunanTrack.dart';
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
                  child: const Text(
                    'Admin 01',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
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
              ],
            ),
          ),
        ],
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
