import 'dart:convert';
import 'dart:io';

import 'package:etuntas/network/globals.dart';
import 'package:etuntas/widgets/loading_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AduanFormPage extends StatefulWidget {
  final String kategori;
  final String nik;

  AduanFormPage({Key? key, required this.kategori, required this.nik})
      : super(key: key);

  @override
  _AduanFormPageState createState() => _AduanFormPageState();
}

Widget uploadDokumen(String label, Function(File?) onFileSelected) {
  return _UploadDokumen(label: label, onFileSelected: onFileSelected);
}

class _UploadDokumen extends StatefulWidget {
  final String label;
  final Function(File?) onFileSelected;

  const _UploadDokumen(
      {super.key, required this.label, required this.onFileSelected});

  @override
  State<_UploadDokumen> createState() => _UploadDokumenState();
}

class _UploadDokumenState extends State<_UploadDokumen> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
      widget.onFileSelected(_selectedFile);
    }

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  void _previewFile() {
    if (_selectedFile != null) {
      OpenFile.open(_selectedFile!.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      _selectedFile != null
                          ? _selectedFile!.path.split('/').last
                          : "Pilih Dokumen",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (_selectedFile != null) ...[
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blue),
                    onPressed: _previewFile,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: _removeFile,
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: _pickFile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AduanFormPageState extends State<AduanFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final Map<String, TextEditingController> controllers = {};

  @override
  @override
  void initState() {
    super.initState();

    controllers["Tanggal Ajuan"] = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    controllers["NIK"] = TextEditingController();
    controllers["Deskripsi"] = TextEditingController();
    controllers["Kategori"] = TextEditingController(text: widget.kategori);

    fetchUserNIK();
    }

    Future<void> fetchUserNIK() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');

    if (email != null && email.isNotEmpty) {
      try {
      // Kirim email sebagai parameter agar backend tahu user mana
      final response = await http.get(
        Uri.parse('${baseURL}user/get-nik?email=$email'),
        headers: await getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nik = data['nik'] ?? '';
        setState(() {
        controllers["NIK"]?.text = nik;
        });
      } else {
        debugPrint("Gagal mengambil NIK: ${response.statusCode}");
        setState(() {
        controllers["NIK"]?.text = '';
        });
      }
      } catch (e) {
      debugPrint("Error mengambil NIK: $e");
      setState(() {
        controllers["NIK"]?.text = '';
      });
      }
    } else {
      debugPrint("Email tidak ditemukan di SharedPreferences.");
      setState(() {
      controllers["NIK"]?.text = '';
      });
    }
    }

  String? _filePath;
  File? _selectedFile;

  Future<void> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        controllers["Tanggal Ajuan"]?.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  void submitForm() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final email = await getUserEmail();
    debugPrint("Retrieved email from SharedPreferences: $email");

    if (email == null || email.isEmpty) {
      debugPrint("Email tidak ditemukan dalam SharedPreferences.");
      setState(() {
        isLoading = false;
      });
      _showDialog(
        success: false,
        title: "Gagal Upload!",
        message: "Email pengguna tidak ditemukan. Silakan login kembali.",
        buttonText: "Kembali",
        onPressed: () => Navigator.pop(context),
      );
      return;
    }

    String tanggalAjuan = controllers["Tanggal Ajuan"]!.text;
    String deskripsi = controllers["Deskripsi"]!.text;

    if (tanggalAjuan.isEmpty ||
        deskripsi.isEmpty ||
        _filePath == null ||
        _filePath!.isEmpty ||
        _selectedFile == null) {
      setState(() {
        isLoading = false;
      });
      _showDialog(
        success: false,
        title: "Gagal!",
        message: "Harap lengkapi semua data terlebih dahulu.",
        buttonText: "Kembali",
        onPressed: () => Navigator.pop(context),
      );
      return;
    }

    try {
      final headers = await getHeaders();
      var uri = Uri.parse('${baseURL}pengaduan-bpjs/');
      var request = http.MultipartRequest('POST', uri);

      request.fields['email'] = email;
      debugPrint("Request fields: ${request.fields}");
      request.headers.addAll(headers);
      request.fields['kategori_bpjs'] = controllers["Kategori"]!.text;
      request.fields['tanggal_ajuan'] = tanggalAjuan;
      request.fields['nomor_bpjs_nik'] = controllers["NIK"]!.text;
      request.fields['deskripsi'] = deskripsi;
      request.files.add(await http.MultipartFile.fromPath(
        'data_pendukung',
        _selectedFile!.path,
      ));
      request.fields['send_email'] = 'true';

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response body: $respStr');

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showDialog(
          success: true,
          title: "Berhasil!",
          message: "Aduan Anda berhasil dikirim!",
          buttonText: "Oke",
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context, {
              "Email": email,
              "Tanggal Ajuan": tanggalAjuan,
              "Deskripsi": deskripsi,
              "Data Pendukung": _filePath!,
            });
          },
        );
      } else {
        String errorMessage = "Terjadi kesalahan. Coba lagi nanti.";

        try {
          var jsonResp = json.decode(respStr);
          errorMessage = jsonResp["message"] ?? errorMessage;
        } catch (e) {
          print("Gagal decode JSON: $e");
          if (respStr.contains('<!DOCTYPE html>')) {
            errorMessage = "Terjadi kesalahan pada server (HTML error page).";
          }
        }

        _showDialog(
          success: false,
          title: "Gagal!",
          message: errorMessage,
          buttonText: "Reupload",
          onPressed: () => Navigator.pop(context),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showDialog(
        success: false,
        title: "Error",
        message: "Terjadi kesalahan: $e",
        buttonText: "Kembali",
        onPressed: () => Navigator.pop(context),
      );
    }
  }

  void _showDialog({
    required bool success,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                success ? 'assets/icon berhasil.png' : 'assets/icon gagal.png',
                width: 50,
                height: 50,
              ),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: success
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                children: [
                  if (!success)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Kembali",
                          style: TextStyle(color: Colors.white)),
                    ),
                  TextButton(
                    onPressed: onPressed,
                    style: TextButton.styleFrom(
                      backgroundColor: success
                          ? const Color.fromARGB(255, 18, 18, 162)
                          : const Color.fromARGB(170, 231, 0, 23),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildTextField(
      {required String label,
      required String hint,
      required TextEditingController controller,
      bool readOnly = false,
      int maxLines = 1,
      VoidCallback? onTap,
      bool isNumber = false}) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters:
              isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(
                vertical: isLandscape ? 6 : 8, horizontal: 12),
          ),
          onTap: onTap,
        ),
        SizedBox(height: isLandscape ? 5 : 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: isLandscape ? 10 : 20, left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Image.asset('assets/simbol back.png',
                                width: 28, height: 28),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "Aduan & Tracking BPJS",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isLandscape ? 5 : 10),
                      Text(
                        widget.kategori,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(217, 38, 38, 126),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: isLandscape ? 5 : 10),
                            buildTextField(
                              label: "Kategori",
                              hint: "",
                              controller: controllers["Kategori"]!,
                              readOnly: true,
                            ),
                            buildTextField(
                              label: "Tanggal Ajuan",
                              hint: "",
                              controller: controllers["Tanggal Ajuan"]!,
                              readOnly: true,
                            ),
                            buildTextField(
                              label: "NIK",
                              hint: "",
                              controller: controllers["NIK"]!,
                              readOnly: true,
                            ),
                            buildTextField(
                              label: "Deskripsi",
                              hint: "Deskripsi",
                              controller: controllers["Deskripsi"]!,
                              maxLines: isLandscape ? 3 : 4,
                            ),
                            uploadDokumen("Data Pendukung",
                                (File? selectedFile) {
                              setState(() {
                                _selectedFile = selectedFile;
                                _filePath = selectedFile?.path.split('/').last;
                              });
                            }),
                            SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: isKeyboardVisible && isLandscape
                                        ? 20
                                        : 40,
                                    bottom: isKeyboardVisible
                                        ? (isLandscape ? 80 : 40)
                                        : 20),
                                child: ElevatedButton(
                                  onPressed: submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2F2F9D),
                                    padding: EdgeInsets.symmetric(
                                        vertical: isLandscape ? 10 : 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Kirim",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isLoading) LoadingWidget(isLoading: isLoading)
          ],
        ),
      ),
    );
  }
}
