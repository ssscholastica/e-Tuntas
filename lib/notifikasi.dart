import 'dart:convert';

import 'package:etuntas/network/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotifPage extends StatefulWidget {
  @override
  _NotifPageState createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> with TickerProviderStateMixin {
  List<NotificationModel> notifications = [];
  bool isLoading = true;
  String? errorMessage;
  int currentPage = 1;
  bool hasMorePages = false;
  bool isLoadingMore = false;
  String selectedFilter = 'all'; // 'all', 'status_update', 'comment', 'unread'
  int unreadCount = 0;
  
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    _loadNotifications();
    _getUnreadCount();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            selectedFilter = 'all';
            break;
          case 1:
            selectedFilter = 'unread';
            break;
          case 2:
            selectedFilter = 'status_update';
            break;
          case 3:
            selectedFilter = 'comment';
            break;
        }
        currentPage = 1;
        notifications.clear();
      });
      _loadNotifications();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (hasMorePages && !isLoadingMore) {
        _loadMoreNotifications();
      }
    }
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        setState(() {
          errorMessage = 'Authentication token not found';
          isLoading = false;
        });
        return;
      }

      String url = '${baseURL}notifications?page=$currentPage&per_page=15';
      
      // Add filters
      if (selectedFilter == 'unread') {
        url += '&unread_only=true';
      } else if (selectedFilter != 'all') {
        url += '&type=$selectedFilter';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          final List<dynamic> notificationData = data['data'];
          final pagination = data['pagination'];
          
          setState(() {
            if (currentPage == 1) {
              notifications = notificationData
                  .map((item) => NotificationModel.fromJson(item))
                  .toList();
            } else {
              notifications.addAll(notificationData
                  .map((item) => NotificationModel.fromJson(item))
                  .toList());
            }
            
            hasMorePages = pagination['has_more'] ?? false;
            unreadCount = data['unread_count'] ?? 0;
            isLoading = false;
            isLoadingMore = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to load notifications';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (isLoadingMore || !hasMorePages) return;
    
    setState(() {
      isLoadingMore = true;
      currentPage++;
    });
    
    await _loadNotifications();
  }

  Future<void> _getUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${baseURL}notifications/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            unreadCount = data['unread_count'] ?? 0;
          });
        }
      }
    } catch (e) {
      print('Error getting unread count: $e');
    }
  }

  Future<void> _markAsRead(String notificationId, int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) return;

      final response = await http.put(
        Uri.parse('${baseURL}notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications[index].isRead = true;
          notifications[index].readAt = DateTime.now();
          if (unreadCount > 0) unreadCount--;
        });
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) return;

      final response = await http.put(
        Uri.parse('${baseURL}notifications/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          for (var notification in notifications) {
            notification.isRead = true;
            notification.readAt = DateTime.now();
          }
          unreadCount = 0;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Semua notifikasi telah ditandai sudah dibaca'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menandai semua notifikasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteNotification(String notificationId, int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) return;

      final response = await http.delete(
        Uri.parse('${baseURL}notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          if (!notifications[index].isRead && unreadCount > 0) {
            unreadCount--;
          }
          notifications.removeAt(index);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notifikasi berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus notifikasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      currentPage = 1;
      notifications.clear();
    });
    await _loadNotifications();
    await _getUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Notifikasi'),
            if (unreadCount > 0) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: 'Tandai semua sudah dibaca',
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshNotifications,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Semua'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Belum Dibaca'),
                  if (unreadCount > 0) ...[
                    SizedBox(width: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(text: 'Update Status'),
            Tab(text: 'Komentar'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading && notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat notifikasi...'),
          ],
        ),
      );
    }

    if (errorMessage != null && notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshNotifications,
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada notifikasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Notifikasi akan muncul ketika ada update status atau komentar baru',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: notifications.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == notifications.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final notification = notifications[index];
        return _buildNotificationCard(notification, index);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id, index);
          }
          _showNotificationDetail(notification);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: notification.isRead ? null : Colors.blue.shade50,
            border: notification.isRead 
                ? null 
                : Border.all(color: Colors.blue.shade200, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _getNotificationIcon(notification.type, notification.referenceType),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: notification.isRead 
                                      ? FontWeight.w500 
                                      : FontWeight.bold,
                                  color: notification.isRead 
                                      ? Colors.grey[800] 
                                      : Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _formatReferenceType(notification.referenceType),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'mark_read':
                          if (!notification.isRead) {
                            _markAsRead(notification.id, index);
                          }
                          break;
                        case 'delete':
                          _showDeleteConfirmation(notification.id, index);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!notification.isRead)
                        PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(Icons.done, size: 18),
                              SizedBox(width: 8),
                              Text('Tandai sudah dibaca'),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              if (notification.referenceNumber != null) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'No. ${notification.referenceNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDateTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String type, String referenceType) {
    IconData iconData;
    Color iconColor;

    if (type == 'status_update') {
      iconData = Icons.update;
      iconColor = Colors.orange;
    } else if (type == 'comment') {
      iconData = Icons.comment;
      iconColor = Colors.blue;
    } else {
      iconData = Icons.notifications;
      iconColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  String _formatReferenceType(String referenceType) {
    switch (referenceType) {
      case 'pengaduan_bpjs':
        return 'Pengaduan BPJS';
      case 'pengajuan_santunan1':
        return 'Santunan Kematian';
      case 'pengajuan_santunan2':
        return 'Santunan Cacat';
      case 'pengajuan_santunan3':
        return 'Santunan Berkala';
      case 'pengajuan_santunan4':
        return 'Santunan Lainnya';
      case 'pengajuan_santunan5':
        return 'Santunan Khusus';
      default:
        return referenceType;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
    }
  }

  void _showNotificationDetail(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _getNotificationIcon(notification.type, notification.referenceType),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatReferenceType(notification.referenceType),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Divider(),
                      SizedBox(height: 16),
                      Text(
                        'Detail Notifikasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (notification.referenceNumber != null) ...[
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nomor Referensi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                notification.referenceNumber!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                          SizedBox(width: 4),
                          Text(
                            'Diterima ${_formatDateTime(notification.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      if (notification.readAt != null) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.done, size: 16, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              'Dibaca ${_formatDateTime(notification.readAt!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String notificationId, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Notifikasi'),
        content: Text(
          'Apakah Anda yakin ingin menghapus notifikasi ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNotification(notificationId, index);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// NotificationModel class
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String referenceType;
  final String? referenceNumber;
  final DateTime createdAt;
  bool isRead;
  DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.referenceType,
    this.referenceNumber,
    required this.createdAt,
    required this.isRead,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      referenceType: json['reference_type'] ?? '',
      referenceNumber: json['reference_number'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'reference_type': referenceType,
      'reference_number': referenceNumber,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
    };
  }
}