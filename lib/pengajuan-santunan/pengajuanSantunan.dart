import 'package:etuntas/pengajuan-santunan/pengajuanSantunan1.dart';
import 'package:etuntas/pengajuan-santunan/pengajuanSantunan2.dart';
import 'package:etuntas/pengajuan-santunan/pengajuanSantunan3.dart';
import 'package:etuntas/pengajuan-santunan/pengajuanSantunan4.dart';
import 'package:etuntas/pengajuan-santunan/pengajuanSantunan5.dart';
import 'package:flutter/material.dart';

class PengajuanSantunan extends StatelessWidget {
  final String namaPTPN;
  final String lokasiList;

  PengajuanSantunan(
      {required this.namaPTPN, required this.lokasiList, super.key});

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
    },
    {
      "image": "assets/proses-pengajuan3.png",
      "text":
          "Yang Meninggal Pensiunan PTPN XI Kantor Pusat dan Istri Sudah Meninggal, Dalam KK Ada Beberapa Anak",
    },
    {
      "image": "assets/proses-pengajuan4.png",
      "text":
          "Yang Meninggal Pensiunan PTPN XI Kantor Pusat dan Istri Sudah Meninggal, Dalam KK Hanya Pensiunan Sendiri (Tidak Ada Anak Karena Sudah Pecah KK)",
    },
    {
      "image": "assets/proses-pengajuan5.png",
      "text":
          "Yang Meninggal Pensiunan PTPN XI Kantor Pusat dan Istri Sudah Meninggal, Dalam KK Hanya Tercantum Pensiunan Janda Tanpa Batih (Tidak Ada Anak Karena Sudah Pecah KK)",
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
            width: double.infinity,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                const SizedBox(width: 10),
                Image.asset('assets/icon pilih kategori.png',
                    width: 20, height: 20),
                const SizedBox(width: 10),
                const Text(
                  'Pilih Kategori Terlebih Dahulu',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 5, top: 5),
            child: Text(
              "Kategori ($namaPTPN - $lokasiList)",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        Widget pageToNavigate;

                        switch (index) {
                          case 0:
                            pageToNavigate = PengajuanSantunan1(
                                namaPTPN: namaPTPN, lokasiList: lokasiList);
                            break;
                          case 1:
                            pageToNavigate = PengajuanSantunan2(
                                namaPTPN: namaPTPN, lokasiList: lokasiList);
                            break;
                          case 2:
                            pageToNavigate = PengajuanSantunan3(
                                namaPTPN: namaPTPN, lokasiList: lokasiList);
                            break;
                          case 3:
                            pageToNavigate = PengajuanSantunan4(
                                namaPTPN: namaPTPN, lokasiList: lokasiList);
                            break;
                          default:
                            pageToNavigate = PengajuanSantunan5(
                                namaPTPN: namaPTPN, lokasiList: lokasiList);
                            break;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => pageToNavigate,
                          ),
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
