import 'package:etuntas/home.dart';
import 'package:flutter/material.dart';

class SuccesUpload extends StatefulWidget {
  final String noPendaftaran;

  const SuccesUpload({Key? key, required this.noPendaftaran}) : super(key: key);

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
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect rect) {
                      return _gradient.createShader(rect);
                    },
                    child: const Text(
                      "E-Tuntas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 10),
                      child: Image.asset('assets/edit berhasil.png',
                          width: 300, height: 300)),
                  const Text(
                    'Pengajuan Santunan Berhasil Dikirim!',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0XFF1E1B15)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nomor Pendaftaran Anda: \n${widget.noPendaftaran}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0XFF1E1B15)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Silakan periksa email Anda untuk melihat ulang nomor pendaftaran. \nCek folder spam jika Anda tidak menemukan email dari kami.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0XFFA3A3A3),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 80),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Home()));
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
                        style:
                            TextStyle(color: Color(0xFFFFFFFF), fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
