import 'package:etuntas/pengajuan-santunan/pengajuanSantunan.dart';
import 'package:etuntas/profile/profile.dart';
import 'package:flutter/material.dart';

class SuccesUpload extends StatefulWidget {
  const SuccesUpload({super.key});

  @override
  State<SuccesUpload> createState() => _SuccessUploadState();
}

class _SuccessUploadState extends State<SuccesUpload> {
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
                'Pengajuan Santunan Berhasil Dikirim!',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0XFF1E1B15)),
              )),
              const SizedBox(height: 10),
              const Center(
                  child: Text(
                'Nomor Pendaftaran Anda :  00110122024',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0XFF1E1B15)),
              )),
              const SizedBox(height: 10),
              const Text(
                'Silakan periksa email Anda untuk melihat ulang \nnomor pendaftaran.\nCek folder spam jika Anda tidak menemukan \nemail dari kami.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0XFFA3A3A3),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PengajuanSantunan()));
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 145, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: const Color(0xFF2F2F9D)),
                child: const Text("Lanjutkan",
                    style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16)),
              ),
            ],
          ),
        ));
  }
}
