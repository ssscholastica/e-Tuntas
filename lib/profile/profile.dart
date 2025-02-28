import 'package:etuntas/profile/editProfile.dart';
import 'package:etuntas/navbar.dart';
import 'package:etuntas/profile/profileBersangkutan.dart';
import 'package:etuntas/profile/ubahSandi.dart';
import 'package:etuntas/splashScreen.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
                margin: const EdgeInsets.only(top: 80),
                child: const Text(
                  "Akun Pengguna",
                  style: TextStyle(
                      fontSize: 18,
                      color: Color(0XFF000000),
                      fontWeight: FontWeight.bold),
                )),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 510,
            child: Stack(
              children: [
                Image.asset(
                  "assets/background profile.png",
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
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 40, left: 20, right: 20),
                          child: Row(
                            children: [
                              const Text(
                                "Profile",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0XFF000000),
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const EditProfile()),
                                  );
                                },
                                child: const Text(
                                  "Edit",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0XFF2F2F9D),
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            buildTemplate('Nama Lengkap', "Sri Indah"),
                            buildTemplate('Email', "sriindah@gmail.com"),
                            buildTemplate('Nomor HP', "+6281234567891"),
                            buildTemplate('Tanggal Lahir', "2 Februari 2002"),
                            buildTemplate('Alamat', "Jl. Merak 1"),
                            const SizedBox(
                              height: 20,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage("assets/profile.png"),
                      ),
                    ))
              ],
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(top: 15, left: 20, bottom: 20),
            child: const Text(
              'Lainnya',
              style: TextStyle(
                  fontSize: 16,
                  color: Color(0XFF000000),
                  fontWeight: FontWeight.w600),
            ),
          ),
          Center(
            child: Container(
              height: 150,
              width: 330,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UbahSandi()),
                        );
                      },
                      child: buildTemplateBawah('assets/logo sandi.png',
                          'Ganti Kata Sandi', 'assets/simbol next.png'),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileBersangkutan()),
                        );
                      },
                      child: buildTemplateBawah(
                          'assets/logo informasi.png',
                          'Informasi Data Bersangkutan',
                          'assets/simbol next.png'),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SplashScreen()),
                          );
                        },
                        child: buildTemplateBawah(
                            'assets/logo logout.png', 'Keluar', null))
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
