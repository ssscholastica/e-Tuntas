import 'package:etuntas/home.dart';
import 'package:etuntas/profile/profile.dart';
import 'package:flutter/material.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 79,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0XFF2F2F9D),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Home()),
                      );
                    },
                    icon: const Icon(
                      Icons.home_outlined,
                      color: Color(0xFFFFFFFF),
                      size: 24,
                    ),
                  ),
                  const Text("Home",
                      style: TextStyle(fontSize: 14, color: Color(0xFFFFFFFF)))
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Profile()),
                    );
                  },
                  icon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFFFFFFFF),
                    size: 24,
                  ),
                ),
                const Text("Profile",
                    style: TextStyle(fontSize: 14, color: Color(0xFFFFFFFF)))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
