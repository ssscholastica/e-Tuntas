import 'package:etuntas/navbar.dart';
import 'package:etuntas/profile/profile.dart';
import 'package:flutter/material.dart';

class ProfileBersangkutan extends StatefulWidget {
  const ProfileBersangkutan({super.key});

  @override
  State<ProfileBersangkutan> createState() => _ProfileBersangkutanState();
}

class _ProfileBersangkutanState extends State<ProfileBersangkutan> {
  @override
  void initState() {
    super.initState();
  }

  Widget buildTemplate(String judul, String isiJudul) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            judul,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0XFF8C8C8C),
                fontWeight: FontWeight.w400),
          ),
          Text(
            isiJudul,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0XFF000000),
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget buildTemplateBawah(
      String imagePath, String namaImage, String? imagePathKanan) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 24,
            height: 24,
          ),
          const SizedBox(
            width: 20,
          ),
          Text(
            namaImage,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0XFF000000),
                fontWeight: FontWeight.w400),
          ),
          const Spacer(),
          if (imagePathKanan != null)
            Image.asset(
              imagePathKanan,
              width: 24,
              height: 24,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 10),
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
                    "Profile Bersangkutan",
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
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 510,
            child: Stack(
              children: [
                Image.asset(
                  "assets/background data bersangkutan.png",
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 80,
                  left: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 20, left: 20, right: 20),
                          child: Center(
                            child: Text(
                              "Informasi Data Bersangkutan",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0XFF000000),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            buildTemplate('Nama Lengkap', "Suyitno"),
                            buildTemplate('Unit Terakhir Dinas', "Kebun Banyuwangi"),
                            buildTemplate('NIK', "3578012350010001"),
                            buildTemplate('Nomor Pensiunan', "342518910019910"),
                            buildTemplate('Status', "Istri"),
                            const SizedBox(
                              height: 20,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
