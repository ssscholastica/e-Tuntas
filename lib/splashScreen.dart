import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              children: [
                Image.asset("assets/logo ptpn1.png", height: 50),
                const SizedBox(height: 10),
                const Text(
                  "Santunan PTPN 1 Regional 4",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                const Spacer(),
                const Text(
                  "E-Tuntas",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F2F9D)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Image.asset("assets/Credit card-pana 1.png", height: 300),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 30),
              child: const Text(
                "Halo, \nSelamat Datang",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(left: 30, right: 30),
            child: const Text(
              "Silakan lakukan Pendaftaran terlebih dahulu. Jika sudah memiliki username dan password silakan login",
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 140, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: const Color(0xFF2F2F9D)),
            child: const Text("Pendaftaran",
                style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16)),
          ),
          const SizedBox(height: 20),
          const Text("atau",
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Login",
                style: TextStyle(color: Color(0xFF2F2F9D), fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
