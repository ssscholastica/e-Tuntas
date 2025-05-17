class Comment {
  final int id;
  final int pengajuanId;
  final String noPendaftaran;
  final String comment;
  final String authorType;
  final String createdAt;
  final String updatedAt;
  final List<CommentReply> replies;
  final String content;

  Comment({
    required this.id,
    required this.pengajuanId,
    required this.noPendaftaran,
    required this.comment,
    required this.authorType,
    required this.createdAt,
    required this.updatedAt,
    required this.replies,
    required this.content
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    print('Comment.fromJson received: $json');

    List<CommentReply> replyList = [];

    if (json['replies'] != null) {
      replyList = (json['replies'] as List)
          .map((reply) => CommentReply.fromJson(reply))
          .toList();
    }

    int parsedPengajuanId;
    try {
      if (json['pengajuan_id'] is String) {
        parsedPengajuanId = int.parse(json['pengajuan_id']);
      } else if (json['pengajuan_id'] is int) {
        parsedPengajuanId = json['pengajuan_id'];
      } else {
        print(
            'Warning: pengajuan_id is neither string nor int: ${json['pengajuan_id']}');
        // Default to 0 or handle error as appropriate for your app
        parsedPengajuanId = 0;
      }
    } catch (e) {
      print('Error parsing pengajuan_id: $e');
      parsedPengajuanId = 0;
    }

    return Comment(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      pengajuanId: parsedPengajuanId,
      noPendaftaran: json['no_pendaftaran'] ?? '',
      comment: json['comment'] ?? '',
      authorType: json['author_type'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      replies: replyList,
      content: ''
    );
  }

  factory Comment.empty() {
    return Comment(
      id: 0,
      pengajuanId: 0,
      noPendaftaran: '',
      comment: '',
      authorType: '',
      createdAt: '',
      updatedAt: '',
      replies: [],
      content: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Keep as integer
      'pengajuan_id': pengajuanId, // Keep as integer
      'no_pendaftaran': noPendaftaran,
      'comment': comment,
      'author_type': authorType,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }
}

class CommentReply {
  final int id;
  final int commentId;
  final String comment;
  final String authorType;
  final String createdAt;
  final String updatedAt;

  CommentReply({
    required this.id,
    required this.commentId,
    required this.comment,
    required this.authorType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentReply.fromJson(Map<String, dynamic> json) {
    // Debug printing
    print('CommentReply.fromJson received: $json');

    // Handle comment_id type safely - keep as integer
    int parsedCommentId;
    try {
      if (json['comment_id'] is String) {
        parsedCommentId = int.parse(json['comment_id']);
      } else if (json['comment_id'] is int) {
        parsedCommentId = json['comment_id'];
      } else if (json['parent_id'] is String) {
        // Try parent_id as fallback
        parsedCommentId = int.parse(json['parent_id']);
      } else if (json['parent_id'] is int) {
        // Try parent_id as fallback
        parsedCommentId = json['parent_id'];
      } else {
        print(
            'Warning: comment_id/parent_id is missing or invalid: ${json['comment_id'] ?? json['parent_id']}');
        parsedCommentId = 0;
      }
    } catch (e) {
      print('Error parsing comment_id: $e');
      parsedCommentId = 0;
    }

    return CommentReply(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      commentId: parsedCommentId,
      comment: json['comment'] ?? '',
      authorType: json['author_type'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Keep as integer
      'comment_id': commentId, // Keep as integer
      'comment': comment,
      'author_type': authorType,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
