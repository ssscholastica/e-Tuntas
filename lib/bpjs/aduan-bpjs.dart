import 'package:flutter/material.dart';

class aduanBPJS extends StatelessWidget {
  const aduanBPJS({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Custom Header
            Container(
              margin: const EdgeInsets.only(top: 60, left: 20, right: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/simbol back.png',
                      width: 28,
                      height: 28,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Aduan & Tracking BPJS",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0XFF000000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const TabBar(
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "Aduan BPJS"),
                Tab(text: "Cek Aduan BPJS"),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  AduanBPJSPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AduanBPJSPage extends StatelessWidget {
  const AduanBPJSPage({super.key});

  final List<Map<String, dynamic>> aduanList = const [
    {
      "icon": Icons.credit_card_off,
      "title": "BPJS Non Aktif",
      "color": Colors.red
    },
    {
      "icon": Icons.local_hospital,
      "title": "Pindah Faskes",
      "color": Colors.green
    },
    {
      "icon": Icons.report_problem,
      "title": "Klaim BPJS Bermasalah",
      "color": Colors.blue
    },
    {"icon": Icons.more_horiz, "title": "Lain-Lain", "color": Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left:30, top: 15, bottom: 10),
          child: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Pilih Perihal Aduan Terlebih Dahulu",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.only(left: 30),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
                      "Perihal Aduan",
                      style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
                    ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: aduanList.length,
            itemBuilder: (context, index) {
              final item = aduanList[index];
              return Container (
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Icon(item["icon"], color: item["color"]),
                title: Text(item["title"]),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ));
            },
          ),
        ),
      ],
    );
  }
}
