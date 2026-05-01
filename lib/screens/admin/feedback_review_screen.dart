import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../data/models/feedback.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/auth_provider.dart';

class AdminFeedbackReviewScreen extends ConsumerWidget {
  const AdminFeedbackReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(feedbackListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: feedbackAsync.when(
        data: (feedbacks) {
          final pending = feedbacks.where((f) => f.status == 'pending').length;
          final resolved = feedbacks.where((f) => f.status == 'resolved').length;

          return RefreshIndicator(
            onRefresh: () => ref.read(feedbackListProvider.notifier).refresh(),
            child: Column(
              children: [
                // Stats row
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _StatChip(label: 'Total', value: feedbacks.length, color: AppConstants.accent),
                      const SizedBox(width: 8),
                      _StatChip(label: 'Pending', value: pending, color: Colors.amber),
                      const SizedBox(width: 8),
                      _StatChip(label: 'Resolved', value: resolved, color: Colors.green),
                    ],
                  ),
                ),
                Expanded(
                  child: feedbacks.isEmpty
                      ? const Center(child: Text('No feedback yet'))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: feedbacks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) => _FeedbackCard(
                            feedback: feedbacks[i],
                            onReview: () => ref.read(feedbackListProvider.notifier)
                                .updateStatus(feedbacks[i].id.toString(), 'reviewed'),
                            onResolve: () => ref.read(feedbackListProvider.notifier)
                                .updateStatus(feedbacks[i].id.toString(), 'resolved'),
                            onDelete: () => _confirmDelete(context, ref, feedbacks[i]),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('$e'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(feedbackListProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, FeedbackModel feedback) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: const Text('Are you sure you want to delete this feedback?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      HapticFeedback.lightImpact();
      await ref.read(feedbackListProvider.notifier).deleteFeedback(feedback.id.toString());
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text('$value', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: color)),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final FeedbackModel feedback;
  final VoidCallback onReview;
  final VoidCallback onResolve;
  final VoidCallback onDelete;

  const _FeedbackCard({
    required this.feedback,
    required this.onReview,
    required this.onResolve,
    required this.onDelete,
  });

  Color get _statusColor {
    switch (feedback.status) {
      case 'reviewed': return Colors.blue;
      case 'resolved': return Colors.green;
      default: return Colors.amber;
    }
  }

  String get _formattedDate {
    try {
      final dt = DateTime.parse(feedback.createdAt);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return feedback.createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  feedback.email ?? 'Anonymous',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  feedback.status,
                  style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (feedback.subject != null && feedback.subject!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(feedback.subject!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ],
          const SizedBox(height: 6),
          Text(
            feedback.comment,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(_formattedDate, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
              const Spacer(),
              if (feedback.status == 'pending')
                _ActionBtn(label: 'Review', color: Colors.blue, onTap: onReview),
              const SizedBox(width: 6),
              if (feedback.status != 'resolved')
                _ActionBtn(label: 'Resolve', color: Colors.green, onTap: onResolve),
              const SizedBox(width: 6),
              _ActionBtn(label: 'Delete', color: Colors.red, onTap: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
