import 'package:dio/dio.dart';
import '../models/feedback.dart';
import '../../core/dio_client.dart';

class FeedbackRepository {
  final Dio _dio = DioClient.instance;

  Future<void> submitFeedback({
    String? email,
    String? subject,
    required String comment,
  }) async {
    await _dio.post('/api/feedback', data: {
      if (email != null && email.isNotEmpty) 'email': email,
      if (subject != null && subject.isNotEmpty) 'subject': subject,
      'comment': comment,
    });
  }

  Future<List<FeedbackModel>> getFeedbacks() async {
    final response = await _dio.get('/api/feedback');
    final data = response.data;
    final list = data is List ? data : (data['feedbacks'] ?? data['data'] ?? []);
    return (list as List).map((e) => FeedbackModel.fromJson(e)).toList();
  }

  Future<void> updateFeedbackStatus(String id, String status) async {
    await _dio.patch('/api/feedback/$id', data: {'status': status});
  }

  Future<void> deleteFeedback(String id) async {
    await _dio.delete('/api/feedback/$id');
  }
}
