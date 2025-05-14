class Comment {
  final int id;
  final int pengajuanBPJSId;
  final String nomorBPJS;
  final String comment;
  final String authorType;
  final String createdAt;
  final String updatedAt;
  final List<CommentReply> replies;

  Comment({
    required this.id,
    required this.pengajuanBPJSId,
    required this.nomorBPJS,
    required this.comment,
    required this.authorType,
    required this.createdAt,
    required this.updatedAt,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    print('Comment.fromJson received: $json');

    List<CommentReply> replyList = [];

    if (json['replies'] != null) {
      replyList = (json['replies'] as List)
          .map((reply) => CommentReply.fromJson(reply))
          .toList();
    }

    int parsedPengajuanBPJSId;
    try {
      if (json['pengajuanBPJS_id'] is String) {
        parsedPengajuanBPJSId = int.parse(json['pengajuanBPJS_id']);
      } else if (json['pengajuanBPJS_id'] is int) {
        parsedPengajuanBPJSId = json['pengajuanBPJS_id'];
      } else {
        print(
            'Warning: pengajuanBPJS_id is neither string nor int: ${json['pengajuanBPJS_id']}');
        // Default to 0 or handle error as appropriate for your app
        parsedPengajuanBPJSId = 0;
      }
    } catch (e) {
      print('Error parsing pengajuanBPJS_id: $e');
      parsedPengajuanBPJSId = 0;
    }

    return Comment(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      pengajuanBPJSId: parsedPengajuanBPJSId,
      nomorBPJS: json['no_bpjs_nik'] ?? '',
      comment: json['comment'] ?? '',
      authorType: json['author_type'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      replies: replyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Keep as integer
      'pengajuanBPJS_id': pengajuanBPJSId, // Keep as integer
      'no_bpjs_nik': nomorBPJS,
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
