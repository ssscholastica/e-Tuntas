import 'package:etuntas/pengajuan-santunan/pengajuanSantunan1.dart';
import 'package:etuntas/persyaratan/persyaratan1.dart';
import 'package:etuntas/persyaratan/persyaratan2.dart';
import 'package:etuntas/persyaratan/persyaratan3.dart';
import 'package:etuntas/persyaratan/persyaratan4.dart';
import 'package:etuntas/persyaratan/persyaratan5.dart';
import 'package:flutter/material.dart';

class PengajuanSantunan extends StatelessWidget {
  PengajuanSantunan({super.key});

  final List<Widget> pengajuanPages = [
    PengajuanSantunan1(),
    Persyaratan2(),
    Persyaratan3(),
    Persyaratan4(),
    Persyaratan5(),
  ];

  final List<Map<String, dynamic>> pengajuanList = [
    {
      "image": "assets/proses-pengajuan1.png",
      "text":
          "Yang Meninggal Pensiunan PTPN XI Kantor Pusat dan Istri Masih Hidup",
    },
    {
      "image": "assets/proses-pengajuan2.png",
      "text":
          "Yang Meninggal Pensiunan PTPN XI Kantor Pusat dan Istri Sudah Meninggal, Dalam KK Ada 1 Anak",
      "color": const Color(0xFFD0D0F7),
    },
    {
      "image": "assets/proses-pengajuan3.png",
      "text":
          "Yang Meninggal Pensiunan PTPN XI Kantor Pusat dan Istri Sudah Meninggal, Dalam KK Ada Beberapa Anak",
      "color": const Color(0xFFCFE3FF),
    },
    {
      "image": "assets/proses-pengajuan4.png",
      "text":
          "Yang Meninggal Pensiunan PTPN XI Kantor Pusat dan Istri Sudah Meninggal, Dalam KK Hanya Pensiunan Sendiri (Tidak Ada Anak Karena Sudah Pecah KK)",
      "color": const Color(0xFFFFF1C5),
    },
    {
      "image": "assets/proses-pengajuan5.png",
      "text":
          "Yang Meninggal Pensiunan PTPN XI Kantor Pusat dan Istri Sudah Meninggal, Dalam KK Hanya Tercantum Pensiunan Janda Tanpa Batih (Tidak Ada Anak Karena Sudah Pecah KK)",
      "color": const Color(0xFFFFD9E1),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Proses Pengajuan Santunan",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 500,
            height: 50,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0XFFF8D7DA),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: const Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Image.asset(
                  'assets/icon pilih kategori.png',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'Pilih Kategori Terlebih Dahulu',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 5),
            child: Text(
              "Kategori",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: ListView.builder(
                itemCount: pengajuanList.length,
                itemBuilder: (context, index) {
                  final item = pengajuanList[index];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => pengajuanPages[index]),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(item["image"], width: 30, height: 30),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item["text"],
                                textAlign: TextAlign.justify,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Icon(Icons.arrow_forward_ios, size: 18),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
