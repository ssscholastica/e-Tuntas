import 'dart:convert';

import 'package:etuntas/navbar.dart';
import 'package:etuntas/network/globals.dart';
import 'package:etuntas/profile/editBerhasil.dart';
import 'package:etuntas/profile/profile.dart';
import 'package:etuntas/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String name = "-";
  String email = "-";
  String nomorHp = "-";
  String tanggalLahir = "-";
  String alamat = "-";

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dateController;

  DateTime? _selectedDate;
  bool isLoading = false; 

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _dateController = TextEditingController();
    _selectedDate = DateTime(2002, 2, 2);
    _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);
    fetchData();
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email') ?? '';

    if (userEmail.isEmpty) {
      debugPrint("No user email found in SharedPreferences.");
      setState(() {
        name = "-";
        email = "-";
        nomorHp = "-";
        tanggalLahir = "-";
        alamat = "-";
      });
      return;
    }

    final url = Uri.parse("${baseURL}user/email/$userEmail");
    debugPrint("Fetching user data from: $url");

    try {
      final headers = await getHeaders();
      final response = await http.get(url, headers: headers);
      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");


      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          name = data['name'] ?? "No Name";
          email = data['email'] ?? "-";
          nomorHp = data['nomor_hp'] ?? "-";
          tanggalLahir = data['tanggal_lahir'] ?? "-";
          alamat = data['alamat'] ?? "-";
        });

         _nameController.text = name;
        _emailController.text = email;
        _phoneController.text = nomorHp;
        _dateController.text = tanggalLahir;
        _addressController.text = alamat;

      } else {
        setState(() {
          name = "User Not Found";
          email = "-";
          nomorHp = "-";
          tanggalLahir = "-";
          alamat = "-";
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      setState(() {
        name = "Error Fetching Data";
        email = "-";
        nomorHp = "-";
        tanggalLahir = "-";
        alamat = "-";
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool isPhone = false, bool isDate = false, bool readOnly = false, void Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(top: 20, left: 20),
          child: Text(
            label,
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
              controller: controller,
              readOnly: isDate || readOnly,
              keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
              inputFormatters: isPhone
                  ? [
                      FilteringTextInputFormatter.digitsOnly,
                    ]
                  : null,
              onTap: isDate
                  ? () {
                      _selectDate(context);
                    }
                  : null,
                  onChanged: onChanged,
              decoration: InputDecoration(
                prefixText: isPhone ? '+62 ' : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: isDate
                    ? const Icon(Icons.calendar_today, color: Colors.grey)
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onBackPressed() {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Profile()),
      );
    });
  }

  void _saveProfile() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email') ?? '';

    if (userEmail.isEmpty) {
      debugPrint("No user email found in SharedPreferences.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      debugPrint("Nama dan email harus diisi!");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse("${baseURL}user/update");
    final body = jsonEncode({
      "email": _emailController.text,
      "name": _nameController.text,
      "nomor_hp": _phoneController.text,
      "tanggal_lahir": _dateController.text,
      "alamat": _addressController.text,
    });

    try {
      final headers = await getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: body, 
      );

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditBerhasil()),
        );
      } else {
        debugPrint("Failed to update profile");
      }
    } catch (e) {
      debugPrint("Error updating profile: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 60, left: 20, right: 20),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: _onBackPressed,
                        child: Image.asset(
                          'assets/simbol back.png',
                          width: 28,
                          height: 28,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Edit Profile",
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
                    'Informasi Data Pendaftar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0XFF000000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                buildTextField('Nama', _nameController,
                    onChanged: (val) => setState(() => name = val)),
                buildTextField("Email", _emailController,
                readOnly: true,
                    onChanged: (val) => setState(() => email = val)),
                buildTextField("Nomor HP", _phoneController,
                    isPhone: true,
                    onChanged: (val) => setState(() => nomorHp = val)),
                buildTextField("Tanggal Lahir", _dateController,
                    isDate: true,
                    onChanged: (val) => setState(() => tanggalLahir = val)),
                buildTextField("Alamat", _addressController,
                    onChanged: (val) => setState(() => alamat = val)),
            
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                      padding:  EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width *0.37,
                          vertical: MediaQuery.of(context).size.height *0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFF2F2F9D)),
                  child: const Text("Simpan",
                      style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16)),
                ),
                const SizedBox(height: 10)
              ],
            ),
          ),
          LoadingWidget(isLoading: isLoading), 
        ],
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
