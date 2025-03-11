import 'package:etuntas/persyaratan/persyaratan1.dart';
import 'package:etuntas/persyaratan/persyaratan2.dart';
import 'package:etuntas/persyaratan/persyaratan3.dart';
import 'package:etuntas/persyaratan/persyaratan4.dart';
import 'package:etuntas/persyaratan/persyaratan5.dart';
import 'package:flutter/material.dart';

class Persyaratan extends StatelessWidget {
  Persyaratan({super.key});

  final List<Widget> persyaratanPages = [
    Persyaratan1(),
    Persyaratan2(),
    Persyaratan3(),
    Persyaratan4(),
    Persyaratan5(),
  ];

  final List<Map<String, dynamic>> persyaratanList = [
    {
      "image": "assets/img1.png",
      "text":
          "Yang Meninggal Pensiunan PTPN X atau XI Kantor Pusat dan Istri Masih Hidup",
      "color": const Color(0xFFD1E7D1),
    },
    {
      "image": "assets/img2.png",
      "text":
          "Yang Meninggal Pensiunan PTPN X atau XI Kantor Pusat dan Istri Sudah Meninggal, Dalam KK Ada 1 Anak",
      "color": const Color(0xFFD0D0F7),
    },
    {
      "image": "assets/img3.png",
      "text":
          "Yang Meninggal Pensiunan PTPN X atau XI Kantor Pusat dan Istri Sudah Meninggal, Dalam KK Ada Beberapa Anak",
      "color": const Color(0xFFCFE3FF),
    },
    {
      "image": "assets/img4.png",
      "text":
          "Yang Meninggal Pensiunan PTPN X atau XI Kantor Pusat dan Istri Sudah Meninggal, Dalam KK Hanya Pensiunan Sendiri (Tidak Ada Anak Karena Sudah Pecah KK)",
      "color": const Color(0xFFFFF1C5),
    },
    {
      "image": "assets/img5.png",
      "text":
          "Yang Meninggal Pensiunan PTPN X atau XI Kantor Pusat dan Istri Sudah Meninggal, Dalam KK Hanya Tercantum Pensiunan Janda Tanpa Batih (Tidak Ada Anak Karena Sudah Pecah KK)",
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
          "Persyaratan",
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
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: ListView.builder(
          itemCount: persyaratanList.length,
          itemBuilder: (context, index) {
            final item = persyaratanList[index];
            return Card(
              color: item["color"],
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 15),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => persyaratanPages[index]),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(item["image"], width: 80, height: 80),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item["text"],
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
