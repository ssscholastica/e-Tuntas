// import 'dart:async';
// import 'dart:convert';

// import 'package:etuntas/network/globals.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // API Service for handling API requests
// class ApiService {
//   // Headers for API requests
//   Future<Map<String, String>> _getHeaders() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('auth_token') ?? '';

//     return {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//   }

//   // Fetch data from an endpoint
//   Future<List<dynamic>> fetchData(String endpoint) async {
//     try {
//       final headers = await _getHeaders();
//       final response = await http.get(
//         Uri.parse('$baseURL/$endpoint'),
//         headers: headers,
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return data['data'] ?? [];
//       } else {
//         print('Error fetching data: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       print('Exception fetching data: $e');
//       return [];
//     }
//   }

//   // Fetch a specific record
//   Future<Map<String, dynamic>> fetchRecord(String endpoint, String id) async {
//     try {
//       final headers = await _getHeaders();
//       final response = await http.get(
//         Uri.parse('$baseURL/$endpoint/$id'),
//         headers: headers,
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return data['data'] ?? {};
//       } else {
//         print('Error fetching record: ${response.statusCode}');
//         return {};
//       }
//     } catch (e) {
//       print('Exception fetching record: $e');
//       return {};
//     }
//   }

//   // Update status of a record
//   Future<bool> updateStatus(String endpoint, String id, String status) async {
//     try {
//       final headers = await _getHeaders();
//       final response = await http.put(
//         Uri.parse('$baseURL/$endpoint/$id/status'),
//         headers: headers,
//         body: json.encode({'status': status}),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return true;
//       } else {
//         print('Error updating status: ${response.statusCode}');
//         return false;
//       }
//     } catch (e) {
//       print('Exception updating status: $e');
//       return false;
//     }
//   }
// }

// // // Status data class
// // class StatusData {
// //   final String tableName;
// //   final String id;
// //   final String status;
// //   final String updatedAt;

// //   StatusData({
// //     required this.tableName,
// //     required this.id,
// //     required this.status,
// //     required this.updatedAt,
// //   });
// // }

// class NotificationModel {
//   final IconData icon;
//   final String title;
//   final String description;
//   final String date;
//   final String time;
//   final Color color;
//   final String category;
//   final String statusType;

//   NotificationModel({
//     required this.icon,
//     required this.title,
//     required this.description,
//     required this.date,
//     required this.time,
//     required this.color,
//     required this.category,
//     required this.statusType,
//   });
// }

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
//   // Initialize notification channels and request permissions
//   Future<void> initialize() async {
//     // Initialize Firebase
//     await Firebase.initializeApp();
    
//     // Request permission for iOS
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       provisional: false,
//       sound: true,
//     );
    
//     // Configure local notifications
//     const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
    
//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
    
//     await _localNotifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onSelectNotification,
//     );
    
//     // Create notification channel for Android
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       description: 'This channel is used for important notifications.',
//       importance: Importance.high,
//     );
    
//     await _localNotifications
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
    
//     // Handle incoming FCM messages
//     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
//     // Get and store FCM token
//     String? token = await _firebaseMessaging.getToken();
//     if (token != null) {
//       await _saveFcmToken(token);
//       await _sendTokenToServer(token);
//     }
    
//     // Listen for token refreshes
//     _firebaseMessaging.onTokenRefresh.listen((newToken) {
//       _saveFcmToken(newToken);
//       _sendTokenToServer(newToken);
//     });
//   }
  
//   // Save FCM token to shared preferences
//   Future<void> _saveFcmToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('fcm_token', token);
//   }
  
//   // Send FCM token to your server
//   Future<void> _sendTokenToServer(String token) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? userId = prefs.getString('user_id');
//       if (userId == null) return;
      
//       final String baseUrl = 'http://10.0.2.2:8000'; // For emulator, change for real device
      
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/users/update-fcm-token'),
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${prefs.getString('auth_token') ?? ''}',
//         },
//         body: jsonEncode(<String, String>{
//           'fcm_token': token,
//         }),
//       );
      
//       if (response.statusCode != 200) {
//         print('Failed to update FCM token: ${response.body}');
//       }
//     } catch (e) {
//       print('Error sending FCM token to server: $e');
//     }
//   }

//   // Handle incoming foreground messages
//   void _handleForegroundMessage(RemoteMessage message) {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
    
//     // If notification is present, show local notification
//     if (notification != null && android != null) {
//       _localNotifications.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             'high_importance_channel',
//             'High Importance Notifications',
//             channelDescription: 'This channel is used for important notifications.',
//             importance: Importance.high,
//             priority: Priority.high,
//           ),
//           iOS: const DarwinNotificationDetails(
//             presentAlert: true,
//             presentBadge: true,
//             presentSound: true,
//           ),
//         ),
//         payload: jsonEncode(message.data),
//       );
//     }
    
//     // Process the notification data
//     _processStatusUpdate(message.data);
//   }
  
//   // Process notification payload
//   void _processStatusUpdate(Map<String, dynamic> data) {
//     // Store in local database or update UI as needed
//     final StatusData statusData = StatusData.fromMap(data);
    
//     // Broadcast to the app using a stream controller
//     notificationStreamController.add(statusData);
//   }
  
//   // Handle notification tap
//   void _onSelectNotification(NotificationResponse response) {
//     if (response.payload != null) {
//       try {
//         final data = jsonDecode(response.payload!);
//         _processStatusUpdate(Map<String, dynamic>.from(data));
        
//         // Navigate to the appropriate screen based on notification data
//         final statusData = StatusData.fromMap(data);
//         _navigateBasedOnNotification(statusData);
//       } catch (e) {
//         print('Error processing notification tap: $e');
//       }
//     }
//   }
  
//   // Navigate based on notification data
//   void _navigateBasedOnNotification(StatusData statusData) {
//     // This needs to be implemented with your navigation logic
//     // Example:
//     /*
//     if (navigatorKey.currentState != null) {
//       if (statusData.tableName == 'pengaduan-bpjs') {
//         navigatorKey.currentState!.pushNamed(
//           '/pengaduan-detail',
//           arguments: {'id': statusData.recordId}
//         );
//       } else if (statusData.tableName == 'pengajuan-santunan1') {
//         navigatorKey.currentState!.pushNamed(
//           '/santunan1-detail',
//           arguments: {'id': statusData.recordId}
//         );
//       } else if (statusData.tableName == 'pengajuan-santunan2') {
//         navigatorKey.currentState!.pushNamed(
//           '/santunan2-detail',
//           arguments: {'id': statusData.recordId}
//         );
//       } else if (statusData.tableName == 'pengajuan-santunan3') {
//         navigatorKey.currentState!.pushNamed(
//           '/santunan3-detail',
//           arguments: {'id': statusData.recordId}
//         );
//       } else if (statusData.tableName == 'pengajuan-santunan4') {
//         navigatorKey.currentState!.pushNamed(
//           '/santunan4-detail',
//           arguments: {'id': statusData.recordId}
//         );
//       } else if (statusData.tableName == 'pengajuan-santunan5') {
//         navigatorKey.currentState!.pushNamed(
//           '/santunan5-detail',
//           arguments: {'id': statusData.recordId}
//         );
//       }
//     }
//     */
//   }
// }

// // Stream controller for notifications
// final StreamController<StatusData> notificationStreamController = StreamController<StatusData>.broadcast();

// // Status data model
// class StatusData {
//   final String tableName;
//   final int recordId;
//   final String status;
  
//   StatusData({
//     required this.tableName,
//     required this.recordId,
//     required this.status,
//   });
  
//   factory StatusData.fromMap(Map<String, dynamic> map) {
//     return StatusData(
//       tableName: map['tableName'] ?? '',
//       recordId: int.tryParse(map['recordId']?.toString() ?? '0') ?? 0,
//       status: map['status'] ?? '',
//     );
//   }
  
//   Map<String, dynamic> toMap() {
//     return {
//       'tableName': tableName,
//       'recordId': recordId,
//       'status': status,
//     };
//   }
// }

// // Background message handler
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
  
//   // Process notification
//   // In background mode, we can't update UI directly
//   // But we can store data in shared preferences or local database
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> notifications = prefs.getStringList('pending_notifications') ?? [];
//     notifications.add(jsonEncode(message.data));
//     await prefs.setStringList('pending_notifications', notifications);
//   } catch (e) {
//     print('Error storing background notification: $e');
//   }
// }

// // Example of how to listen to notifications in a widget
// class NotificationListener extends StatefulWidget {
//   final Widget child;
  
//   const NotificationListener({Key? key, required this.child}) : super(key: key);
  
//   @override
//   _NotificationListenerState createState() => _NotificationListenerState();
// }

// class _NotificationListenerState extends State<NotificationListener> {
//   late StreamSubscription<StatusData> _subscription;
  
//   @override
//   void initState() {
//     super.initState();
//     _subscription = notificationStreamController.stream.listen(_handleNotification);
//     _checkPendingNotifications();
//   }
  
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
  
//   // Check for any notifications received while app was in background
//   Future<void> _checkPendingNotifications() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       List<String> notifications = prefs.getStringList('pending_notifications') ?? [];
      
//       if (notifications.isNotEmpty) {
//         await prefs.setStringList('pending_notifications', []);
        
//         for (String notificationJson in notifications) {
//           final data = jsonDecode(notificationJson);
//           final statusData = StatusData.fromMap(Map<String, dynamic>.from(data));
//           _handleNotification(statusData);
//         }
//       }
//     } catch (e) {
//       print('Error checking pending notifications: $e');
//     }
//   }
  
//   // Handle incoming notification
//   void _handleNotification(StatusData statusData) {
//     // Update your UI based on notification data
//     // Example: Show a snackbar
//     if (mounted) {
//       String title = "";
//       String body = "";
      
//       if (statusData.tableName == 'pengaduan-bpjs') {
//         title = "Update Pengaduan BPJS";
//         switch (statusData.status.toLowerCase()) {
//           case 'ditolak':
//             body = "Pengaduan BPJS anda ditolak. Silahkan cek email untuk informasi lebih lanjut.";
//             break;
//           case 'diterima':
//             body = "Pengaduan BPJS anda telah diterima. Proses akan dilanjutkan.";
//             break;
//           case 'terkirim':
//             body = "Pengaduan BPJS anda berhasil terkirim. Silahkan cek email untuk melihat ulang nomor pendaftaran.";
//             break;
//           case 'diproses':
//             body = "Pengaduan BPJS anda sedang diproses. Harap menunggu informasi selanjutnya.";
//             break;
//           default:
//             body = "Status pengaduan BPJS anda telah diperbarui menjadi '${statusData.status}'.";
//         }
//       } else if (statusData.tableName.startsWith('pengajuan-santunan')) {
//         String santunanType = statusData.tableName.replaceAll('pengajuan-santunan', '');
//         title = santunanType.isNotEmpty ? "Update Santunan $santunanType" : "Update Santunan";
        
//         switch (statusData.status.toLowerCase()) {
//           case 'diterima':
//             body = "Pengajuan santunan anda telah diterima. Proses pencairan akan segera dilakukan.";
//             break;
//           case 'ditolak':
//             body = "Pengajuan santunan anda ditolak. Silahkan cek email untuk informasi lebih lanjut.";
//             break;
//           case 'diverifikasi':
//             body = "Pengajuan santunan anda sedang dalam proses verifikasi. Harap menunggu untuk informasi selanjutnya.";
//             break;
//           case 'dibayar':
//             body = "Dana santunan anda telah dikirimkan. Silahkan cek rekening anda.";
//             break;
//           case 'terkirim':
//             body = "Pengajuan santunan anda berhasil terkirim. Silahkan cek email untuk melihat ulang nomor pendaftaran.";
//             break;
//           default:
//             body = "Status pengajuan santunan anda telah diperbarui menjadi '${statusData.status}'.";
//         }
//       }
      
//       // Show snackbar or other UI component
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
//               SizedBox(height: 4),
//               Text(body),
//             ],
//           ),
//           duration: Duration(seconds: 4),
//           action: SnackBarAction(
//             label: 'View',
//             onPressed: () {
//               // Navigate to relevant screen based on the specific table name
//               switch (statusData.tableName) {
//                 case 'pengaduan-bpjs':
//                   Navigator.of(context).pushNamed(
//                     '/pengaduan-detail',
//                     arguments: {'id': statusData.recordId}
//                   );
//                   break;
//                 case 'pengajuan-santunan1':
//                   Navigator.of(context).pushNamed(
//                     '/santunan1-detail',
//                     arguments: {'id': statusData.recordId}
//                   );
//                   break;
//                 case 'pengajuan-santunan2':
//                   Navigator.of(context).pushNamed(
//                     '/santunan2-detail',
//                     arguments: {'id': statusData.recordId}
//                   );
//                   break;
//                 case 'pengajuan-santunan3':
//                   Navigator.of(context).pushNamed(
//                     '/santunan3-detail',
//                     arguments: {'id': statusData.recordId}
//                   );
//                   break;
//                 case 'pengajuan-santunan4':
//                   Navigator.of(context).pushNamed(
//                     '/santunan4-detail',
//                     arguments: {'id': statusData.recordId}
//                   );
//                   break;
//                 case 'pengajuan-santunan5':
//                   Navigator.of(context).pushNamed(
//                     '/santunan5-detail',
//                     arguments: {'id': statusData.recordId}
//                   );
//                   break;
//               }
//             },
//           ),
//         ),
//       );
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }

// class NotifPage extends StatefulWidget {
//   const NotifPage({super.key});

//   @override
//   State<NotifPage> createState() => _NotifPageState();
// }

// class _NotifPageState extends State<NotifPage> {
//   final NotificationService _notificationService = NotificationService();
//   final ApiService _apiService = ApiService();
//   late StatusMonitorService _statusMonitorService;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeServices();
//   }

//   Future<void> _initializeServices() async {
//     // Initialize notification service
//     await _notificationService.loadNotifications();

//     // Initialize status monitor service
//     _statusMonitorService =
//         StatusMonitorService(_apiService, _notificationService);
//     _statusMonitorService.startMonitoring();

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   void dispose() {
//     _statusMonitorService.dispose();
//     _notificationService.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           Container(
//             margin: const EdgeInsets.only(top: 60, left: 20, right: 20),
//             child: Row(
//               children: [
//                 InkWell(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   child: Image.asset(
//                     'assets/simbol back.png',
//                     width: 28,
//                     height: 28,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 const Text(
//                   "Notifikasi",
//                   style: TextStyle(
//                     fontSize: 20,
//                     color: Color(0XFF000000),
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: const Icon(Icons.refresh),
//                   onPressed: () {
//                     // Manually trigger a status check
//                     _statusMonitorService.startMonitoring();
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                           content: Text('Menyegarkan notifikasi...')),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           // Clear all button
//           if (!_isLoading)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 children: [
//                   const Spacer(),
//                   TextButton(
//                     onPressed: () {
//                       _notificationService.clearNotifications();
//                     },
//                     child: const Text(
//                       'Hapus Semua',
//                       style: TextStyle(color: Colors.blue),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           const SizedBox(height: 10),
//           if (_isLoading)
//             const Expanded(
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             )
//           else
//             Expanded(
//               child: StreamBuilder<List<NotificationModel>>(
//                 stream: _notificationService.notificationsStream,
//                 initialData: _notificationService.notifications,
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return const Center(
//                       child: Text('Tidak ada notifikasi'),
//                     );
//                   }

//                   // Group notifications by category
//                   final groupedNotifications =
//                       _notificationService.getGroupedNotifications();
//                   final categories = groupedNotifications.keys.toList();

//                   return RefreshIndicator(
//                     onRefresh: () async {
//                       // Manually trigger a status check
//                       _statusMonitorService.startMonitoring();
//                     },
//                     child: ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: categories.length,
//                       itemBuilder: (context, categoryIndex) {
//                         final category = categories[categoryIndex];
//                         final notificationsInCategory =
//                             groupedNotifications[category]!;

//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Category header
//                             Container(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 8.0),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[100],
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               width: double.infinity,
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 16.0),
//                                 child: Text(
//                                   category,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF444444),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             // Notifications in this category
//                             ListView.separated(
//                               physics: const NeverScrollableScrollPhysics(),
//                               shrinkWrap: true,
//                               itemCount: notificationsInCategory.length,
//                               separatorBuilder: (context, index) =>
//                                   const Divider(height: 20, thickness: 1),
//                               itemBuilder: (context, index) {
//                                 return NotificationItem(
//                                   notification: notificationsInCategory[index],
//                                 );
//                               },
//                             ),
//                             // Add divider between categories
//                             if (categoryIndex < categories.length - 1)
//                               const Divider(height: 40, thickness: 1.5),
//                           ],
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class NotificationItem extends StatelessWidget {
//   final NotificationModel notification;

//   const NotificationItem({Key? key, required this.notification})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: notification.color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(notification.icon, color: notification.color, size: 24),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       notification.title,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   Text(
//                     notification.date,
//                     style: const TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 notification.description,
//                 style: TextStyle(color: Colors.grey[700]),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 notification.time,
//                 style: const TextStyle(color: Colors.grey, fontSize: 12),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
