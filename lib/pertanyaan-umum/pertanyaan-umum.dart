import 'package:etuntas/home.dart';
import 'package:flutter/material.dart';

class PertanyaanUmum extends StatefulWidget {
  const PertanyaanUmum({super.key});

  @override
  State<PertanyaanUmum> createState() => _PertanyaanUmumState();
}

class _PertanyaanUmumState extends State<PertanyaanUmum> {
  @override
  void initState() {
    super.initState();
  }

  Map<String, bool> _expandedStatus = {};

  Widget buildImageBox(String title, String content) {
    bool isExpanded = _expandedStatus[title] ?? false; 

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedStatus[title] =
                    !isExpanded; 
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: MediaQuery.of(context).size.width * 0.88,
              height: MediaQuery.of(context).size.height * 0.09,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 5, bottom: 10),
              width: MediaQuery.of(context).size.width * 0.88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                content,
                style: const TextStyle(fontSize: 14),
              ),
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
              margin: const EdgeInsets.only(
                  top: 60, left: 20, right: 20, bottom: 10),
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
                  const SizedBox(width: 20),
                  const Text(
                    "Pertanyaan Umum",
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
          Stack(
            children: [
              Container(
                  margin: const EdgeInsets.only(top: 200),
                  child: Image.asset('assets/background pertanyaan.png')),
              Column(
                children: [
                  buildImageBox('Pertanyaan Pertama', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt'),
                  buildImageBox('Pertanyaan Kedua',
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt'),
                  buildImageBox('Pertanyaan Ketiga',
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt')
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
