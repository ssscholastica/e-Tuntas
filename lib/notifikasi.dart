import 'dart:async';
import 'package:etuntas/models/notification_model.dart';
import 'package:etuntas/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> _notifications = [];
  bool _loading = true;
  String? token;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTokenAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access_token'); // pastikan token tersimpan saat login

    if (token != null) {
      await _fetchNotifications();
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final notifs = await NotificationService.fetchNotifications(token!);
      setState(() {
        _notifications = notifs;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (token != null) {
        _fetchNotifications();
      }
    });
  }

  Future<void> _markAsRead(int id) async {
    try {
      await NotificationService.markAsRead(id, token!);
      await _fetchNotifications();
    } catch (e) {
      debugPrint('Gagal menandai notifikasi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              child: _notifications.isEmpty
                  ? const Center(child: Text('Tidak ada notifikasi'))
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        return ListTile(
                          leading: notif.isRead
                              ? const Icon(Icons.notifications_none)
                              : const Icon(Icons.notifications_active,
                                  color: Colors.blue),
                          title: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: notif.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(notif.message),
                          trailing: notif.isRead
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () => _markAsRead(notif.id),
                                ),
                        );
                      },
                    ),
            ),
    );
  }
}
