import 'package:etuntas/navbar.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Center(
            child: Container(
                margin: const EdgeInsets.only(top: 80),
                child: const Text(
                  "Akun Pengguna",
                  style: TextStyle(
                      fontSize: 18,
                      color: Color(0XFF000000),
                      fontWeight: FontWeight.bold),
                )
                ),
          ),
          Image.asset("assets/background profile.png")
        ],
      ),
    );
  }
}
