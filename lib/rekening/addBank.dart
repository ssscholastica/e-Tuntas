import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';

class addBank extends StatefulWidget {
  const addBank({super.key});

  @override
  State<addBank> createState() => _addBankState();
}

Widget uploadDokumen(String label, Function(File?) onFileSelected) {
  return _UploadDokumen(label: label, onFileSelected: onFileSelected);
}

class _UploadDokumen extends StatefulWidget {
  final String label;
  final Function(File?) onFileSelected;

  const _UploadDokumen({super.key, required this.label, required this.onFileSelected});

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
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
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

class _addBankState extends State<addBank> {
  final TextEditingController namaBankController = TextEditingController();
  final TextEditingController noRekController = TextEditingController();
  final TextEditingController namaPemilikController = TextEditingController();
  String? _uploadedFileName;
  bool isLoading = false;

  void _saveBankAccount() {
  if (namaBankController.text.isNotEmpty &&
      noRekController.text.isNotEmpty &&
      namaPemilikController.text.isNotEmpty &&
      _uploadedFileName != null &&
      _uploadedFileName!.isNotEmpty) {
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
              ),
            alignment: Alignment.center,
          child: const CircularProgressIndicator(),
            ))
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); 

      _showDialog(
        success: true,
        title: "Tersimpan!",
        message: "Data Rekening berhasil ditambahkan",
        buttonText: "Oke",
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context, {
            "Nama Bank": namaBankController.text,
            'Nomor Rekening': noRekController.text,
            'Nama Pemilik': namaPemilikController.text,
            'Buku Tabungan': _uploadedFileName ?? 'No file chosen'
          });
        },
      );
    });

  } else {
    _showDialog(
      success: false,
      title: "Gagal!",
      message: "Terjadi kesalahan...",
      buttonText: "Reupload",
      onPressed: () {
        Navigator.pop(context);
      },
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
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

  Widget buildJudul(
      String judul, String hint, TextEditingController controller, {bool isNumber = false}) {
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
          child: SizedBox(
            height: 50,
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.left,
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              inputFormatters:
                  isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
              decoration: InputDecoration(
                hintText: hint,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 30, left: 20, right: 20),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        'assets/simbol back.png',
                        width: 28,
                        height: 28,
                      ),
                    ),
                    const Text(
                      "Tambah Rekening",
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0XFF000000),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              buildJudul("Nama Bank", 'Nama Bank', namaBankController),
              buildJudul("Nomor Rekening", 'Nomor Rekening', noRekController,
                  isNumber: true),
              buildJudul("Nama Pemilik", "Nama Pemilik", namaPemilikController),
              uploadDokumen("Buku Tabungan", (File? selectedFile) {
                setState(() {
                  _uploadedFileName = selectedFile?.path.split('/').last;
                });
              }),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: isLoading ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _saveBankAccount,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: const Color(0xFF2F2F9D)),
                    child: const Text("Simpan",
                        style:
                            TextStyle(color: Color(0xFFFFFFFF), fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
