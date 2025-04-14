import 'package:flutter/material.dart';

import '/admin/admin-BPJSform.dart';

class TrackBPJS extends StatefulWidget {
  const TrackBPJS({Key? key}) : super(key: key);

  @override
  State<TrackBPJS> createState() => _TrackBPJSState();
}

class _TrackBPJSState extends State<TrackBPJS> {
  bool showFilterDropdown = false;
  bool isFilterApplied = false;
  String searchQuery = "";
  String selectedFilterType = "";

final List<Widget> trackBPJSPages = List.generate(
  5,
  (index) => Scaffold(
    appBar: AppBar(
      title: Text("Detail Pengaduan BPJS ${index + 1}"),
      backgroundColor: Colors.blue,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: formBPJS(pageIndex: index),
    ),
  ),
);

  final List<Map<String, dynamic>> trackBPJSList = [
    {
      "image": "assets/images/id_card.png",
      "text": "Nomor BPJS: 0001234567890\nKategori: Kesehatan",
      "id": "0001234567890",
      "category": "Kesehatan",
      "date": DateTime(2023, 5, 15),
    },
    {
      "image": "assets/images/family_card.png",
      "text": "Nomor NIK: 3578062209990002\nKategori: Ketenagakerjaan",
      "id": "3578062209990002",
      "category": "Ketenagakerjaan",
      "date": DateTime(2024, 1, 10),
    },
    {
      "image": "assets/images/retirement.png",
      "text": "Nomor BPJS: 0009876543210\nKategori: Pensiun",
      "id": "0009876543210",
      "category": "Pensiun",
      "date": DateTime(2023, 11, 20),
    },
    {
      "image": "assets/images/health_card.png",
      "text": "Nomor NIK: 3578064506880001\nKategori: Kesehatan",
      "id": "3578064506880001",
      "category": "Kesehatan",
      "date": DateTime(2024, 2, 5),
    },
    {
      "image": "assets/images/employment.png",
      "text": "Nomor BPJS: 0005678901234\nKategori: Ketenagakerjaan",
      "id": "0005678901234",
      "category": "Ketenagakerjaan",
      "date": DateTime(2023, 8, 12),
    },
  ];

  List<Map<String, dynamic>> getFilteredList() {
    List<Map<String, dynamic>> result = List.from(trackBPJSList);
    if (searchQuery.isNotEmpty) {
      result = result
          .where((item) => item["text"]
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }
    if (selectedFilterType == "kategori") {}
    if (selectedFilterType == "tanggal") {}
    return result;
  }

  void toggleFilterDropdown() {
    setState(() {
      showFilterDropdown = !showFilterDropdown;
    });
  }

  void applyFilter() {
    setState(() {
      isFilterApplied = selectedFilterType.isNotEmpty;
      showFilterDropdown = false;
    });
  }

  void resetFilter() {
    setState(() {
      selectedFilterType = "";
      isFilterApplied = false;
    });
  }

  void _selectDateFilter() {
    setState(() {
      selectedFilterType = "tanggal";
    });
  }

  void _selectCategoryFilter() {
    setState(() {
      selectedFilterType = "kategori";
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = getFilteredList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "TrackBPJS",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 70),
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          "Tidak ada hasil yang ditemukan",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        if (isFilterApplied || searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                searchQuery = "";
                                resetFilter();
                              });
                            },
                            child: const Text("Reset Pencarian"),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 15),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => trackBPJSPages[
                                      trackBPJSList.indexOf(item)]),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  item["image"],
                                  width: 50,
                                  height: 50,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.credit_card,
                                          size: 50, color: Colors.blue[300]),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item["text"],
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Cari...',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 5),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: toggleFilterDropdown,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            color: isFilterApplied ? Colors.blue : Colors.black,
                          ),
                          if (isFilterApplied)
                            GestureDetector(
                              onTap: () {
                                resetFilter();
                              },
                              behavior: HitTestBehavior
                                  .opaque,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.close,
                                    size: 16, color: Colors.blue),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showFilterDropdown)
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Filter berdasarkan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _selectDateFilter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 18,
                                color: selectedFilterType == "tanggal"
                                    ? Colors.blue
                                    : Colors.grey.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Tanggal',
                              style: TextStyle(
                                color: selectedFilterType == "tanggal"
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                            ),
                            const Spacer(),
                            if (selectedFilterType == "tanggal")
                              const Icon(Icons.check,
                                  size: 18, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _selectCategoryFilter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.category,
                                size: 18,
                                color: selectedFilterType == "kategori"
                                    ? Colors.blue
                                    : Colors.grey.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Kategori',
                              style: TextStyle(
                                color: selectedFilterType == "kategori"
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                            ),
                            const Spacer(),
                            if (selectedFilterType == "kategori")
                              const Icon(Icons.check,
                                  size: 18, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: applyFilter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}