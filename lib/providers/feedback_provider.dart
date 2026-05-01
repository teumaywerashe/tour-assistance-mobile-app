import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/feedback.dart';
import '../data/repositories/feedback_repository.dart';

class FeedbackListNotifier extends AsyncNotifier<List<FeedbackModel>> {
  final _repo = FeedbackRepository();

  @override
  Future<List<FeedbackModel>> build() async {
    return _repo.getFeedbacks();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getFeedbacks());
  }

  Future<void> updateStatus(String id, String status) async {
    await _repo.updateFeedbackStatus(id, status);
    await refresh();
  }

  Future<void> deleteFeedback(String id) async {
    await _repo.deleteFeedback(id);
    await refresh();
  }
}

final feedbackListProvider =
    AsyncNotifierProvider<FeedbackListNotifier, List<FeedbackModel>>(
        FeedbackListNotifier.new);
