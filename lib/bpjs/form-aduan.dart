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
  bool isLoadingNIK = false;
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    controllers["Tanggal Ajuan"] = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    controllers["NIK"] = TextEditingController();
    controllers["Deskripsi"] = TextEditingController();
    controllers["Kategori"] = TextEditingController(text: widget.kategori);

    // Fetch user NIK on initialization
    fetchUserNIK();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  // Updated fetchUserNIK method with better debugging and error handling
  Future<void> fetchUserNIK() async {
    setState(() {
      isLoadingNIK = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      final token = prefs.getString('access_token'); 

      if (email == null || email.isEmpty) {
        debugPrint("Email tidak ditemukan di SharedPreferences.");
        _showNIKError("Email pengguna tidak ditemukan. Silakan login kembali.");
        return;
      }

      // Debug token info
      debugPrint("Fetching NIK for email: $email");
      debugPrint("Auth token exists: ${token != null}");
      debugPrint("Token preview: ${token?.substring(0, 20) ?? 'null'}...");

      final headers = await getHeaders();
      debugPrint("Headers being sent: $headers");

      // Use the existing route with email as query parameter
      final response = await http.get(
        Uri.parse('${baseURL}user/get-nikBPJS?email=${Uri.encodeComponent(email)}'),
        headers: headers,
      );

      debugPrint("NIK fetch response status: ${response.statusCode}");
      debugPrint("NIK fetch response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        String nik = '';
        if (data is Map<String, dynamic>) {
          if (data['success'] == true) {
            nik = data['nik']?.toString() ?? '';
          } else {
            _showNIKError(data['message'] ?? 'NIK tidak ditemukan');
            return;
          }
        }

        setState(() {
          controllers["NIK"]?.text = nik;
        });

        if (nik.isEmpty) {
          _showNIKError("NIK tidak ditemukan untuk user ini.");
        } else {
          debugPrint("NIK berhasil diambil: $nik");
        }
      } else if (response.statusCode == 401) {
        // Handle authentication error specifically
        debugPrint("Authentication failed - token might be expired or invalid");
        _showAuthError("Sesi Anda telah berakhir. Silakan login kembali.");
      } else if (response.statusCode == 403) {
        // Handle authorization error
        debugPrint("Unauthorized access to NIK");
        _showNIKError("Anda tidak memiliki akses untuk mengambil NIK ini.");
      } else if (response.statusCode == 404) {
        debugPrint("User atau NIK tidak ditemukan: ${response.statusCode}");
        _showNIKError("User tidak ditemukan atau NIK belum diatur.");
      } else {
        debugPrint("Gagal mengambil NIK: ${response.statusCode}");
        String errorMessage = "Gagal mengambil data NIK";

        try {
          final errorData = json.decode(response.body);
          if (errorData is Map<String, dynamic> &&
              errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          debugPrint("Error parsing error response: $e");
        }

        _showNIKError(errorMessage);
      }
    } catch (e) {
      debugPrint("Error mengambil NIK: $e");
      _showNIKError("Terjadi kesalahan saat mengambil data NIK: $e");
    } finally {
      setState(() {
        isLoadingNIK = false;
      });
    }
  }

// Add this new method to handle authentication errors
  void _showAuthError(String message) {
    setState(() {
      controllers["NIK"]?.text = '';
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sesi Berakhir'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login page or clear stored credentials
              _handleLogout();
            },
            child: const Text('Login Ulang'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              fetchUserNIK(); // Retry once
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

// Add this method to handle logout
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data

    // Navigate to login page
    // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    // Or however you handle navigation to login in your app
  }

  void _showNIKError(String message) {
    setState(() {
      controllers["NIK"]?.text = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: fetchUserNIK,
        ),
      ),
    );
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final email = await getUserEmail();
      debugPrint("Retrieved email from SharedPreferences: $email");

      if (email == null || email.isEmpty) {
        debugPrint("Email tidak ditemukan dalam SharedPreferences.");
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
      String nik = controllers["NIK"]!.text;

      // Validation
      if (tanggalAjuan.isEmpty) {
        _showValidationError("Tanggal ajuan tidak boleh kosong");
        return;
      }
      if (nik.isEmpty) {
        _showValidationError("NIK tidak boleh kosong");
        return;
      }
      if (deskripsi.isEmpty) {
        _showValidationError("Deskripsi tidak boleh kosong");
        return;
      }
      if (_selectedFile == null) {
        _showValidationError("Data pendukung harus dipilih");
        return;
      }

      final headers = await getHeaders();
      var uri = Uri.parse('${baseURL}pengaduan-bpjs/');
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(headers);

      // Add fields
      request.fields['email'] = email;
      request.fields['kategori_bpjs'] = controllers["Kategori"]!.text;
      request.fields['tanggal_ajuan'] = tanggalAjuan;
      request.fields['nomor_bpjs_nik'] = nik;
      request.fields['deskripsi'] = deskripsi;
      request.fields['send_email'] = 'true';

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'data_pendukung',
        _selectedFile!.path,
      ));

      debugPrint("Request fields: ${request.fields}");

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
          debugPrint("Gagal decode JSON: $e");
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
      debugPrint("Error during form submission: $e");
      _showDialog(
        success: false,
        title: "Error",
        message: "Terjadi kesalahan: $e",
        buttonText: "Kembali",
        onPressed: () => Navigator.pop(context),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showValidationError(String message) {
    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
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

  Widget buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
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
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(
                vertical: isLandscape ? 6 : 8, horizontal: 12),
            suffixIcon: readOnly && label == "NIK" && isLoadingNIK
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
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
                              hint: isLoadingNIK
                                  ? "Mengambil NIK..."
                                  : "NIK akan diambil otomatis",
                              controller: controllers["NIK"]!,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'NIK tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            buildTextField(
                              label: "Deskripsi",
                              hint: "Masukkan deskripsi aduan",
                              controller: controllers["Deskripsi"]!,
                              maxLines: isLandscape ? 3 : 4,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Deskripsi tidak boleh kosong';
                                }
                                return null;
                              },
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
                                  onPressed: (isLoading || isLoadingNIK)
                                      ? null
                                      : submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2F2F9D),
                                    disabledBackgroundColor: Colors.grey,
                                    padding: EdgeInsets.symmetric(
                                        vertical: isLandscape ? 10 : 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    isLoadingNIK
                                        ? "Mengambil Data..."
                                        : "Kirim",
                                    style: const TextStyle(
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
