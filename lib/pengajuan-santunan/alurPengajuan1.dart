import 'package:etuntas/home.dart';
import 'package:etuntas/pengajuan-santunan/alurPengajuan2.dart';
import 'package:flutter/material.dart';

class alurPengajuan1 extends StatefulWidget {
  const alurPengajuan1({super.key});

  @override
  State<alurPengajuan1> createState() => _alurPengajuan1State();
}

class _alurPengajuan1State extends State<alurPengajuan1> {
  final List<Map<String, String>> ptpnList = [
    {
      "nama": "PTPN 10",
      "image": "assets/simbol cara pengajuan santunan.png",
      "color": "0XFFE6AE06"
    },
    {
      "nama": "PTPN 11",
      "image": "assets/simbol cara pengajuan BPJS.png",
      "color": "0XFF26267E"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 60, left: 20, right: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Home()));
                    },
                    child: Image.asset('assets/simbol back.png',
                        width: 28, height: 28),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Pengajuan Santunan",
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0XFF000000),
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.02,
            ),
            child: Column(
              children: List.generate(ptpnList.length, (index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            alurPengajuan2(namaPTPN: ptpnList[index]["nama"]!),
                      ),
                    );
                  },
                  child: buildImageBox(
                    ptpnList[index]["nama"]!,
                    ptpnList[index]["image"]!,
                    int.parse(
                        ptpnList[index]["color"]!.replaceFirst("0X", "0x")),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImageBox(String nama, String imagePath, int color) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.1,
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
            Image.asset(imagePath, width: 100, height: 100),
          ],
        ),
      ),
    );
  }
}
