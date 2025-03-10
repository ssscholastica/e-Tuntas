import 'package:etuntas/profile/editBerhasil.dart';
import 'package:etuntas/navbar.dart';
import 'package:etuntas/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:etuntas/widgets/loading_widget.dart'; // Import LoadingWidget

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Sri Indah');
  final TextEditingController _emailController =
      TextEditingController(text: 'sriindah@gmail.com');
  final TextEditingController _phoneController =
      TextEditingController(text: '8214156628');
  final TextEditingController _addressController =
      TextEditingController(text: 'Jl. Merak 1');
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  bool isLoading = false; // Status untuk loading

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2002, 2, 2);
    _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);
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
      {bool isPhone = false, bool isDate = false, bool readOnly = false}) {
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
                      const Spacer(),
                      const Text(
                        "Profile",
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
                buildTextField('Nama', _nameController),
                buildTextField("Email", _emailController),
                buildTextField("Nomor HP", _phoneController, isPhone: true),
                buildTextField("Tanggal Lahir", _dateController, isDate: true),
                buildTextField("Alamat", _addressController),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditBerhasil()));
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 160, vertical: 15),
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
          LoadingWidget(isLoading: isLoading), 
        ],
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
