import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:etuntas/network/globals.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

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
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
    widget.onFileSelected(null);
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
  @override
  void initState() {
    super.initState();
    fetchBankList();
    _checkExistingBankAccounts();
  }

  final TextEditingController namaBankController = TextEditingController();
  final TextEditingController noRekController = TextEditingController();
  final TextEditingController namaPemilikController = TextEditingController();
  File? _selectedBukuTabungan;
  bool isLoading = false;
  List<Bank> bankList = [];
  Bank? selectedBank;
  int existingBankAccountsCount = 0; // To track number of existing bank accounts

  // Check how many bank accounts already exist
  Future<void> _checkExistingBankAccounts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('${baseURL}rekening-bank/'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          existingBankAccountsCount = data.length;
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load existing bank accounts')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking accounts: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchBankList() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('${baseURL}banks/'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          bankList = data.map((json) => Bank.fromJson(json)).toList();
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load banks')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveBankAccount() async {
    // Check if already reached maximum bank accounts (3)
    if (existingBankAccountsCount >= 3) {
      _showDialog(
        success: false,
        title: "Batas Maksimum",
        message: "Rekening sudah melewati batas maksimum (3 rekening)",
        buttonText: "Mengerti",
        onPressed: () {
          Navigator.pop(context);
        },
      );
      return;
    }

    if (namaBankController.text.isEmpty ||
        noRekController.text.isEmpty ||
        namaPemilikController.text.isEmpty ||
        _selectedBukuTabungan == null) {
      _showDialog(
        success: false,
        title: "Data Tidak Lengkap",
        message: "Mohon lengkapi semua data terlebih dahulu",
        buttonText: "Ok",
        onPressed: () {
          Navigator.pop(context);
        },
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseURL}rekening-bank/'),
      );
      request.fields['nama_bank'] = namaBankController.text;
      request.fields['nomor_rekening'] = noRekController.text;
      request.fields['nama_pemilik'] = namaPemilikController.text;
      String fileName = path.basename(_selectedBukuTabungan!.path);
      String fileExtension = path.extension(fileName).toLowerCase();
      
      String contentType;
      if (['.jpg', '.jpeg'].contains(fileExtension)) {
        contentType = 'image/jpeg';
      } else if (fileExtension == '.png') {
        contentType = 'image/png';
      } else if (fileExtension == '.pdf') {
        contentType = 'application/pdf';
      } else {
        contentType = 'application/octet-stream';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'buku_tabungan',
          _selectedBukuTabungan!.path,
          contentType: MediaType.parse(contentType),
        ),
      );

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var responseData = json.decode(responseBody);

      // Close loading dialog
      Navigator.pop(context);

      if (response.statusCode == 201) {
        // Save bank account path to shared preferences
        final prefs = await SharedPreferences.getInstance();
        List<String> savedPaths = prefs.getStringList('bank_tabungan_paths') ?? [];
        savedPaths.add(_selectedBukuTabungan!.path);
        await prefs.setStringList('bank_tabungan_paths', savedPaths);
        
        // Success
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
              'Buku Tabungan': _selectedBukuTabungan!.path
            });
          },
        );
      } else {
        // Failed
        _showDialog(
          success: false,
          title: "Gagal!",
          message: responseData['message'] ??
              "Terjadi kesalahan saat menyimpan data",
          buttonText: "Coba Lagi",
          onPressed: () {
            Navigator.pop(context);
          },
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error dialog
      _showDialog(
        success: false,
        title: "Error!",
        message: "Terjadi kesalahan: ${e.toString()}",
        buttonText: "Coba Lagi",
        onPressed: () {
          Navigator.pop(context);
        },
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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

  Widget buildBankDropdown(String judul) {
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: DropdownSearch<Bank>(
            items: bankList,
            selectedItem: selectedBank,
            itemAsString: (Bank? bank) => bank?.namaBank ?? '',
            popupProps: PopupProps.modalBottomSheet(
              showSearchBox: true,
              title: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Pilih Bank",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Cari nama bank",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              modalBottomSheetProps: const ModalBottomSheetProps(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: "Pilih bank",
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            onChanged: (Bank? newValue) {
              setState(() {
                selectedBank = newValue;
                namaBankController.text = newValue?.namaBank ?? '';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildJudul(String judul, String hint, TextEditingController controller,
      {bool isNumber = false}) {
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
                    const SizedBox(width: 10),
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
              // Show count indicator for bank accounts
              Container(
                margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: Row(
                  children: [
                    Text(
                      "Rekening yang telah ditambahkan: $existingBankAccountsCount/3",
                      style: TextStyle(
                        fontSize: 14,
                        color: existingBankAccountsCount >= 3 ? Colors.red : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              buildBankDropdown("Nama Bank"),
              buildJudul("Nomor Rekening", 'Nomor Rekening', noRekController,
                  isNumber: true),
              buildJudul("Nama Pemilik", "Nama Pemilik", namaPemilikController),
              uploadDokumen("Buku Tabungan", (File? selectedFile) {
                setState(() {
                  _selectedBukuTabungan = selectedFile;
                });
              }),
              const SizedBox(height: 25),
              Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: existingBankAccountsCount >= 3 
                              ? null // Disable button if already reached max
                              : _saveBankAccount,
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: existingBankAccountsCount >= 3 
                                  ? Colors.grey // Grey out if max reached
                                  : const Color(0xFF2F2F9D)),
                            child: const Text("Simpan",
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF), fontSize: 14)),
                          ),
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class Bank {
  final String kodeBank;
  final String bankId;
  final String namaBank;

  Bank({
    required this.kodeBank,
    required this.bankId,
    required this.namaBank,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      kodeBank: json['kode_bank'],
      bankId: json['bank_id'] ?? '',
      namaBank: json['nama_bank'],
    );
  }
}