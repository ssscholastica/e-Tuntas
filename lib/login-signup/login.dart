import 'dart:convert';
import 'package:etuntas/home.dart';
import 'package:etuntas/login-signup/forgotPassword.dart';
import 'package:etuntas/login-signup/login.dart';
import 'package:etuntas/login-signup/pendaftaran.dart';
import 'package:etuntas/network/auth_services.dart';
import 'package:etuntas/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final LinearGradient _gradient = const LinearGradient(
      colors: <Color>[Color(0xFF26267E), Color(0xFF2F2F9D), Color(0xFF6F6FB9)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight);

  bool _obscureText = true;
  bool isLoading = false;
  String errorMessage = "";
  String name = '';
  String password = '';

  void loginPressed() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });
    try {
      var response = await AuthServices.login(name, password);
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        setState(() {
          errorMessage = responseData['message'] ?? 'Login gagal';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Terjadi kesalahan, coba lagi.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _name = '';
  String _password = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void LoginPressed() async {
    String name = _nameController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isNotEmpty && password.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      print("Mengirim login request:");
      print("name: $name");
      print("Password: $password");

      http.Response response = await AuthServices.login(name, password);
      Map responseMap = jsonDecode(response.body);
      print("Response dari server: ${response.body}");

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = responseMap['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', userData['email']);

        // Also store the token
        final token = responseMap['access_token'];
        await prefs.setString('access_token', token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const Home()),
        );
      } else {
        errorSnackBar(context, responseMap['message'] ?? "Login failed");
      }
    } else {
      errorSnackBar(context, 'Masukkan semua field!');
    }
  }


  void errorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (Rect rect) {
                            return _gradient.createShader(rect);
                          },
                          child: const Center(
                            child: Text(
                              "E-Tuntas",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Image.asset(
                          "assets/logo ptpn1.png",
                          height: 40,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Image.asset(
                      "assets/login.png",
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Masuk ke Akun Anda",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          "Nama Pengguna",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Nama Pengguna",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5),
                        child:  Text(
                          "Kata Sandi",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      onChanged: (value) {
                        setState(() {
                          password =
                              value;
                        });
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        hintText: "Kata Sandi",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPassword()));
                        },
                        child: const Text("Lupa Kata Sandi?"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: const Color(0xFF2F2F9D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: loginPressed,
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Belum memiliki akun?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Pendaftaran()));
                      },
                      child: const Text(
                        "Daftar",
                        style: TextStyle(
                          color: Color(0xFF2F2F9D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Informasi Pendaftaran",
                        style: TextStyle(color: Color(0xFF2F2F9D)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            LoadingWidget(isLoading: isLoading),
          ],
        ),
      ),
    );
  }
}
