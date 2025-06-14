# E-Tuntas – Aplikasi Pengajuan Santunan Pensiunan dan Pengaduan BPJS

Aplikasi ini terhubung langsung ke backend Laravel melalui REST API dan menggunakan Firebase untuk notifikasi real-time.

# Fitur Utama:
- Autentikasi dengan email
- Pengajuan santunan
- Pengaduan BPJS
- Tracking status pengajuan
- Tracking status pengaduan
- Notifikasi status via Firebase Cloud Messaging
- Komentar & balasan antara user dan admin
- Tampilan dokumen PDF di external aplikasi
- Input data rekening bank

# Teknologi:
- Frontend: Flutter (Dart)
- Backend: Laravel REST API (terpisah dari repository ini)
- Push Notification: Firebase Cloud Messaging (FCM)
- PDF Viewer: DirectPDFViewer
- SharedPreferences untuk penyimpanan lokal

# Cara Menjalankan:
**Clone repository:**  
git clone https://github.com/ssscholastica/e-Tuntas.git  
cd e-Tuntas  
  
**Install dependency:**  
flutter pub get  

**Jalankan emulator atau hubungkan perangkat lalu:**  
flutter run
  
Pastikan kamu sudah mengatur baseUrl di file globals.dart untuk mengarah ke server backend Laravel-mu.
