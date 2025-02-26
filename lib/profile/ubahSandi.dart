import 'package:etuntas/navbar.dart';
import 'package:etuntas/profile/profile.dart';
import 'package:etuntas/profile/ubahBerhasil.dart';
import 'package:flutter/material.dart';

class UbahSandi extends StatefulWidget {
  const UbahSandi({super.key});

  @override
  State<UbahSandi> createState() => _UbahSandiState();
}

class _UbahSandiState extends State<UbahSandi> {
  @override
  void initState() {
    super.initState();
  }
  
  final Map<int, bool> _obscureTextMap = {
    0: true,
    1: true,
    2: true,
  };

  Widget buildJudul(String judul, String initialValue, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(top: 20, left: 20),
          child: Text(
            judul,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0XFF000000),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
          child: SizedBox(
            height: 50,
            child: TextFormField(
              initialValue: initialValue,
              textAlign: TextAlign.left,
              obscureText: _obscureTextMap[index]!,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureTextMap[index]!
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureTextMap[index] = !_obscureTextMap[index]!;
                    });
                  },
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 80, left: 20, right: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Profile()),
                      );
                    },
                    child: Image.asset(
                      'assets/simbol back.png',
                      width: 28,
                      height: 28,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Ganti Kata Sandi",
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
            Container(
              alignment: Alignment.bottomLeft,
              margin: const EdgeInsets.only(top: 30, left: 20),
              child: const Text(
                'Informasi Data Pendaftar',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0XFF000000),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            buildJudul('Kata Sandi Sekarang', 'Sri Indah', 0),
            buildJudul("Kata Sandi Baru", 'sriindah@gmail.com', 1),
            buildJudul("Ulang Kata Sandi Baru", "81234567891", 2),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UbahBerhasil()));
              },
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 160, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: const Color(0xFF2F2F9D)),
              child: const Text("Simpan",
                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
