import 'package:etuntas/network/globals.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// API Service for handling API requests
class ApiService {

  // Headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Fetch data from an endpoint
  Future<List<dynamic>> fetchData(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseURL/$endpoint'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        print('Error fetching data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception fetching data: $e');
      return [];
    }
  }

  // Fetch a specific record
  Future<Map<String, dynamic>> fetchRecord(String endpoint, String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseURL/$endpoint/$id'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? {};
      } else {
        print('Error fetching record: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Exception fetching record: $e');
      return {};
    }
  }
}

// Status data class
class StatusData {
  final String tableName;
  final String id;
  final String status;
  final String updatedAt;
  
  StatusData({
    required this.tableName,
    required this.id,
    required this.status,
    required this.updatedAt,
  });
}

// Status monitoring service
class StatusMonitorService {
  final ApiService _apiService;
  final NotificationService _notificationService;
  
  // Map to store the latest status of each item
  final Map<String, Map<String, String>> _lastKnownStatuses = {
    'pengaduan-bpjs': {},
    'pengajuan-santunan1': {},
    'pengajuan-santunan2': {},
    'pengajuan-santunan3': {},
    'pengajuan-santunan4': {},
    'pengajuan-santunan5': {},
  };
  
  Timer? _pollingTimer;
  final Duration _pollingInterval = const Duration(minutes: 1); // Poll every minute
  
  StatusMonitorService(this._apiService, this._notificationService);
  
  // Start monitoring statuses
  void startMonitoring() {
    // Do an initial check
    _checkAllStatuses();
    
    // Set up periodic polling
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => _checkAllStatuses());
  }
  
  // Check statuses for all tables
  Future<void> _checkAllStatuses() async {
    await Future.wait([
      _checkTableStatuses('pengaduan-bpjs'),
      _checkTableStatuses('pengajuan-santunan1'),
      _checkTableStatuses('pengajuan-santunan2'),
      _checkTableStatuses('pengajuan-santunan3'),
      _checkTableStatuses('pengajuan-santunan4'),
      _checkTableStatuses('pengajuan-santunan5'),
    ]);
  }
  
  // Check statuses for a specific table
  Future<void> _checkTableStatuses(String tableName) async {
    try {
      final items = await _apiService.fetchData(tableName);
      
      for (var item in items) {
        final String id = item['id'].toString();
        final String currentStatus = item['status'] ?? '';
        final String updatedAt = item['updated_at'] ?? '';
        
        // Check if we have a record of this item
        if (!_lastKnownStatuses[tableName]!.containsKey(id)) {
          // New item, store its status
          _lastKnownStatuses[tableName]![id] = currentStatus;
        } 
        // Check if status has changed
        else if (_lastKnownStatuses[tableName]![id] != currentStatus) {
          // Status changed, create notification
          _createStatusChangeNotification(
            StatusData(
              tableName: tableName,
              id: id,
              status: currentStatus,
              updatedAt: updatedAt,
            ),
          );
          
          // Update the stored status
          _lastKnownStatuses[tableName]![id] = currentStatus;
        }
      }
    } catch (e) {
      print('Error checking $tableName statuses: $e');
    }
  }
  
  void _createStatusChangeNotification(StatusData statusData) {
    String formattedDate = _formatDate(statusData.updatedAt);
    String formattedTime = _formatTime(statusData.updatedAt);
    NotificationModel notification;
    String category;
    
    if (statusData.tableName == 'pengaduan-bpjs') {
      category = 'BPJS';
      
      switch (statusData.status.toLowerCase()) {
        case 'ditolak':
          notification = NotificationModel(
            icon: Icons.cancel,
            title: "Pengaduan BPJS Ditolak",
            description: "Pengaduan BPJS anda ditolak. Silahkan cek email untuk informasi lebih lanjut.",
            date: formattedDate,
            time: formattedTime,
            color: Colors.red,
            category: category,
            statusType: 'rejected',
          );
          break;
        case 'diterima':
          notification = NotificationModel(
            icon: Icons.check_circle,
            title: "Pengaduan BPJS Diterima",
            description: "Pengaduan BPJS anda telah diterima. Proses akan dilanjutkan.",
            date: formattedDate,
            time: formattedTime,
            color: Colors.green,
            category: category,
            statusType: 'approved',
          );
          break;
        case 'terkirim':
          notification = NotificationModel(
            icon: Icons.mark_email_read_outlined,
            title: "Pengaduan BPJS Berhasil Terkirim",
            description: "Pengaduan BPJS anda berhasil terkirim. Silahkan cek email untuk melihat ulang nomor pendaftaran.",
            date: formattedDate,
            time: formattedTime,
            color: Colors.blue,
            category: category,
            statusType: 'sent',
          );
          break;
        case 'diproses':
          notification = NotificationModel(
            icon: Icons.hourglass_top,
            title: "Pengaduan BPJS Sedang Diproses",
            description: "Pengaduan BPJS anda sedang diproses. Harap menunggu informasi selanjutnya.",
            date: formattedDate,
            time: formattedTime,
            color: Colors.orange,
            category: category,
            statusType: 'processing',
          );
          break;
        default:
          notification = NotificationModel(
            icon: Icons.info_outline,
            title: "Update Pengaduan BPJS",
            description: "Status pengaduan BPJS anda telah diperbarui menjadi '${statusData.status}'.",
            date: formattedDate,
            time: formattedTime,
            color: Colors.blue,
            category: category,
            statusType: 'update',
          );
      }
    } else if (statusData.tableName.startsWith('pengajuan-santunan')) {
      category = 'Santunan';
      String santunanType = statusData.tableName.replaceAll('pengajuan-santunan', '');
      if (santunanType.isNotEmpty) {
        category = 'Santunan $santunanType';
      }
      
      switch (statusData.status.toLowerCase()) {
        case 'diterima':
          notification = NotificationModel(
            icon: Icons.check,
            title: "Pengajuan Santunan Diterima",
            description: "Pengajuan santunan anda telah diterima. Proses pencairan akan segera dilakukan.",
            date: formattedDate,
            time: formattedTime,
            color: Colors.green,
            category: category,
            statusType: 'approved',
          );
          break;
        case 'ditolak':
          notification = NotificationModel(
            icon: Icons.cancel,
            title: "Pengajuan Santunan Ditolak",
            description: "Pengajuan santunan anda ditolak. Silahkan cek email untuk informasi lebih lanjut.",
            date: formattedDate,
            time: formattedTime,
            color: Colors.red,
            category: category,
            statusType: 'rejected',
          );
          break;
        case 'diverifikasi':
          notification = NotificationModel(
            icon: Icons.watch_later_outlined,
            title: "Pengajuan Santunan Sedang Diverifikasi",
            description: "Pengajuan santunan anda sedang dalam proses verifikasi. Harap menunggu untuk informasi selanjutnya.",
            date: formattedDate,
            time: formattedTime,
            color: Colors.orange,
            category: category,
            statusType: 'verifying',
          );
          break;
        case 'dibayar':
          notification = NotificationModel(
            icon: Icons.credit_score,
            title: "Dana Telah Dikirimkan",
            description: "Dana santunan anda telah dikirimkan. Silahkan cek rekening anda.",
            date: formattedDate,
            time: formattedTime,
            color: Colors.green,
            category: category,
            statusType: 'paid',
          );
          break;
        case 'terkirim':
          notification = NotificationModel(
            icon: Icons.mark_email_read_outlined,
            title: "Pengajuan Santunan Berhasil Terkirim",
            description: "Pengajuan santunan anda berhasil terkirim. Silahkan cek email untuk melihat ulang nomor pendaftaran.",
            date: formattedDate,
            time: formattedTime,
            color: Colors.blue,
            category: category,
            statusType: 'sent',
          );
          break;
        default:
          notification = NotificationModel(
            icon: Icons.info_outline,
            title: "Update Pengajuan Santunan",
            description: "Status pengajuan santunan anda telah diperbarui menjadi '${statusData.status}'.",
            date: formattedDate,
            time: formattedTime,
            color: Colors.blue,
            category: category,
            statusType: 'update',
          );
      }
    } else {
      category = 'Lainnya';
      notification = NotificationModel(
        icon: Icons.notifications,
        title: "Notifikasi Baru",
        description: "Ada perubahan status pada aplikasi anda.",
        date: formattedDate,
        time: formattedTime,
        color: Colors.blue,
        category: category,
        statusType: 'general',
      );
    }
    
    _notificationService.addNotification(notification);
  }
  
  String _formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);
      
      if (dateToCheck == today) {
        return 'Hari ini';
      } else if (dateToCheck == yesterday) {
        return 'Kemarin';
      } else {
        return DateFormat('d MMM', 'id_ID').format(dateTime);
      }
    } catch (e) {
      print('Error formatting date: $e');
      return 'Unknown';
    }
  }
  
  String _formatTime(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('HH:mm', 'id_ID').format(dateTime) + ' WIB';
    } catch (e) {
      print('Error formatting time: $e');
      return 'Unknown';
    }
  }
  
  // Cancel the polling timer
  void dispose() {
    _pollingTimer?.cancel();
  }
}

// Notification model
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

// Notification service
class NotificationService {
  final List<NotificationModel> _notifications = [];
  final _notificationController = StreamController<List<NotificationModel>>.broadcast();
  
  Stream<List<NotificationModel>> get notificationsStream => _notificationController.stream;
  List<NotificationModel> get notifications => _notifications;

  // Add new notification
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification); // Add to the beginning of the list
    _notificationController.add(_notifications);
    _saveNotifications(); // Save to local storage
  }

  // Get notifications grouped by category
  Map<String, List<NotificationModel>> getGroupedNotifications() {
    final Map<String, List<NotificationModel>> grouped = {};
    
    for (var notification in _notifications) {
      if (!grouped.containsKey(notification.category)) {
        grouped[notification.category] = [];
      }
      grouped[notification.category]!.add(notification);
    }
    
    return grouped;
  }

  // Initialize notifications from local storage
  Future<void> loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedNotifications = prefs.getStringList('notifications') ?? [];
      
      _notifications.clear();
      
      for (var notificationJson in storedNotifications) {
        final Map<String, dynamic> notificationMap = json.decode(notificationJson);
        
        _notifications.add(
          NotificationModel(
            icon: _getIconFromString(notificationMap['icon']),
            title: notificationMap['title'],
            description: notificationMap['description'],
            date: notificationMap['date'],
            time: notificationMap['time'],
            color: Color(notificationMap['color']),
            category: notificationMap['category'],
            statusType: notificationMap['statusType'],
          ),
        );
      }
      
      if (_notifications.isNotEmpty) {
        _notificationController.add(_notifications);
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }
  
  // Save notifications to local storage
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsToSave = _notifications.map((notification) {
        return json.encode({
          'icon': _getStringFromIcon(notification.icon),
          'title': notification.title,
          'description': notification.description,
          'date': notification.date,
          'time': notification.time,
          'color': notification.color.value,
          'category': notification.category,
          'statusType': notification.statusType,
        });
      }).toList();
      
      await prefs.setStringList('notifications', notificationsToSave);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }
  
  // Helper method to convert icon to string
  String _getStringFromIcon(IconData icon) {
    if (icon == Icons.cancel) return 'cancel';
    if (icon == Icons.check) return 'check';
    if (icon == Icons.credit_score) return 'credit_score';
    if (icon == Icons.mark_email_read_outlined) return 'mark_email_read_outlined';
    if (icon == Icons.watch_later_outlined) return 'watch_later_outlined';
    if (icon == Icons.check_circle) return 'check_circle';
    if (icon == Icons.hourglass_top) return 'hourglass_top';
    if (icon == Icons.info_outline) return 'info_outline';
    return 'notifications'; // Default
  }
  
  // Helper method to convert string to icon
  IconData _getIconFromString(String iconString) {
    switch (iconString) {
      case 'cancel': return Icons.cancel;
      case 'check': return Icons.check;
      case 'credit_score': return Icons.credit_score;
      case 'mark_email_read_outlined': return Icons.mark_email_read_outlined;
      case 'watch_later_outlined': return Icons.watch_later_outlined;
      case 'check_circle': return Icons.check_circle;
      case 'hourglass_top': return Icons.hourglass_top;
      case 'info_outline': return Icons.info_outline;
      default: return Icons.notifications;
    }
  }
  
  // Clear all notifications
  Future<void> clearNotifications() async {
    _notifications.clear();
    _notificationController.add(_notifications);
    await _saveNotifications();
  }
  
  void dispose() {
    _notificationController.close();
  }
}

class NotifPage extends StatefulWidget {
  const NotifPage({super.key});

  @override
  State<NotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  final NotificationService _notificationService = NotificationService();
  final ApiService _apiService = ApiService();
  late StatusMonitorService _statusMonitorService;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    // Initialize notification service
    await _notificationService.loadNotifications();
    
    // Initialize status monitor service
    _statusMonitorService = StatusMonitorService(_apiService, _notificationService);
    _statusMonitorService.startMonitoring();
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  void dispose() {
    _statusMonitorService.dispose();
    _notificationService.dispose();
    super.dispose();
  }

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
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    // Manually trigger a status check
                    _statusMonitorService.startMonitoring();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menyegarkan notifikasi...')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Clear all button
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _notificationService.clearNotifications();
                    },
                    child: const Text(
                      'Hapus Semua',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: StreamBuilder<List<NotificationModel>>(
                stream: _notificationService.notificationsStream,
                initialData: _notificationService.notifications,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada notifikasi'),
                    );
                  }
                  
                  // Group notifications by category
                  final groupedNotifications = _notificationService.getGroupedNotifications();
                  final categories = groupedNotifications.keys.toList();
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      // Manually trigger a status check
                      _statusMonitorService.startMonitoring();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: categories.length,
                      itemBuilder: (context, categoryIndex) {
                        final category = categories[categoryIndex];
                        final notificationsInCategory = groupedNotifications[category]!;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category header
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF444444),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Notifications in this category
                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: notificationsInCategory.length,
                              separatorBuilder: (context, index) => const Divider(height: 20, thickness: 1),
                              itemBuilder: (context, index) {
                                return NotificationItem(
                                  notification: notificationsInCategory[index],
                                );
                              },
                            ),
                            // Add divider between categories
                            if (categoryIndex < categories.length - 1)
                              const Divider(height: 40, thickness: 1.5),
                          ],
                        );
                      },
                    ),
                  );
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: notification.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(notification.icon, color: notification.color, size: 24),
        ),
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