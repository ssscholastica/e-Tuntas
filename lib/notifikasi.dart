import 'package:flutter/material.dart';

class NotifPage extends StatelessWidget {
  NotifPage({super.key});

  final List<NotificationModel> notifications = [
    NotificationModel(
      icon: Icons.cancel,
      title: "Pengaduan BPJS Ditolak",
      description: "Proses Ajuan anda berhasil terkirim. Silahkan cek email untuk melihat ulang nomor pendaftaran. Tunggu informasi selanjutnya",
      date: "Hari ini",
      time: "08:24 WIB",
      color: Colors.red,
    ),
    NotificationModel(
      icon: Icons.mark_email_read_outlined,
      title: "Pengaduan BPJS Berhasil Terkirim",
      description: "Proses Ajuan anda berhasil terkirim. Silahkan cek email untuk melihat ulang nomor pendaftaran.",
      date: "Kemarin",
      time: "08:24 WIB",
      color: Colors.blue,
    ),
    NotificationModel(
      icon: Icons.credit_score,
      title: "Dana Telah Dikirimkan",
      description: "Proses Ajuan anda berhasil terkirim. Silahkan cek email untuk melihat ulang nomor pendaftaran.",
      date: "12 Des",
      time: "08:24 WIB",
      color: Colors.green,
    ),
    NotificationModel(
      icon: Icons.check,
      title: "Pengajuan Santunan Diterima",
      description: "Proses Ajuan anda berhasil terkirim. Silahkan cek email untuk melihat ulang nomor pendaftaran.",
      date: "11 Des",
      time: "08:24 WIB",
      color: Colors.green,
    ),
    NotificationModel(
      icon: Icons.watch_later_outlined,
      title: "Pengajuan Santunan Sedang Diverifikasi",
      description: "Proses Ajuan anda berhasil terkirim. Silahkan cek email untuk melihat ulang nomor pendaftaran.",
      date: "11 Des",
      time: "10:50 WIB",
      color: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
                const SizedBox(width: 10),
                const Text(
                  "Notifikasi",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0XFF000000),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 20, thickness: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationItem(notification: notification);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(notification.icon, color: notification.color, size: 30),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    notification.date,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                notification.description,
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                notification.time,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NotificationModel {
  final IconData icon;
  final String title;
  final String description;
  final String date;
  final String time;
  final Color color;

  NotificationModel({
    required this.icon,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.color,
  });
}