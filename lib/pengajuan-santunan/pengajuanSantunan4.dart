import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:etuntas/pengajuan-santunan/pengajuanSantunan.dart';
import 'package:etuntas/pengajuan-santunan/successUpload.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

class PengajuanSantunan4 extends StatefulWidget {
  const PengajuanSantunan4({super.key});

  @override
  State<PengajuanSantunan4> createState() => _PengajuanSantunan4State();
}

class _PengajuanSantunan4State extends State<PengajuanSantunan4> {
  @override
  void initState() {
    super.initState();
  }

  TextEditingController tanggalMeninggalController = TextEditingController();
  TextEditingController lokasiMeninggalController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        tanggalMeninggalController.text =
            DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  final List<String> lokasiList = [
    "Kabupaten Jember",
    "Kabupaten Lumajang",
    "Kota Surabaya",
    "Kota Banyuwangi",
    "Kabupaten Madiun"
  ];
  String? selectedLokasi;

  bool _validateForm() {
    return tanggalMeninggalController.text.isNotEmpty &&
        selectedLokasi != null &&
        _validateFiles();
  }

  bool _validateFiles() {
    return fileUploadKeys
        .every((key) => key.currentState?._selectedFile != null);
  }

  final List<GlobalKey<_FileUploadFieldState>> fileUploadKeys = [
    GlobalKey<_FileUploadFieldState>(),
    GlobalKey<_FileUploadFieldState>(),
    GlobalKey<_FileUploadFieldState>(),
    GlobalKey<_FileUploadFieldState>(),
    GlobalKey<_FileUploadFieldState>(),
    GlobalKey<_FileUploadFieldState>(),
  ];

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PengajuanSantunan()),
                      );
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
                'Yang Meninggal Pensiunan PTPN XI Kantor Pusat dan Istri Sudah Meninggal, Dalam KK Hanya Pensiunan Sendiri (Tidak Ada Anak Karena Sudah Pecah KK',
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
            FileUploadField(key: fileUploadKeys[0], label: "Surat Kematian"),
            FileUploadField(key: fileUploadKeys[1], label: "Surat Keterangan"),
            FileUploadField(key: fileUploadKeys[2], label: "Surat Kuasa"),
            FileUploadField(key: fileUploadKeys[3], label: "Kartu Keluarga"),
            FileUploadField(
                key: fileUploadKeys[4], label: "KTP Pensiunan dan Anak"),
            FileUploadField(
                key: fileUploadKeys[5], label: "Buku Rekening Anak"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_validateForm()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SuccesUpload()),
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
                    context: context,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 160, vertical: 15),
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
                        ? Color.fromARGB(255, 18, 18, 162)
                        : Color.fromARGB(170, 231, 0, 23),
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
