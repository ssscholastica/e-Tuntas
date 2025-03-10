import 'package:dropdown_search/dropdown_search.dart';
import 'package:etuntas/login-signup/daftarBerhasil.dart';
import 'package:etuntas/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Pendaftaran extends StatefulWidget {
  @override
  Pendaftaran({super.key});

  @override
  State<Pendaftaran> createState() => _PendaftaranState();
}

class _PendaftaranState extends State<Pendaftaran> {
  final Map<String, TextEditingController> controllers = {
    "Nama Pendaftar": TextEditingController(),
    "Email": TextEditingController(),
    "Alamat": TextEditingController(),
    "Tanggal Lahir": TextEditingController(),
    "Nomor HP": TextEditingController(),
    "instansi": TextEditingController(),
    "jabatan": TextEditingController(),
  };

  Future<void> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      setState(() {
        controllers["Tanggal Lahir"]?.text = formattedDate;
      });
    }
  }

  final List<String> instansiList = [
    "Kantor Pusat eks N10",
"PG Toelangan",
"PG Watoetoelis",
"PG Kremboong",
"PG Gempolkrep",
"PG Djombang Baru",
"PG Tjoekir",
"PG Lestari",
"PG Meritjan",
"PG Pesantren Baru",
"PG Ngadiredjo",
"PG Modjopanggoong",
"Kebun Kertosari",
"Kebun Adjong Gayasan",
"Kebun Klaten",
"PG Sudhono",
"PG Purwodadie",
"PG Redjosari",
"PG Pagottan",
"PG Kanigoro",
"Unit Usaha Strategis",
"PG Kedawung",
"PG Wonolangan",
"PG Gending",
"PG Pajarakan",
"PG Djatiroto",
"PG Semboro",
"PG Wringinanom",
"PG Olean",
"PG Pandji",
"PG Assembagus",
"PG Pradjekan",
"PK Rosella Baru",
"Kantor Pusat EKS N11",
"Pasa dan Hilirisasi Usaha",
  ];
  String? selectedInstansi;

  final List<String> statusKeluargaList = [
    "Istri",
    "Suami",
    "Anak",
    "Kakak",
    "Adik"
  ];
  String? selectedStatusKeluarga;

  Widget buildTextField(String key, String label, String hint,
      {TextInputType? keyboardType, Widget? prefix, bool isDate = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 3),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: TextField(
            controller: controllers[key],
            keyboardType: keyboardType,
            readOnly: isDate,
            onTap: isDate ? () => selectDate(context) : null,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefix,
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              suffixIcon: isDate ? const Icon(Icons.calendar_today) : null,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in controllers.values) {
      controller.dispose();
    }
  }

  void handleSubmit() {
    print("Nama: ${controllers["Nama"]?.text}");
    print("Email: ${controllers["Email"]?.text}");
    print("Alamat: ${controllers["Alamat"]?.text}");
    print("Tanggal lahir: ${controllers["Tanggal lahir"]?.text}");
    print("Nomor HP: ${controllers["Nomor HP"]?.text}");
    print("PG/Unit Terakhir Dinas: $selectedInstansi");
    print("NIK: ${controllers["NIK"]?.text}");
    print("Nomor Pensiunan: ${controllers["Nomor Pensiunan"]?.text}");
    print("Status Hubungan Keluarga: $selectedStatusKeluarga");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text(
            "Pendaftaran",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 16.0),
                  child: Text(
                      "Lengkapi form pendaftaran berikut untuk masuk kedalam sistem",
                      style: TextStyle(fontSize: 16, color: Colors.black))),
              const SizedBox(height: 10),
              Divider(color: Colors.grey[300], thickness: 8, height: 20),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Data Penerima",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Divider(color: Colors.grey[300], thickness: 3),
                    buildTextField("Nama", "Nama Pendaftar", "Nama Penerima"),
                    buildTextField("Email", "Email", "example@gmail.com"),
                    buildTextField("Alamat", "Alamat", "Alamat Penerima"),
                    buildTextField(
                        "Tanggal Lahir", "Tanggal Lahir", "Pilih tanggal lahir",
                        isDate: true),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Nomor HP", style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 5),
                        TextField(
                          controller: controllers["Nomor HP"],
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: "Nomor HP Penerima",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            prefixIcon: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              child: Text(
                                "+62",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Divider(color: Colors.grey[300], thickness: 8, height: 20),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Data Bersangkutan",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.grey, thickness: 3, height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("PG / Unit Terakhir Dinas",
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 5),
                        DropdownSearch<String>(
                          items: instansiList,
                          selectedItem: selectedInstansi,
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            fit: FlexFit.loose,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: "Search",
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              hintText: "PG/Unit Terakhir",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedInstansi = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                    buildTextField("No Pensiun", "Nomor Pensiunan",
                        "12 digit nomor pensiunan"),
                    buildTextField("NIK", "NIK", "12 digit NIK"),
                    buildTextField(
                        "Nama Bersangkutan", "Nama", "Nama bersangkutan"),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Status Hubungan Keluarga",
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 5),
                        DropdownButtonFormField<String>(
                          value: selectedStatusKeluarga,
                          decoration: const InputDecoration(
                            hintText: "Status Hubungan",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                            isDense: true,
                          ),
                          items: statusKeluargaList.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedStatusKeluarga = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F2F9D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return Center(
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                            ),
                          ),
                        );
                      },
                    );
                    Future.delayed(const Duration(seconds: 2), () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const DaftarBerhasil()),
                      );
                    });
                  },
                  child: const Text(
                    "Daftar",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: const Color(0xFF2F2F9D),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //     ),
                    //     onPressed: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => const DaftarBerhasil()),
                    //       );
                    //     },
                    //     child: const Text(
                    //       "Daftar",
                    //       style: TextStyle(fontSize: 16, color: Colors.white),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
