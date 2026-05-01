import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../data/models/building.dart';
import '../../providers/buildings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/building_bottom_sheet.dart';
import '../../widgets/skeleton_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buildingsAsync = ref.watch(buildingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Buildings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: buildingsAsync.when(
        data: (buildings) => RefreshIndicator(
          onRefresh: () => ref.read(buildingsProvider.notifier).refresh(),
          child: buildings.isEmpty
              ? const Center(child: Text('No buildings yet. Add one!'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: buildings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _BuildingAdminCard(
                    building: buildings[i],
                    onEdit: () => _openSheet(context, ref, building: buildings[i]),
                    onDelete: () => _confirmDelete(context, ref, buildings[i]),
                  ),
                ),
        ),
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, __) => const SizedBox(height: 80, child: SkeletonCard()),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('$e'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(buildingsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSheet(context, ref),
        backgroundColor: AppConstants.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _openSheet(BuildContext context, WidgetRef ref, {Building? building}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BuildingBottomSheet(
        building: building,
        onSaved: () => ref.read(buildingsProvider.notifier).refresh(),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Building building) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Building'),
        content: Text('Are you sure you want to delete "${building.name}"?'),
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
      await ref.read(buildingsProvider.notifier).deleteBuilding(building.id.toString());
    }
  }
}

class _BuildingAdminCard extends StatelessWidget {
  final Building building;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BuildingAdminCard({
    required this.building,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = AppConstants.imageUrl(building.images);
    final catColor = AppConstants.categoryColor(building.category);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 72, height: 72,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(building.name, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(building.category, style: TextStyle(color: catColor, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red), onPressed: onDelete),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 72, height: 72,
        color: Colors.grey.shade800,
        child: const Icon(Icons.business, color: Colors.grey),
      );
}
