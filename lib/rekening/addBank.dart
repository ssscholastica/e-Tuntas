
import 'package:etuntas/profile/profile.dart';
import 'package:flutter/material.dart';

class addBank extends StatefulWidget {
  const addBank({super.key});

  @override
  State<addBank> createState() => _addBankState();
}

class _addBankState extends State<addBank> {
  @override
  void initState() {
    super.initState();
  }

  Widget buildJudul(String judul, String hint) {
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
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                hintText: hint,
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

  Widget buildUploadDokumen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(top: 20, left: 20),
          child: const Text(
            "Upload Dokumen",
            style: TextStyle(
              fontSize: 14,
              color: Color(0XFF000000),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
          child: InkWell(
            onTap: () {
              // Tambahkan fungsi untuk memilih dan mengunggah dokumen
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  "Pilih Dokumen",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
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
                  // const Spacer(),
                  const Text(
                    "Tambah Rekening",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0XFF000000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            buildJudul("Nama Bank", 'Nama Bank'),
            buildJudul("Nomor Rekening", 'Nomor Rekening'),
            buildJudul("Nama Pemilik", "Nama Pemilik"),
            buildUploadDokumen(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
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
