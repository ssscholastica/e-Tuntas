import 'package:etuntas/home.dart';
import 'package:flutter/material.dart';

class DaftarBerhasil extends StatefulWidget {
  const DaftarBerhasil({super.key});

  @override
  State<DaftarBerhasil> createState() => _DaftarBerhasilState();
}

class _DaftarBerhasilState extends State<DaftarBerhasil> {
  @override
  void initState() {
    super.initState();
  }

  final LinearGradient _gradient = const LinearGradient(
      colors: <Color>[Color(0xFF26267E), Color(0xFF2F2F9D), Color(0xFF6F6FB9)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect rect) {
                      return _gradient.createShader(rect);
                    },
                    child: const Center(
                      child: Text(
                        "E-Tuntas",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                      alignment: Alignment.bottomCenter,
                      margin: const EdgeInsets.only(top: 50),
                      child: Image.asset('assets/edit berhasil.png',
                          width: 300, height: 300)),
                  const Center(
                      child: Text(
                    'Berhasil Melakukan Pendaftaran!',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0XFF1E1B15)),
                  )),
                  const SizedBox(height: 10),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                          'Silakan periksa email Anda untuk mendapatkan username dan password akun. Cek folder spam jika Anda tidak menemukan email aktivasi dari kami.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0XFFA3A3A3),
                          ),
                          textAlign: TextAlign.center),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const Home()));
                      },
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.32,
                            vertical: MediaQuery.of(context).size.height * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color(0xFF2F2F9D)),
                      child: const Text("Lanjutkan",
                          style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
