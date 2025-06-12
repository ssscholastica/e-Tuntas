class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: int.tryParse(json['id'].toString()) ?? 0, // Safe parsing
      title: json['title'] ?? '',
      message: json['description'] ??
          '', // Field 'message' di JSON sebenarnya bernama 'description'
      isRead: json['isRead'] ??
          false, // Pastikan sesuai dengan casing di JSON: isRead (camelCase)
    );
  }

}
