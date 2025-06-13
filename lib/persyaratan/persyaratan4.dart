import 'package:flutter/material.dart';

class Persyaratan4 extends StatelessWidget {
  Persyaratan4({super.key});

  final List<Map<String, dynamic>> persyaratanList = [
    {
      "text":"Yang Meninggal Pensiunan PTPN X atau XI Kantor Pusat dan Istri Sudah Meninggal, Dalam KK Hanya Pensiunan Sendiri (Tidak Ada Anak Karena Sudah Pecah KK",
      "color": const Color(0xFFCFE2FF),
    },
    {
      "text":"Syarat copy berkas untuk pengajuan bantuan kematian pensiunan kantor pusat PTPN XI :",
      "sub-text":"1. Surat Kematian \n2. Kartu Keluarga pensiunan \n3. Surat keterangan (dari kelurahan yang menerangkan identitas anak-anak pensiunan. \n4. Surat kuasa dari semua anak, anak mana yang ditunjuk untuk menerima bantuan.\n5. KTP pensiunan & semua anak. \n6. Buku Rekening anak yang ditunjuk untuk menerima bantuan \n7 Besar bantuan adalah 4 kali manfaat pensiun \n",
      "sub-text2": "Catatan",
      "sub-text3": "1. Berkas hanya diterima bila kondisi lengkap \n 2. Perkecualian yang sangat lanjut usia (misal kelahiran tahun 1930-an), dan dimungkinkan surat nikah hilang/rusak, berkas boleh diterima dengan pelapor menuliskan keterangan tambahan bahwa surat nikah rusak/hilang di copy Kartu Keluarga (KK).",
      "color" : Colors.white,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: -5,
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
              elevation: 5,
              color: item["color"],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["text"],
                      textAlign: TextAlign.justify,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    if (item.containsKey("sub-text"))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          item["sub-text"] ?? "",
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      if (item.containsKey("sub-text2"))
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          item["sub-text2"] ?? "",
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (item.containsKey("sub-text3"))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          item["sub-text3"] ?? "",
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}