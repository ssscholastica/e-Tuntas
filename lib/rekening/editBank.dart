import 'dart:convert';
import 'dart:io';

import 'package:etuntas/network/globals.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class editBank extends StatefulWidget {
  final Map<String, dynamic>? bankAccounts;

  const editBank({super.key, required this.bankAccounts});

  @override
  State<editBank> createState() => _editBankState();
}

class _UploadDokumen extends StatefulWidget {
  final String label;
  final String? initialValue;
  final Function(String, File?) onFileSelected;

  const _UploadDokumen({
    super.key,
    required this.label,
    required this.onFileSelected,
    this.initialValue,
  });

  @override
  State<_UploadDokumen> createState() => _UploadDokumenState();
}

class _UploadDokumenState extends State<_UploadDokumen> {
  File? _selectedFile;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _fileName = widget.initialValue;
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = path.basename(result.files.single.path!);
      });

      widget.onFileSelected(_fileName!, _selectedFile);
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
    widget.onFileSelected("", null);
  }

  void _previewFile() {
    if (_selectedFile != null) {
      OpenFile.open(_selectedFile!.path);
    } else if (_fileName != null) {
      _showFilePreviewDialog();
    }
  }

  void _showFilePreviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("File API Preview"),
          content:
              Text("File: $_fileName\n\nThis file is stored on the server."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
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
                      _fileName != null && _fileName!.isNotEmpty
                          ? _fileName!
                          : "Pilih Dokumen",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (_fileName != null && _fileName!.isNotEmpty) ...[
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
  File? _uploadedFile;
  bool isEditing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    namaBankController =
        TextEditingController(text: widget.bankAccounts?['Nama Bank']);
    noRekController =
        TextEditingController(text: widget.bankAccounts?['Nomor Rekening']);
    namaPemilikController =
        TextEditingController(text: widget.bankAccounts?['Nama Pemilik']);
    _uploadedFileName = widget.bankAccounts?['buku_tabungan'];
  }

  void editRekening() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Widget uploadDokumen(String label, String? uploadedFileName) {
    return _UploadDokumen(
      label: label,
      initialValue: uploadedFileName,
      onFileSelected: (fileName, file) {
        setState(() {
          _uploadedFileName = fileName;
          _uploadedFile = file;
        });
      },
    );
  }

  void _saveBankAccount() async {
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

  if (namaBankController.text.isEmpty || noRekController.text.isEmpty) {
    debugPrint("Nama bank dan nomor rekening harus diisi!");
    setState(() {
      isLoading = false;
    });
    return;
  }

  final url = Uri.parse("${baseURL}rekening-bank");
  final body = jsonEncode({
    "nama_bank": namaBankController.text,
    "nomor_rekening": noRekController.text,
    "nama_pemilik": namaPemilikController.text,
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      final updatedData = {
        "Nama Bank": namaBankController.text,
        "Nomor Rekening": noRekController.text,
        "Nama Pemilik": namaPemilikController.text,
        "buku_tabungan": _uploadedFileName,
      };

      _showDialog(
        success: true,
        title: "Tersimpan!",
        message: "Data Rekening berhasil diubah",
        buttonText: "Oke",
        onPressed: () {
          Navigator.pop(context); // close dialog
          Navigator.pop(context, updatedData); // return to previous screen with data
        },
      );
    } else {
      debugPrint("Failed to save bank account");
    }
  } catch (e) {
    debugPrint("Error saving bank account: $e");
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  Future<void> deleteRekening(BuildContext context) async {
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
              onPressed: () async {
                Navigator.pop(dialogContext);

                setState(() {
                  isLoading = true;
                });

                try {
                  // Simulate success for now
                  setState(() {
                    isLoading = false;
                  });

                  if (mounted) {
                    _showDialog(
                      success: true,
                      title: "Terhapus!",
                      message: "Data Rekening berhasil dihapus",
                      buttonText: "Oke",
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context, {"deleted": true});
                      },
                    );
                  }

                  /* Uncomment for real API implementation
                  final response = await http.delete(
                    Uri.parse('$baseUrl/rekening-bank/delete/${widget.bankAccounts?['id']}'),
                  );
                  
                  setState(() {
                    isLoading = false;
                  });
                  
                  if (response.statusCode == 200) {
                    if (mounted) {
                      _showDialog(
                        success: true,
                        title: "Terhapus!",
                        message: "Data Rekening berhasil dihapus",
                        buttonText: "Oke",
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context, {"deleted": true});
                        },
                      );
                    }
                  } else {
                    var decodedResponse = json.decode(response.body);
                    if (mounted) {
                      _showDialog(
                        success: false,
                        title: "Gagal!",
                        message: decodedResponse['message'] ?? "Gagal menghapus rekening",
                        buttonText: "Coba Lagi",
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      );
                    }
                  }
                  */
                } catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                  if (mounted) {
                    _showDialog(
                      success: false,
                      title: "Error!",
                      message: "Terjadi kesalahan: $e",
                      buttonText: "Coba Lagi",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    );
                  }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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
                        const SizedBox(width: 10),
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
                  buildJudul(
                      "Nomor Rekening", 'Nomor Rekening', noRekController),
                  buildJudul(
                      "Nama Pemilik", "Nama Pemilik", namaPemilikController),
                  uploadDokumen(
                      "Buku Tabungan", widget.bankAccounts?["buku_tabungan"]),
                  const SizedBox(height: 25),
                  if (isEditing) ...[
                    Row(
                      children: [
                        const Padding(padding: EdgeInsets.only(left: 20)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _saveBankAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 18, 18, 162),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: const Text("Simpan",
                                style: TextStyle(color: Colors.white)),
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
                            onPressed: isLoading
                                ? null
                                : () => deleteRekening(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  const Color.fromARGB(170, 231, 0, 23),
                            ),
                            child: const Text("Hapus"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : editRekening,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 18, 18, 162),
                            ),
                            child: const Text("Edit",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 20)
                      ],
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 18, 18, 162),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
