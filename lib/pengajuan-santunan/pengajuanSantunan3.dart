import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:etuntas/network/globals.dart';
import 'package:etuntas/network/wilayah_service.dart';
import 'package:etuntas/pengajuan-santunan/successUpload.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PengajuanSantunan3 extends StatefulWidget {
  final String namaPTPN;
  final String lokasiList;

  PengajuanSantunan3({required this.namaPTPN, required this.lokasiList, super.key});

  @override
  State<PengajuanSantunan3> createState() => _PengajuanSantunan3State();
}

class _PengajuanSantunan3State extends State<PengajuanSantunan3> {
  @override
  void initState() {
    super.initState();
    fetchKota();
  }

  TextEditingController tanggalMeninggalController = TextEditingController();
  TextEditingController lokasiMeninggalController = TextEditingController();
  TextEditingController ptpnController = TextEditingController();
  TextEditingController lokasiController = TextEditingController();
  List<String> lokasiList = [];
  bool isLoadingKota = true;
  bool isLoading = false; 

  Future<void> fetchKota() async {
    try {
      final kotaList = await WilayahService.fetchKota();

      setState(() {
        lokasiList = kotaList.whereType<String>().toList();
        isLoadingKota = false;
      });
    } catch (e) {
      print("Error saat ambil data kota: $e");
    }
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        tanggalMeninggalController.text = formattedDate.trim();
      });
    }
  }

  Future<void> uploadSantunan() async {
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
        context: context,
      );
      return;
    }

    try {
      final uri = Uri.parse('${baseURL}pengajuan-santunan3');
      final request = http.MultipartRequest('POST', uri);
      final headers = await getHeaders();

      request.headers.addAll(headers);

      request.fields['email'] = email;
      debugPrint("Request fields: ${request.fields}");

      request.fields['tanggal_meninggal'] =
          tanggalMeninggalController.text.trim();

      debugPrint(
          "Tanggal meninggal yang dikirim: ${request.fields['tanggal_meninggal']}");

      request.fields['lokasi_meninggal'] = selectedLokasi ?? '';

      request.fields['ptpn'] = widget.namaPTPN;
      request.fields['lokasi'] = widget.lokasiList;
      request.fields['send_email'] = 'true';

      debugPrint("Request fields: ${request.fields}");

      request.files.add(await http.MultipartFile.fromPath(
        'surat_kematian',
        suratKematianKey.currentState!.getSelectedFile()!.path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'kartu_keluarga',
        kartuKeluargaKey.currentState!.getSelectedFile()!.path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'surat_kuasa',
        suratKuasaKey.currentState!.getSelectedFile()!.path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'ktp_pensiunan_anak',
        ktpPensiunanAnakKey.currentState!.getSelectedFile()!.path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'buku_rekening_anak',
        bukuRekeningAnakKey.currentState!.getSelectedFile()!.path,
      ));

      final response = await request.send();
      final resStr = await response.stream.bytesToString();

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: $resStr");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(resStr);
        final noPendaftaran = jsonResponse['no_pendaftaran'] ?? '';
        await _sendEmailWithRegistrationNumber(email, noPendaftaran);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SuccesUpload(noPendaftaran: noPendaftaran)),
        );
      } else {
        String errorMessage =
            "Terjadi kesalahan saat mengupload. Silakan coba lagi.";
        try {
          final jsonResponse = json.decode(resStr);
          if (jsonResponse['message'] != null) {
            errorMessage = jsonResponse['message'];
          }
        } catch (e) {
          debugPrint("Gagal parsing response JSON: $e");
        }

        _showDialog(
          success: false,
          title: "Gagal Upload!",
          message: errorMessage,
          buttonText: "Coba Lagi",
          onPressed: () => Navigator.pop(context),
          context: context,
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String? selectedLokasi;

  bool _validateForm() {
    return tanggalMeninggalController.text.isNotEmpty &&
        selectedLokasi != null &&
        _validateFiles();
  }

  bool _validateFiles() {
    final fields = [
      suratKematianKey.currentState,
      kartuKeluargaKey.currentState,
      suratKuasaKey.currentState,
      ktpPensiunanAnakKey.currentState,
      bukuRekeningAnakKey.currentState,
    ];

    for (var field in fields) {
      if (field == null || field.getSelectedFile() == null) {
        return false;
      }
    }
    return true;
  }

  final GlobalKey<_FileUploadFieldState> suratKematianKey =
      GlobalKey<_FileUploadFieldState>();
  final GlobalKey<_FileUploadFieldState> kartuKeluargaKey =
      GlobalKey<_FileUploadFieldState>();
  final GlobalKey<_FileUploadFieldState> suratKuasaKey =
      GlobalKey<_FileUploadFieldState>();
  final GlobalKey<_FileUploadFieldState> ktpPensiunanAnakKey =
      GlobalKey<_FileUploadFieldState>();
  final GlobalKey<_FileUploadFieldState> bukuRekeningAnakKey =
      GlobalKey<_FileUploadFieldState>();

  Widget buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tanggal Meninggal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: TextField(
              controller: controller,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                hintText: 'Tanggal Meninggal',
                hintStyle: const TextStyle(fontSize: 15, color: Colors.grey),
                contentPadding:
                    const EdgeInsets.only(top: 5, bottom: 5, left: 10),
                suffixIcon:
                    const Icon(Icons.calendar_today, color: Colors.black),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildJudul(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lokasi Meninggal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          DropdownSearch<String>(
            items: lokasiList,
            selectedItem: selectedLokasi,
            popupProps: PopupProps.menu(
              showSearchBox: true,
              fit: FlexFit.loose,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: "Lokasi Meninggal",
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.only(top: 5, bottom: 5, left: 10),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey)),
              ),
            ),
            onChanged: (String? newValue) {
              setState(() {
                selectedLokasi = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 60, left: 20, right: 20),
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
                    "Proses Pengajuan Santunan",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0XFF000000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              margin: const EdgeInsets.only(top: 30, left: 20, right: 20),
              child: const Text(
                'Yang Meninggal Pensiunan PTPN XI Kantor Pusat dan Istri Sudah Meninggal, Dalam KK Ada Beberapa Anak',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0XFF26267E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            buildDatePickerField(
                "Tanggal Meninggal", tanggalMeninggalController),
            buildJudul("Lokasi Meninggal", lokasiMeninggalController),
            FileUploadField(key: suratKematianKey, label: "Surat Kematian"),
            FileUploadField(key: kartuKeluargaKey, label: "Kartu Keluarga"),
            FileUploadField(key: suratKuasaKey, label: "Surat Kuasa"),
            FileUploadField(key: ktpPensiunanAnakKey, label: "KTP Pensiunan & Anak"),
            FileUploadField(
                key: bukuRekeningAnakKey, label: "Buku Rekening Anak"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_validateForm()) {
                  uploadSantunan();
                } else {
                  _showDialog(
                    success: false,
                    title: "Gagal!",
                    message: "Terjadi kesalahan...",
                    buttonText: "Reupload",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    context: context,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                  EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.37,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: const Color(0xFF2F2F9D),
              ),
              child: const Text(
                "Upload",
                style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

Future<void> _sendEmailWithRegistrationNumber(
    String email, String noPendaftaran) async {
  try {
    final uri = Uri.parse('${baseURL}pengajuan-santunan3');
    final headers = await getHeaders();
    final response = await http.post(
      uri,
      headers: headers,
      body: json.encode({
        'email': email,
        'no_pendaftaran': noPendaftaran,
        'subject': 'Informasi Nomor Pendaftaran',
        'message':
            'Terima kasih telah mendaftar. Nomor pendaftaran Anda adalah: $noPendaftaran'
      }),
    );

    if (response.statusCode == 200) {
      debugPrint("Email sent successfully");
    } else {
      debugPrint("Failed to send email: ${response.body}");
    }
  } catch (e) {
    debugPrint("Error sending email: $e");
  }
}

void _showDialog({
  required bool success,
  required BuildContext context,
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

class FileUploadField extends StatefulWidget {
  final String label;

  const FileUploadField({super.key, required this.label});

  @override
  _FileUploadFieldState createState() => _FileUploadFieldState();
}

class _FileUploadFieldState extends State<FileUploadField> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

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

  File? getSelectedFile() => _selectedFile;

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
              border: Border.all(color: Colors.grey),
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
                          : "No file chosen",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
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
                  icon: const Icon(Icons.attach_file, color: Colors.black),
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
