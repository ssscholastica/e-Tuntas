import 'package:etuntas/home.dart'; // Import halaman Home
import 'package:etuntas/pengajuan-santunan/pengajuanSantunan.dart';
import 'package:flutter/material.dart';

class alurPengajuan2 extends StatelessWidget {
  final String namaPTPN;

  alurPengajuan2({required this.namaPTPN, super.key});

  final List<Map<String, dynamic>> lokasiList = [
    {"text": "Kantor Pusat", "image": "assets/proses-pengajuan1.png"},
    {"text": "Pabrik Gula (PG)", "image": "assets/proses-pengajuan2.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                          builder: (context) => const Home(),
                        ),
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
                    "Pengajuan Santunan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text(
              "Lokasi - $namaPTPN",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: lokasiList.length,
              itemBuilder: (context, index) {
                final item = lokasiList[index];
                return Center(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
                    child: ListTile(
                      title: Text(item["text"]),
                      leading:
                          Image.asset(item["image"], width: 30, height: 30),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PengajuanSantunan(
                              namaPTPN: namaPTPN,
                              lokasiList: item["text"],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
