import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:etuntas/models/comment_bpjs_model.dart';
import 'package:etuntas/network/globals.dart';

class CommentService {
  Future<List<Comment>> getCommentsByPengajuan(int pengajuanId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseURL}commentsbpjs/pengajuan/$pengajuanId'),
        headers: {'Accept': 'application/json'},
      );

      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = responseData['data'];
        return data.map((item) => Comment.fromJson(item)).toList();
      } else {
        print('Failed to load comments: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  Future<List<Comment>> getCommentsByNomorBPJS(String nomorBPJS) async {
    try {
      final response = await http.get(
        Uri.parse('${baseURL}commentsbpjs/nomor-pendaftaran/$nomorBPJS'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return List<Comment>.from(
            responseData['data'].map((comment) => Comment.fromJson(comment)),
          );
        } else {
          print('No comments found or status is not success');
        }
      } else {
        print('Error: Status code ${response.statusCode}');
      }
      return [];
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }


  Future<Comment?> submitComment({
    required int pengajuanBPJSId,
    required String nomorBPJS,
    required String commentText,
  }) async {
    try {
      final int pengajuanBPJSIdInt = pengajuanBPJSId;
      final Map<String, dynamic> requestBody = {
        'pengajuanBPJS_id': pengajuanBPJSIdInt,
        'nomor_bpjs_nik': nomorBPJS,
        'comment': commentText,
        'author_type': 'user',
      };

      print('Sending request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('${baseURL}commentsbpjs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');
        if (data is Map && data.containsKey('data')) {
          return Comment.fromJson(data['data']);
        } else {
          return Comment.fromJson(data);
        }
      } else {
        print('Failed to submit comment: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error submitting comment: $e');
      print('Error details: ${e.toString()}');
      rethrow; // Re-throw to handle in UI
    }
  }

  // Submit a reply to a comment
  Future<Comment?> submitReply({
    required int commentId,
    required String replyText,
    required String authorType,
  }) async {
    try {
      // Keep commentId as integer, don't convert to string
      final Map<String, dynamic> requestBody = {
        'comment': replyText,
        'author_type': authorType,
      };

      print('Submitting reply with body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('${baseURL}commentsbpjs/$commentId/reply'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Reply response: $responseData');
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return Comment.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error submitting reply: $e');
      print('Error details: ${e.toString()}');
      return null;
    }
  }

  Future<Comment?> addReply({
    required int commentId,
    required String replyText,
  }) async {
    try {
      // Keep commentId as integer, don't convert to string
      final Map<String, dynamic> requestBody = {
        'comment': replyText,
        'author_type': 'user',
      };

      print('Adding reply with body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('${baseURL}commentsbpjs/$commentId/reply'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Add reply response: $data');
        if (data is Map && data.containsKey('data')) {
          return Comment.fromJson(data['data']);
        } else {
          return Comment.fromJson(data);
        }
      } else {
        print('Failed to add reply: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error adding reply: $e');
      print('Error details: ${e.toString()}');
      return null;
    }
  }
}
