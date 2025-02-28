import 'package:etuntas/cara-pangajuan/caraPengajuanBPJS.dart';
import 'package:etuntas/cara-pangajuan/caraPengajuanSantunan.dart';
import 'package:etuntas/home.dart';
import 'package:etuntas/profile/editProfile.dart';
import 'package:etuntas/navbar.dart';
import 'package:etuntas/profile/profile.dart';
import 'package:etuntas/profile/ubahSandi.dart';
import 'package:flutter/material.dart';

class CaraPengajuan extends StatefulWidget {
  const CaraPengajuan({super.key});

  @override
  State<CaraPengajuan> createState() => _CaraPengajuanState();
}

class _CaraPengajuanState extends State<CaraPengajuan> {
  @override
  void initState() {
    super.initState();
  }

  Widget buildImageBox(String nama, String imagePath, int color) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: 350,
      height: 90,
      decoration: BoxDecoration(
        color: Color(color),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 40, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              nama,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0XFFFFFFFF)),
            ),
            Image.asset(
              imagePath,
              width: 100,
              height: 100,
            )
          ],
        ),
      ),
    );
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
                            builder: (context) => const Home()),
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
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top:200),
                child: Image.asset('assets/background cara pengajuan.png')),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CaraPengajuanSantunan()),
                      );
                    },
                    child: buildImageBox("Cara Pengajuan \nSantunan",
                        "assets/simbol cara pengajuan santunan.png", 0XFFE6AE06),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CaraPengajuanBPJS()),
                      );
                    },
                    child: buildImageBox("Cara Pengaduan \nBPJS ",
                        "assets/simbol cara pengajuan BPJS.png", 0XFF26267E),
                  )
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
