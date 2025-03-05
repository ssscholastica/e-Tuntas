import 'package:flutter/material.dart';
import 'package:etuntas/home.dart';
import 'package:etuntas/profile/editBerhasil.dart';

class TrackingAwal extends StatefulWidget {
  const TrackingAwal({super.key});

  @override
  State<TrackingAwal> createState() => _TrackingAwalState();
}

class _TrackingAwalState extends State<TrackingAwal> {
  final TextEditingController _controller = TextEditingController();
  String? trackingInfo;
  bool isTrackingSuccess = false;

  void _cekTrackingData() {
    String nomorPendaftaran = _controller.text.trim();

    if (nomorPendaftaran.isEmpty) {
      _showFailureDialog("Nomor Pendaftaran/NIK tidak boleh kosong!");
      return;
    }

    // Simulasi pengecekan tracking data
    setState(() {
      if (nomorPendaftaran == "123456") {
        isTrackingSuccess = true;
        trackingInfo =
            "Pengajuan dengan nomor $nomorPendaftaran sedang diproses.";
      } else {
        isTrackingSuccess = false;
        trackingInfo = null;
        _showFailureDialog("Nomor Pendaftaran/NIK tidak ditemukan!");
      }
    });
  }

  void _showFailureDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Gagal"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
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
                        MaterialPageRoute(builder: (context) => const Home()),
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
                    "Cek Status Pengajuan Santunan",
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
                'Silahkan masukkan Nomor Pendaftaran/NIK',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0XFF000000),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Nomor Pendaftaran/NIK',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _cekTrackingData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: const Color(0xFF2F2F9D),
                  ),
                  child: const Text(
                    "Cek/Tracking Data",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Informasi Tracking Data
            if (trackingInfo != null)
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color:
                      isTrackingSuccess ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isTrackingSuccess ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  trackingInfo!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        isTrackingSuccess ? Colors.green[900] : Colors.red[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
