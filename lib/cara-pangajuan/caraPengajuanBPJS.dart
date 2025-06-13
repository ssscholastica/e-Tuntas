import 'package:etuntas/cara-pangajuan/caraPengajuan.dart';
import 'package:flutter/material.dart';

class CaraPengajuanBPJS extends StatefulWidget {
  const CaraPengajuanBPJS({super.key});

  @override
  State<CaraPengajuanBPJS> createState() => _CaraPengajuanBPJSState();
}

class _CaraPengajuanBPJSState extends State<CaraPengajuanBPJS> {
  @override
  void initState() {
    super.initState();
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
                    const SizedBox(width: 10),
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
                Center(
                    child: Image.asset('assets/background cara pengajuan.png')),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Alur Pengajuan BPJS",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Center(child: Image.asset('assets/alur pengajuan BPJS.png', width: 225,)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
