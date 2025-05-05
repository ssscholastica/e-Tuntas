import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:etuntas/login-signup/daftarBerhasil.dart';
import 'package:etuntas/network/auth_services.dart';
import 'package:etuntas/network/globals.dart';
import 'package:etuntas/splashScreen.dart';
import 'package:etuntas/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pendaftaran extends StatefulWidget {
  @override
  const Pendaftaran({super.key});

  @override
  State<Pendaftaran> createState() => _PendaftaranState();
}

class _PendaftaranState extends State<Pendaftaran> {
  final Map<String, TextEditingController> controllers = {
    "Nama": TextEditingController(),
    "Email": TextEditingController(),
    "Alamat": TextEditingController(),
    "Tanggal Lahir": TextEditingController(),
    "Nomor HP": TextEditingController(),
    "PG Unit": TextEditingController(),
    "Nomor Pensiunan": TextEditingController(),
    "NIK": TextEditingController(),
    "Nama Bersangkutan": TextEditingController(),
    "Status": TextEditingController(),
  };

  bool isLoadingPensiunan = false;

  @override
  void initState() {
    super.initState();
    controllers["Nomor Pensiunan"]!.addListener(_fetchPensionerDetails);
  }

  Future<void> _fetchPensionerDetails() async {
    final noPensiunan = controllers["Nomor Pensiunan"]!.text;

    if (noPensiunan.length == 12) {
      setState(() {
        isLoadingPensiunan = true;
      });

      try {

        final response = await http.get(
          Uri.parse('${baseURL}pensiunan/$noPensiunan'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data != null && data.containsKey('nama_pensiunan')) {
            setState(() {
              controllers["Nama Bersangkutan"]!.text = data['nama_pensiunan'];
            });
          } else {
            _showErrorMessage('Data pensiunan tidak lengkap');
            controllers["Nama Bersangkutan"]!.clear();
          }
        } else if (response.statusCode == 404) {
          _showErrorMessage('Nomor Pensiunan tidak ditemukan');
          controllers["Nama Bersangkutan"]!.clear();
        } else {
          print("Error status code: ${response.statusCode}");
          print("Error response body: ${response.body}");
          _showErrorMessage('Gagal mengambil data pensiunan');
          controllers["Nama Bersangkutan"]!.clear();
        }
      } catch (e) {
        print("Error fetching pensioner details: $e");
        _showErrorMessage('Terjadi kesalahan koneksi');
        controllers["Nama Bersangkutan"]!.clear();
      } finally {
        setState(() {
          isLoadingPensiunan = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
    "Kantor Pusat eks N11",
    "Kantor Pusat eks N10",
    "Kebun Adjong Gayasan",
    "Kebun Kertosari",
    "Kebun Klaten",
    "PG Assembagus",
    "PG Djatiroto",
    "PG Djombang Baru",
    "PG Gempolkrep",
    "PG Gending",
    "PG Kanigoro",
    "PG Kedawung",
    "PG Kremboong",
    "PG Lestari",
    "PG Meritjan",
    "PG Modjopanggoong",
    "PG Ngadiredjo",
    "PG Pajarakan",
    "PG Pagottan",
    "PG Pandji",
    "PG Pesantren Baru",
    "PG Pradjekan",
    "PG Purwodadie",
    "PG Redjosari",
    "PG Semboro",
    "PG Sudhono",
    "PG Tjoekir",
    "PG Toelangan",
    "PG Watoetoelis",
    "PG Wonolangan",
    "PG Wringinanom",
    "PK Rosella Baru",
    "Pasa dan Hilirisasi Usaha",
    "Unit Usaha Strategis",
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
      {Widget? prefix, bool isDate = false, bool isNumber = false, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 3),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: TextField(
            controller: controllers[key],
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
            readOnly: readOnly || isDate,
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
    controllers["Nomor Pensiunan"]!.removeListener(_fetchPensionerDetails);
    super.dispose();
    for (var controller in controllers.values) {
      controller.dispose();
    }
  }

  bool isLoading = false;

 Future<void> createAccountPressed(BuildContext context) async {
    String name = controllers["Nama"]?.text ?? '';
    String email = controllers["Email"]?.text ?? '';
    String alamat = controllers["Alamat"]?.text ?? '';
    String tanggalLahir = controllers["Tanggal Lahir"]?.text ?? '';
    String nomorHP = controllers["Nomor HP"]?.text ?? '';
    String pgUnit = controllers["PG Unit"]?.text ?? '';
    String noPensiunan = controllers["Nomor Pensiunan"]?.text ?? '';
    String nik = controllers["NIK"]?.text ?? '';
    String namaBersangkutan = controllers["Nama Bersangkutan"]?.text ?? '';
    String status = controllers["Status"]?.text ?? '';

    if (name.isEmpty ||
        email.isEmpty ||
        alamat.isEmpty ||
        tanggalLahir.isEmpty ||
        nomorHP.isEmpty ||
        pgUnit.isEmpty ||
        noPensiunan.isEmpty ||
        nik.isEmpty ||
        namaBersangkutan.isEmpty ||
        status.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);

    if (!emailValid) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Email tidak valid')));
      return;
    }

    if (nomorHP.length < 9) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nomor HP tidak valid')));
      return;
    }

    if (noPensiunan.length != 12) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No Pensiunan harus 12 digit')));
      return;
    }

    if (nik.length != 16) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('NIK harus 16 digit')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      http.Response response = await AuthServices.register(
          name,
          email,
          alamat,
          tanggalLahir,
          nomorHP,
          pgUnit,
          noPensiunan,
          nik,
          namaBersangkutan,
          status);

      print("Response Status Code: ${response.statusCode}");
      print("Raw Response: ${response.body}");

      Map<String, dynamic> responseMap = jsonDecode(response.body);

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setString('user_name', name);

        http.Response loginResponse =
            await AuthServices.login(email, 'defaultpassword');
        if (loginResponse.statusCode == 200) {
          var loginData = jsonDecode(loginResponse.body);
          if (loginData.containsKey('access_token')) {
            await prefs.setString('access_token', loginData['access_token']);
          }
        }

        if (responseMap.containsKey('access_token')) {
          final token = responseMap['access_token'];
          print("Token value: " + token); 
          await prefs.setString('access_token', token);
        } else {
          print(
              "No access_token key in response. Available keys: ${responseMap.keys.join(', ')}");
        }

        await prefs.setString('user_phone', nomorHP);
        await prefs.setString('user_address', alamat);

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pendaftaran berhasil')));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const DaftarBerhasil()),
        );
      } else {
        String errorMessage = responseMap["message"] ?? "Terjadi kesalahan";

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));

        if (response.statusCode == 422) {
          if (responseMap.containsKey('errors')) {
            Map<String, dynamic> errors = responseMap['errors'];
            if (errors.containsKey('email') && errors['email'] is List) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(errors['email'][0])));
            }
          }
        }
      }
    } catch (e) {
      print("Error during registration: $e");

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan. Coba lagi.')));
    }
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Divider(color: Colors.grey[300], thickness: 3),
                      buildTextField("Nama", "Nama Pendaftar", "Nama Penerima"),
                      buildTextField("Email", "Email", "example@gmail.com"),
                      buildTextField("Alamat", "Alamat", "Alamat Penerima"),
                      buildTextField("Tanggal Lahir", "Tanggal Lahir",
                          "Pilih tanggal lahir",
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
                      const Divider(
                          color: Colors.grey, thickness: 3, height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("PG / Unit Terakhir Dinas",
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 5),
                          DropdownSearch<String>(
                            items: instansiList,
                            selectedItem: selectedInstansi,
                            popupProps: PopupProps.modalBottomSheet(
                              showSearchBox: true,
                              title: const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  "PG / Unit Terakhir Dinas",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              modalBottomSheetProps:
                                  const ModalBottomSheetProps(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                              ),
                            ),
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
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
                                controllers["PG Unit"]?.text = newValue ?? '';
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                      buildTextField("Nomor Pensiunan", "Nomor Pensiunan", "12 digit nomor pensiunan", isNumber: true),
                      buildTextField("NIK", "NIK", "16 digit NIK", isNumber: true),
                      buildTextField("Nama Bersangkutan", "Nama", "Nama bersangkutan", readOnly: true),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Status Hubungan Keluarga",
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 5),
                          DropdownSearch<String>(
                            items: statusKeluargaList,
                            selectedItem: selectedStatusKeluarga,
                            popupProps: PopupProps.modalBottomSheet(
                              showSearchBox: true,
                              title: const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  "Status Hubungan Keluarga",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              modalBottomSheetProps:
                                  const ModalBottomSheetProps(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                              ),
                            ),
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                hintText: "Status Hubungan",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedStatusKeluarga = newValue;
                                controllers["Status"]?.text = newValue ?? '';
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
                         onPressed: () => createAccountPressed(context),
                          child: const Text(
                            "Daftar",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          LoadingWidget(isLoading: isLoading),
        ],
      ),
    );
  }
}
