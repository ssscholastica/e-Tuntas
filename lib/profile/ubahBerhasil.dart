import 'package:etuntas/profile/profile.dart';
import 'package:flutter/material.dart';

class UbahBerhasil extends StatefulWidget {
  const UbahBerhasil({super.key});

  @override
  State<UbahBerhasil> createState() => _UbahBerhasilState();
}

class _UbahBerhasilState extends State<UbahBerhasil> {
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
        body: Container(
          margin: const EdgeInsets.all(20),
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
                  margin: const EdgeInsets.only(top: 100),
                  child: Image.asset('assets/edit berhasil.png',
                      width: 300, height: 300)),
              const Center(
                  child: Text(
                'Kata Sandi Berhasil Diperbarui!',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0XFF1E1B15)),
              )),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Kata Sandi Anda Berhasil Diperbarui',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0XFFA3A3A3),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Profile()));
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
                  child: const Text("Kembali",
                      style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16)),
                ),
              ),
            ],
          ),
        ));
  }
}
