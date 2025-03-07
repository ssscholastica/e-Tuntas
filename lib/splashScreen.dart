import 'package:etuntas/login-signup/login.dart';
import 'package:flutter/material.dart';

import 'login-signup/pendaftaran.dart';

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
                Image.asset(
                  "assets/logo ptpn1.png",
                  height: 34.653465270996094,
                  width: 25,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  "Regional 4",
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8C8C8C)),
                ),
                const Spacer(),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF6F6FB9), Color(0xFF2F2F9D), Color(0xFF26267E)],
                  ).createShader(bounds),
                  child: const Text(
                    'E-Tuntas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 40),
          Image.asset(
            "assets/Credit card-pana 1.png",
            height: 300,
            width: 300,
          ),
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
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text: "Silakan lakukan "),
                  TextSpan(
                    text: "Pendaftaran",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        " terlebih dahulu. Jika sudah memiliki username dan password silakan login",
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Pendaftaran()),
              );
            },
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
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
