import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/buildings_provider.dart';
import '../../widgets/building_card.dart';
import '../../widgets/skeleton_card.dart';
import '../../widgets/category_chip_bar.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = ref.watch(buildingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Places'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CategoryChipBar(
              selected: _selectedCategory,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ),
          ),
        ),
      ),
      body: buildingsAsync.when(
        data: (buildings) {
          final filtered = _selectedCategory == 'All'
              ? buildings
              : buildings.where((b) => b.category == _selectedCategory).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(buildingsProvider.notifier).refresh(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    '${filtered.length} location${filtered.length != 1 ? 's' : ''}'
                    '${_selectedCategory != 'All' ? ' in $_selectedCategory' : ''}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: filtered.isEmpty
                        ? _EmptyState(category: _selectedCategory)
                        : GridView.builder(
                            key: ValueKey(_selectedCategory),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.78,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final b = filtered[i];
                              return BuildingCard(
                                building: b,
                                heroTag: 'building-image-${b.id}',
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context.push('/building/${b.id}');
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.78,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => const SkeletonCard(),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('Failed to load buildings', style: TextStyle(color: Colors.grey.shade500)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(buildingsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String category;
  const _EmptyState({required this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No locations found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          Text(
            'No buildings in "$category" category',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
