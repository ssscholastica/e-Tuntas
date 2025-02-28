import 'package:etuntas/cara-pangajuan/caraPengajuan.dart';
import 'package:etuntas/profile/editProfile.dart';
import 'package:etuntas/navbar.dart';
import 'package:etuntas/profile/profile.dart';
import 'package:etuntas/profile/ubahSandi.dart';
import 'package:flutter/material.dart';

class CaraPengajuanSantunan extends StatefulWidget {
  const CaraPengajuanSantunan({super.key});

  @override
  State<CaraPengajuanSantunan> createState() => _CaraPengajuanSantunanState();
}

class _CaraPengajuanSantunanState extends State<CaraPengajuanSantunan> {
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
              margin: const EdgeInsets.only(
                  top: 80, left: 20, right: 20, bottom: 10),
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
                    child: Image.asset(
                      'assets/simbol back.png',
                      width: 28,
                      height: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    "Cara Pengajuan",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0XFF000000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Stack(
            children: [
              const SizedBox(height: 30),
              Container(
                  margin: const EdgeInsets.only(top: 200),
                  child: Image.asset('assets/background cara pengajuan.png')),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Alur Pengajuan Dokumen Santunan",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Image.asset('assets/alur pengajuan dokumen santunan.png'),
                ],
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
