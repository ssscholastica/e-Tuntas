import 'package:etuntas/navbar.dart';
import 'package:etuntas/persyaratan/persyaratan.dart';
import 'package:etuntas/rekening/addBank.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  final LinearGradient _gradient = const LinearGradient(
      colors: <Color>[Color(0xFF26267E), Color(0xFF2F2F9D), Color(0xFF6F6FB9)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight);

  Widget buildImageBox(String imagePath, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEDEFF3),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Image.asset(
            imagePath,
            width: 28,
            height: 28.566787719726562,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (Rect rect) {
              return _gradient.createShader(rect);
            },
            child: const Center(
              child: Text(
                "E-Tuntas",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/profile.png",
                      height: 35,
                      width: 35,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: const Text(
                    "Sri Indah",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const Spacer(),
                Image.asset("assets/notifikasi.png", height: 100)
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 30),
            child: const Text(
              "Informasi",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              children: [
                buildImageBox("assets/cara pengajuan.png", "Cara \nPengajuan"),
                const SizedBox(width: 35),
                InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Persyaratan()),
                      );
                    },
                    child: buildImageBox(
                        "assets/persyaratan.png", "Persyaratan \n")),
                const SizedBox(width: 35),
                buildImageBox("assets/faq.png", "Pertanyaan \nUmum / FAQ"),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.only(left: 30),
            child: const Text(
              "Pengajuan",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildImageBox(
                  "assets/pengajuan santunan.png", "Pengajuan \nSantunan"),
              buildImageBox("assets/pengajuan bpjs.png", "Pengaduan \nBPJS"),
              buildImageBox(
                  "assets/cek status pengajuan.png", "Cek Status \nPengajuan"),
              InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => addBank()),
                    );
                  },
                  child: buildImageBox(
                      "assets/rekening bank.png", "Rekening \nBank")),
            ],
          ),
        ],
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
