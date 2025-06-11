import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationModel {
  final IconData icon;
  final String title;
  final String description;
  final String date;
  final String time;
  final Color color;
  final String category;
  final String statusType;

  NotificationModel({
    required this.icon,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.color,
    required this.category,
    required this.statusType,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Tambahan: List dan StreamController untuk notifikasi
  final List<NotificationModel> _notifications = [];
  final StreamController<List<NotificationModel>> _notificationsController =
      StreamController<List<NotificationModel>>.broadcast();

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  Stream<List<NotificationModel>> get notificationsStream => _notificationsController.stream;

  // Tambahan: Grouping notifikasi
  Map<String, List<NotificationModel>> getGroupedNotifications() {
    final Map<String, List<NotificationModel>> grouped = {};
    for (var notif in _notifications) {
      grouped.putIfAbsent(notif.category, () => []).add(notif);
    }
    return grouped;
  }

  // Tambahan: Load dummy notifications (atau dari storage)
  Future<void> loadNotifications() async {
    // Dummy data, bisa diganti dengan load dari storage
    _notifications.clear();
    _notifications.addAll([
      NotificationModel(
        icon: Icons.notifications,
        title: "Contoh Notifikasi",
        description: "Ini adalah notifikasi contoh.",
        date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        time: DateFormat('HH:mm').format(DateTime.now()),
        color: Colors.blue,
        category: "Umum",
        statusType: "info",
      ),
    ]);
    _notificationsController.add(List.unmodifiable(_notifications));
  }

  // Tambahan: Clear notifications
  void clearNotifications() {
    _notifications.clear();
    _notificationsController.add(List.unmodifiable(_notifications));
  }

  // Tambahan: Dispose
  void dispose() {
    _notificationsController.close();
  }

  // ... (method initialize, _saveFcmToken, _sendTokenToServer, dsb tetap sama)

  // Handle incoming foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // If notification is present, show local notification
    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }

    // Process the notification data
    _processStatusUpdate(message.data);

    // Tambahan: Simpan ke list notifikasi
    _addNotificationFromData(message.data);
  }


  // Fungsi untuk memproses data status dari notifikasi
  void _processStatusUpdate(Map<String, dynamic> data) {
    // Contoh: cek jika ada field 'status' dan lakukan sesuatu
    if (data.containsKey('status')) {
      String status = data['status'];
      // Lakukan aksi sesuai status, misal logika update UI, dsb.
      debugPrint('Status update received: $status');
      // Bisa juga trigger event lain jika diperlukan
    }
  }
  // Tambahan: Method untuk menambah notifikasi ke list
  void _addNotificationFromData(Map<String, dynamic> data) {
    // Contoh mapping, sesuaikan dengan data sebenarnya
    final notif = NotificationModel(
      icon: Icons.notifications,
      title: data['title'] ?? 'Notifikasi',
      description: data['body'] ?? '',
      date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      time: DateFormat('HH:mm').format(DateTime.now()),
      color: Colors.blue,
      category: data['category'] ?? 'Umum',
      statusType: data['status'] ?? '',
    );
    _notifications.insert(0, notif);
    _notificationsController.add(List.unmodifiable(_notifications));
  }

  // ... (method _processStatusUpdate, _onSelectNotification, _navigateBasedOnNotification tetap sama)
}

// ... (StatusData, notificationStreamController, _firebaseMessagingBackgroundHandler, NotificationListener tetap sama)

// Tambahan: StatusMonitorService dummy
class StatusMonitorService {
  final ApiService apiService;
  final NotificationService notificationService;
  Timer? _timer;

  StatusMonitorService(this.apiService, this.notificationService);

  void startMonitoring() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), () async {
    } as void Function(Timer timer));
  }

  void dispose() {
    _timer?.cancel();
  }
}
class ApiService {
  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    await Future.delayed(Duration(seconds: 1));
    return {
      'title': 'Status Update',
      'body': 'Ada perubahan status pada $endpoint',
      'category': 'Update',
      'status': 'updated',
    };
  }
}

class NotifPage extends StatefulWidget {
  const NotifPage({Key? key}) : super(key: key);

  @override
  State<NotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _notificationService.loadNotifications();
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _notificationService.clearNotifications();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationService.notificationsStream,
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text('Tidak ada notifikasi.'));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return NotificationItem(notification: notif);
            },
          );
        },
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.color,
          child: Icon(notification.icon, color: Colors.white),
        ),
        title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${notification.date} ${notification.time}', style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Chip(
                  label: Text(notification.category, style: const TextStyle(fontSize: 10)),
                  backgroundColor: notification.color.withOpacity(0.2),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
        trailing: notification.statusType.isNotEmpty
            ? Chip(
                label: Text(notification.statusType, style: const TextStyle(fontSize: 10)),
                backgroundColor: Colors.grey.shade200,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              )
            : null,
      ),
    );
  }
}