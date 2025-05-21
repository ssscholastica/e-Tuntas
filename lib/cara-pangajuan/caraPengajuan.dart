import 'package:etuntas/cara-pangajuan/caraPengajuanBPJS.dart';
import 'package:etuntas/cara-pangajuan/caraPengajuanSantunan.dart';
import 'package:etuntas/home.dart';
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
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 60,
        maxHeight: 120,
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                nama,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0XFFFFFFFF)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Image.asset(
                imagePath,
                width: 100,
                height: 100,
              ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(
                    top: 60, left: 20, right: 20, bottom: 10),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Home()),
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Stack(
                children: [
                  Center(
                      child: Image.asset('assets/background cara pengajuan.png')),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CaraPengajuanSantunan()),
                          );
                        },
                        child: buildImageBox(
                            "Cara Pengajuan Santunan",
                            "assets/simbol cara pengajuan santunan.png",
                            0XFFE6AE06),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CaraPengajuanBPJS()),
                          );
                        },
                        child: buildImageBox("Cara Pengaduan BPJS ",
                            "assets/simbol cara pengajuan BPJS.png", 0XFF26267E),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
