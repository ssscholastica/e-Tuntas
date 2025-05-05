import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:etuntas/network/globals.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

class AduanFormPage extends StatefulWidget {
  final String kategori;

  AduanFormPage({Key? key, required this.kategori});

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
  void initState() {
    super.initState();
    controllers["Tanggal Ajuan"] = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    controllers["Nomor BPJS/NIK"] = TextEditingController();
    controllers["Deskripsi"] = TextEditingController();
    controllers["Kategori"] = TextEditingController(text: widget.kategori);
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

  void submitForm() async {
    setState(() {
      isLoading = true;
    });

    String tanggalAjuan = controllers["Tanggal Ajuan"]!.text;
    String nomorBpjsNik = controllers["Nomor BPJS/NIK"]!.text;
    String deskripsi = controllers["Deskripsi"]!.text;

    if (tanggalAjuan.isEmpty ||
        nomorBpjsNik.isEmpty ||
        deskripsi.isEmpty ||
        _filePath == null ||
        _filePath!.isEmpty ||
        _selectedFile == null) {
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
      var uri = Uri.parse('${baseURL}pengaduan-bpjs/');
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({'Accept': 'application/json'});
      request.fields['kategori_bpjs'] = controllers["Kategori"]!.text;
      request.fields['tanggal_ajuan'] = tanggalAjuan;
      request.fields['nomor_bpjs_nik'] = nomorBpjsNik;
      request.fields['deskripsi'] = deskripsi;
      request.files.add(await http.MultipartFile.fromPath(
        'data_pendukung',
        _selectedFile!.path,
      ));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response body: $respStr');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showDialog(
          success: true,
          title: "Berhasil!",
          message: "Aduan Anda berhasil dikirim!",
          buttonText: "Oke",
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context, {
              "Tanggal Ajuan": tanggalAjuan,
              "Nomor BPJS/NIK": nomorBpjsNik,
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
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          onTap: onTap,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 60),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset('assets/simbol back.png',
                        width: 28, height: 28),
                  ),
                  const SizedBox(width: 10),
                  const Text("Aduan & Tracking BPJS",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                widget.kategori,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(217, 38, 38, 126),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                        onTap: () => selectDate(context),
                      ),
                      buildTextField(
                          label: "Nomor BPJS/NIK",
                          hint: "Nomor BPJS/NIK",
                          controller: controllers["Nomor BPJS/NIK"]!,
                          isNumber: true),
                      buildTextField(
                          label: "Deskripsi",
                          hint: "Deskripsi",
                          controller: controllers["Deskripsi"]!,
                          maxLines: 4),
                      uploadDokumen("Data Pendukung", (File? selectedFile) {
                        setState(() {
                          _selectedFile = selectedFile;
                          _filePath = selectedFile?.path.split('/').last;
                        });
                      }),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 200),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F2F9D),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Kirim",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
