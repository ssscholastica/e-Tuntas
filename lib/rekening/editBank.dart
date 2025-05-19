import 'dart:convert';
import 'dart:io';

import 'package:etuntas/network/globals.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; 

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

  void _previewFile() async {
    if (_selectedFile != null) {
      OpenFile.open(_selectedFile!.path);
    } else if (_fileName != null && _fileName!.isNotEmpty) {
      final fileUrl = '${baseURLStorage}$_fileName';
      try {
        final url = Uri.parse(fileUrl);

        // Try to launch the URL externally
        bool launched = await launchUrl(
          url,
          mode: LaunchMode.externalNonBrowserApplication,
        );

        // If that fails, try to open in browser
        if (!launched) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        }
      } catch (e) {
        debugPrint('Could not launch $fileUrl: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka dokumen: $_fileName')),
        );

        // Fallback to showing dialog
        _showFilePreviewDialog();
      }
    }
  }

  void _showFilePreviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("File Preview"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("File: $_fileName",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                  "File ini tersimpan di server. Tidak dapat ditampilkan secara langsung."),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "URL: ${baseURL}dokumen/$_fileName",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
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
                    tooltip: "Lihat Dokumen",
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: _removeFile,
                    tooltip: "Hapus Dokumen",
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: _pickFile,
                  tooltip: "Pilih Dokumen",
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
  bool isLoading = false;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    debugPrint("DATA BANK ACCOUNTS: ${widget.bankAccounts}");
    namaBankController =
        TextEditingController(text: widget.bankAccounts?['Nama Bank']);
    noRekController =
        TextEditingController(text: widget.bankAccounts?['Nomor Rekening']);
    namaPemilikController =
        TextEditingController(text: widget.bankAccounts?['Nama Pemilik']);

    String? bukuTabunganPath = widget.bankAccounts?['Buku Tabungan'];
    if (bukuTabunganPath != null && bukuTabunganPath.isNotEmpty) {
      _uploadedFileName = bukuTabunganPath;
    } else {
      _uploadedFileName = null;
    }
  }

  void editRekening() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _handleFileSelected(String fileName, File? file) {
    setState(() {
      _uploadedFileName = fileName;
      _selectedFile = file;
    });
  }

  Widget uploadDokumen(String label, String? uploadedFileName) {
    return _UploadDokumen(
      label: label,
      initialValue: uploadedFileName,
      onFileSelected: _handleFileSelected,
    );
  }

  Future<void> _previewBukuTabungan() async {
    if (_selectedFile != null) {
      await OpenFile.open(_selectedFile!.path);
    } else if (_uploadedFileName != null && _uploadedFileName!.isNotEmpty) {
      final fileUrl = 'http://192.168.11.106:8000/$_uploadedFileName';
      try {
        final url = Uri.parse(fileUrl);

        bool launched = await launchUrl(
          url,
          mode: LaunchMode.externalNonBrowserApplication,
        );

        if (!launched) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        }
      } catch (e) {
        debugPrint('Could not launch $fileUrl: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Tidak dapat membuka dokumen: $_uploadedFileName')),
        );

        _showFilePreviewDialog();
      }
    }
  }

  void _showFilePreviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("File Preview"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("File: $_uploadedFileName",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                  "File ini tersimpan di server. Tidak dapat ditampilkan secara langsung."),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "URL: ${baseURL}dokumen/$_uploadedFileName",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  void _inspectBankAccountsData() {
    debugPrint("Bank Account Data Structure:");
    if (widget.bankAccounts == null) {
      debugPrint("  - bankAccounts is null");
      return;
    }

    widget.bankAccounts!.forEach((key, value) {
      debugPrint("  - $key: $value");
    });

    // Check specifically for ID
    if (widget.bankAccounts!.containsKey('id')) {
      debugPrint("ID found: ${widget.bankAccounts!['id']}");
    } else {
      debugPrint("ID not found in bankAccounts data");
    }
  }

  void _saveBankAccount() async {
    setState(() {
      isLoading = true;
    });

    _inspectBankAccountsData();

    final email = await getLoggedInUserEmail();
    final bankAccountId = await fetchBankAccountIdByEmail(email!);

    debugPrint("Bank Account ID: $bankAccountId");

    if (bankAccountId == null) {
      debugPrint("Error: Bank Account ID is null, cannot update");
      setState(() {
        isLoading = false;
      });

      _showDialog(
        success: false,
        title: "Error!",
        message: "ID rekening tidak ditemukan. Tidak dapat memperbarui data.",
        buttonText: "Kembali",
        onPressed: () {
          Navigator.pop(context); // close dialog
        },
      );
      return;
    }

    // Check if ID is available
    if (bankAccountId == null) {
      debugPrint("Error: Bank Account ID is null, cannot update");
      setState(() {
        isLoading = false;
      });

      _showDialog(
        success: false,
        title: "Error!",
        message: "ID rekening tidak ditemukan. Tidak dapat memperbarui data.",
        buttonText: "Kembali",
        onPressed: () {
          Navigator.pop(context); // close dialog
        },
      );
      return;
    }

    if (namaBankController.text.isEmpty || noRekController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Nama bank dan nomor rekening harus diisi!")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final headers = await getHeaders();
      String? finalFileName = _uploadedFileName;

      // Only upload file if a new file is selected
      if (_selectedFile != null) {
        final uploadResult = await uploadFile(_selectedFile!);

        if (uploadResult != null) {
          finalFileName = uploadResult;
        } else {
          throw Exception("Gagal mengunggah file");
        }
      }

      // Use ID from the edited account for the update endpoint
      final url = Uri.parse("${baseURL}rekening-bank/$bankAccountId");

      // Prepare request body - handle null fileName properly
      final Map<String, dynamic> requestData = {
        "nama_bank": namaBankController.text,
        "nomor_rekening": noRekController.text,
        "nama_pemilik": namaPemilikController.text,
      };

      // Only include buku_tabungan field if there is a filename
      if (finalFileName != null && finalFileName.isNotEmpty) {
        requestData["buku_tabungan"] = finalFileName;
      }

      final requestBody = jsonEncode(requestData);

      // Debugging logs
      debugPrint("Request URL: $url");
      debugPrint("Request Headers: $headers");
      debugPrint("Request Body: $requestBody");

      // Use PUT for update
      final response = await http.put(
        url,
        headers: headers,
        body: requestBody,
      );

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // Create updated data map with only non-null values
        final updatedData = {
          "id": bankAccountId,
          "Nama Bank": namaBankController.text,
          "Nomor Rekening": noRekController.text,
          "Nama Pemilik": namaPemilikController.text,
        };

        // Only add Buku Tabungan if it exists
        if (finalFileName != null && finalFileName.isNotEmpty) {
          updatedData["Buku Tabungan"] = finalFileName;
        }

        _showDialog(
          success: true,
          title: "Tersimpan!",
          message: "Data Rekening berhasil diubah",
          buttonText: "Oke",
          onPressed: () {
            Navigator.pop(context); // close dialog
            Navigator.pop(context, updatedData); // return with updated data
          },
        );
      } else {
        Map<String, dynamic> errorResponse;
        try {
          errorResponse = json.decode(response.body);
        } catch (e) {
          errorResponse = {"message": "Gagal memproses respons server"};
        }

        _showDialog(
          success: false,
          title: "Gagal!",
          message: errorResponse['message'] ?? "Gagal menyimpan data rekening",
          buttonText: "Coba Lagi",
          onPressed: () {
            Navigator.pop(context); // close dialog
          },
        );
      }
    } catch (e) {
      debugPrint("Error saving bank account: $e");
      _showDialog(
        success: false,
        title: "Error!",
        message: "Terjadi kesalahan: $e",
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

  Future<String?> fetchBankAccountIdByEmail(String email) async {
    final headers = await getHeaders();
    final url = Uri.parse("${baseURL}rekening-bank/email/$email");

    try {
      final response = await http.get(url, headers: headers);
      debugPrint("Fetch by email response status: ${response.statusCode}");
      debugPrint("Fetch by email response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['id']?.toString(); // pastikan ID dikembalikan
      }
    } catch (e) {
      debugPrint("Error fetching bank account by email: $e");
    }

    return null;
  }


  Future<String?> getLoggedInUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email'); 
  }


  Future<String?> uploadFile(File file) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('${baseURL}upload'));

      // Add authorization headers
      final headers = await getHeaders();
      request.headers.addAll(headers);

      // Add file to request
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();

      final multipartFile = http.MultipartFile(
        'file', // parameter name expected by server
        fileStream,
        fileLength,
        filename: path.basename(file.path),
      );

      request.files.add(multipartFile);

      // Debug information
      debugPrint("Upload URL: ${request.url}");
      debugPrint("Upload Headers: ${request.headers}");
      debugPrint(
          "Uploading file: ${path.basename(file.path)} (${fileLength} bytes)");

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("Upload Status Code: ${response.statusCode}");
      debugPrint("Upload Response: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          final filename = responseData['filename'];

          if (filename != null && filename is String && filename.isNotEmpty) {
            debugPrint("File uploaded successfully: $filename");
            return filename;
          } else {
            debugPrint("Invalid filename in response: $responseData");
            return null;
          }
        } catch (e) {
          debugPrint("Error parsing JSON response: $e");
          return null;
        }
      } else {
        debugPrint(
            "Failed to upload file. Status: ${response.statusCode}, Body: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error during file upload: $e");
      return null;
    }
  }

  Future<void> deleteRekening() async {
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
                  // Dapatkan token
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('access_token');

                  if (token == null || token.isEmpty) {
                    setState(() {
                      isLoading = false;
                    });

                    if (mounted) {
                      _showDialog(
                        success: false,
                        title: "Error!",
                        message:
                            "Token tidak ditemukan. Silahkan login kembali.",
                        buttonText: "OK",
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigasi ke halaman login
                          // Navigator.pushReplacementNamed(context, '/login');
                        },
                      );
                    }
                    return;
                  }

                  final id = widget.bankAccounts?['id'];

                  if (id == null) {
                    setState(() {
                      isLoading = false;
                    });

                    if (mounted) {
                      _showDialog(
                        success: false,
                        title: "Error!",
                        message: "ID rekening tidak ditemukan",
                        buttonText: "OK",
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      );
                    }
                    return;
                  }

                  final headers = await getHeaders();
                  final response = await http.delete(
                    Uri.parse('${baseURL}rekening-bank/$id'),
                    headers: headers,
                  );

                  print("Delete response code: ${response.statusCode}");
                  print("Delete response body: ${response.body}");

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
                          // Kirim hasil ke halaman sebelumnya untuk refresh data
                          Navigator.pop(context, {"deleted": true});
                        },
                      );
                    }
                  } else if (response.statusCode == 401) {
                    // Token expired atau tidak valid
                    if (mounted) {
                      _showDialog(
                        success: false,
                        title: "Gagal!",
                        message:
                            "Sesi anda telah berakhir. Silahkan login kembali.",
                        buttonText: "OK",
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigasi ke halaman login
                          // Navigator.pushReplacementNamed(context, '/login');
                        },
                      );
                    }
                  } else {
                    // Error lainnya
                    var decodedResponse = json.decode(response.body);
                    if (mounted) {
                      _showDialog(
                        success: false,
                        title: "Gagal!",
                        message: decodedResponse['message'] ??
                            "Gagal menghapus rekening",
                        buttonText: "Coba Lagi",
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      );
                    }
                  }
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
                  print("Error saat menghapus: $e");
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

  Widget buildFilePath(String judul, String? filePath) {
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
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextFormField(
                  readOnly: true,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: filePath ?? "Tidak ada file",
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (filePath != null && filePath.isNotEmpty)
                  Positioned(
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.blue),
                      onPressed: _previewBukuTabungan,
                      tooltip: "Lihat Dokumen",
                    ),
                  ),
              ],
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
                  isEditing
                      ? uploadDokumen("Buku Tabungan", _uploadedFileName)
                      : buildFilePath("Buku Tabungan", _uploadedFileName),
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
                                : () => deleteRekening(),
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
