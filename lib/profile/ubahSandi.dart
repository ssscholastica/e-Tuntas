import 'dart:convert';

import 'package:etuntas/network/globals.dart';
import 'package:etuntas/profile/profile.dart';
import 'package:etuntas/profile/ubahBerhasil.dart';
import 'package:etuntas/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UbahSandi extends StatefulWidget {
  const UbahSandi({super.key});

  @override
  State<UbahSandi> createState() => _UbahSandiState();
}

class _UbahSandiState extends State<UbahSandi> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? email;
  String? userEmail;
  Map<String, dynamic>? userData;

  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('user_email');
    });
    if (email != null) {
      await _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    if (email == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse("${baseURL}user/email/$email");
      debugPrint("Fetching user data from: $url");
      final headers = await getHeaders();
      final response = await http.get(url, headers: headers);
      debugPrint("Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userData = data;
          userEmail = data['email']?.toString();
        });
        debugPrint("User Email: $userEmail");
      } else {
        setState(() {
          errorMessage = 'Failed to fetch user data';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching user data: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _verifyCurrentPassword(String currentPassword) async {
    if (email == null) return false;

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse("${baseURL}auth/verify-password");
      debugPrint("Verifying password at: $url");
      final headers = await getHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'email': email, 'password': currentPassword}),
      );

      debugPrint("Verify Password Response Status: ${response.statusCode}");
      debugPrint("Verify Password Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }

      if (response.statusCode >= 400) {
        final data = jsonDecode(response.body);
        setState(() {
          errorMessage = data['message'] ?? 'Failed to verify password';
        });
      }

      return false;
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to verify password: $e';
      });
      return false;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _updatePassword(String newPassword) async {
    if (email == null) return false;

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse("${baseURL}user/update-password");
      debugPrint("Updating password at: $url");
      final headers = await getHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({'email': email, 'new_password': newPassword}),
      );

      debugPrint("Update Password Response Status: ${response.statusCode}");
      debugPrint("Update Password Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }

      if (response.statusCode >= 400) {
        final data = jsonDecode(response.body);
        setState(() {
          errorMessage = data['message'] ?? 'Failed to update password';
        });
      }

      return false;
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update password: $e';
      });
      return false;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  final Map<int, bool> _obscureTextMap = {
    0: true,
    1: true,
    2: true,
  };

  Widget buildPasswordField(
      String judul, TextEditingController controller, int index,
      {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(top: 20, left: 20),
          child: Text(
            judul,
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
          child: TextFormField(
            controller: controller,
            validator: validator,
            textAlign: TextAlign.left,
            obscureText: _obscureTextMap[index]!,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureTextMap[index]!
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureTextMap[index] = !_obscureTextMap[index]!;
                  });
                },
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSavePressed() async {
    setState(() {
      errorMessage = '';
    });

    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Kata sandi baru tidak cocok dengan konfirmasi')),
        );
        return;
      }

      final isCurrentPasswordValid =
          await _verifyCurrentPassword(_currentPasswordController.text);
      if (!isCurrentPasswordValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kata sandi saat ini tidak valid')),
        );
        return;
      }

      final isPasswordUpdated =
          await _updatePassword(_newPasswordController.text);
      if (isPasswordUpdated) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UbahBerhasil()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(errorMessage.isEmpty
                  ? 'Gagal memperbarui kata sandi'
                  : errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 80, left: 20, right: 20),
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
                          "Ganti Kata Sandi",
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
                      'Ubah Kata Sandi',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0XFF000000),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  buildPasswordField(
                    'Kata Sandi Sekarang',
                    _currentPasswordController,
                    0,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan kata sandi saat ini';
                      }
                      return null;
                    },
                  ),
                  buildPasswordField(
                    "Kata Sandi Baru",
                    _newPasswordController,
                    1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan kata sandi baru';
                      }
                      if (value.length < 6) {
                        return 'Kata sandi minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  buildPasswordField(
                    "Ulang Kata Sandi Baru",
                    _confirmPasswordController,
                    2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan konfirmasi kata sandi';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Kata sandi tidak cocok';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  if (errorMessage.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _onSavePressed,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.37,
                        vertical: MediaQuery.of(context).size.height * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFF2F2F9D),
                    ),
                    child: const Text(
                      "Simpan",
                      style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          LoadingWidget(isLoading: isLoading),
        ],
      ),
    );
  }
}
