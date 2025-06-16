import 'dart:convert';

import 'package:etuntas/network/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormTambahFAQ extends StatefulWidget {
  const FormTambahFAQ({super.key});

  @override
  State<FormTambahFAQ> createState() => _FormTambahFAQState();
}

class _FormTambahFAQState extends State<FormTambahFAQ> {
  final TextEditingController pertanyaanController = TextEditingController();
  final TextEditingController jawabanController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void dispose() {
    pertanyaanController.dispose();
    jawabanController.dispose();
    super.dispose();
  }

  Future<void> _saveFAQ() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final pertanyaan = pertanyaanController.text.trim();
    final jawaban = jawabanController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('${baseURL}faqs'),
        headers: headers,
        body: jsonEncode({
          'pertanyaan': pertanyaan,
          'jawaban': jawaban,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        final responseBody = jsonDecode(response.body);
        debugPrint("Failed response: ${response.body}");
        
        String errorMessage = "Gagal menyimpan FAQ";
        if (responseBody is Map && responseBody.containsKey('message')) {
          errorMessage = responseBody['message'];
        } else if (responseBody is Map && responseBody.containsKey('errors')) {
          final errors = responseBody['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first.join(', ');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildInputField(String label, String hint, TextEditingController controller, {bool isRequired = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(top: 20, left: 20),
          child: RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0XFF000000),
                fontWeight: FontWeight.w600,
              ),
              children: isRequired ? [
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ] : [],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: TextFormField(
            controller: controller,
            maxLines: label == "Jawaban" ? 6 : 4,
            validator: isRequired ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label tidak boleh kosong';
              }
              return null;
            } : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15, 
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2F2F9D), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  margin: const EdgeInsets.only(top: 30, left: 20, right: 20),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back, size: 28),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Tambah Daftar Pertanyaan",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0XFF000000),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Form Fields
                buildInputField(
                  "Pertanyaan", 
                  'Masukkan pertanyaan yang sering ditanyakan', 
                  pertanyaanController
                ),
                buildInputField(
                  "Jawaban", 
                  "Masukkan jawaban untuk pertanyaan tersebut", 
                  jawabanController
                ),
                
                const SizedBox(height: 25),
              
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: const BorderSide(color: Color(0xFF2F2F9D)),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              color: Color(0xFF2F2F9D), 
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveFAQ,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color(0xFF2F2F9D),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  "Simpan",
                                  style: TextStyle(
                                    color: Colors.white, 
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}