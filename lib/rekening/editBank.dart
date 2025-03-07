import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class editBank extends StatefulWidget {
  final Map<String, String>? bankAccounts;

  const editBank({super.key, required this.bankAccounts});

  @override
  State<editBank> createState() => _editBankState();
}

class _UploadDokumen extends StatefulWidget {
  final String label;
  final Function(String) onFileSelected;

  const _UploadDokumen({super.key, required this.label, required this.onFileSelected});

  @override
  State<_UploadDokumen> createState() => _UploadDokumenState();
}

class _UploadDokumenState extends State<_UploadDokumen> {
  File? _selectedFile;
  String? _fileName;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });

      widget.onFileSelected(_fileName!);
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

class _editBankState extends State<editBank> {
  late TextEditingController namaBankController;
  late TextEditingController noRekController;
  late TextEditingController namaPemilikController;
  String? _uploadedFileName;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    namaBankController = TextEditingController(text: widget.bankAccounts?['Nama Bank']);
    noRekController = TextEditingController(text: widget.bankAccounts?['Nomor Rekening']);
    namaPemilikController = TextEditingController(text: widget.bankAccounts?['Nama Pemilik']);
    _uploadedFileName = widget.bankAccounts?['Buku Tabungan'];
  }

  void editRekening() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Widget uploadDokumen(String label) {
    return _UploadDokumen(
      label: label,
      onFileSelected: (fileName) {
        setState(() {
          _uploadedFileName = fileName;
        });
      },
    );
  }

  void _saveBankAccount() {
    if (namaBankController.text.isNotEmpty &&
        noRekController.text.isNotEmpty &&
        namaPemilikController.text.isNotEmpty &&
        _uploadedFileName != null &&
        _uploadedFileName!.isNotEmpty) {
      _showDialog(
        success: true,
        title: "Tersimpan!",
        message: "Data Rekening berhasil diubah",
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

  void deleteRekening(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text("Apakah Anda yakin?"),
        content: const Text("Untuk hapus rekening"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (mounted) {
                _showDialog(
                  success: true,
                  title: "Terhapus!",
                  message: "Data Rekening berhasil dihapus",
                  buttonText: "Oke",
                  onPressed: () {
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
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
      String judul, String hint, TextEditingController controller) {
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
              readOnly: !isEditing,
              textAlign: TextAlign.left,
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

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                      "Rekening Saya",
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
              buildJudul("Nomor Rekening", 'Nomor Rekening', noRekController),
              buildJudul("Nama Pemilik", "Nama Pemilik", namaPemilikController),
              uploadDokumen("Buku Tabungan"),
              const SizedBox(height: 25),
              if (isEditing) ...[
              Row(
                children: [
                  const Padding(padding: EdgeInsets.only(left: 20)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveBankAccount,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 18, 18, 162)),
                      child: const Text("Simpan", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 20)
                ],
              ),
            ] else ...[
              Row(
                children: [
                  const Padding(padding: EdgeInsets.only(left: 20)),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {deleteRekening(context);},
                      style: OutlinedButton.styleFrom(foregroundColor: const Color.fromARGB(170, 231, 0, 23)),
                      child: const Text("Hapus"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: editRekening,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 18, 18, 162)),
                      child: const Text("Edit", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 20)
                ],
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }
}
