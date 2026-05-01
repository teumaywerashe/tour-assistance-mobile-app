import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants.dart';
import '../../data/models/building.dart';
import '../../data/repositories/building_repository.dart';

class BuildingDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const BuildingDetailScreen({super.key, required this.id});

  @override
  ConsumerState<BuildingDetailScreen> createState() => _BuildingDetailScreenState();
}

class _BuildingDetailScreenState extends ConsumerState<BuildingDetailScreen> {
  Building? _building;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBuilding();
  }

  Future<void> _loadBuilding() async {
    try {
      final b = await BuildingRepository().getBuilding(widget.id);
      if (mounted) setState(() { _building = b; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _building == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_error ?? 'Building not found'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadBuilding, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final b = _building!;
    final imageUrl = AppConstants.imageUrl(b.images);
    final catColor = AppConstants.categoryColor(b.category);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Share.share('Check out ${b.name} at AAU 5 Kilo Campus!\n${b.location}');
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'building-image-${b.id}',
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + category
                    Text(
                      b.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        b.category,
                        style: TextStyle(color: catColor, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Info rows
                    _InfoRow(icon: Icons.location_on_outlined, text: b.location),
                    _InfoRow(icon: Icons.access_time_outlined, text: b.hours),
                    _InfoRow(
                      icon: Icons.business_outlined,
                      text: '${b.floorinfo.floors} floor${b.floorinfo.floors != 1 ? 's' : ''} · ${b.floorinfo.rooms} rooms',
                    ),
                    if (b.floorinfo.depts != null && b.floorinfo.depts!.isNotEmpty)
                      _InfoRow(
                        icon: Icons.account_balance_outlined,
                        text: b.floorinfo.depts!.join(', '),
                      ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),

                    // About
                    Text('About', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(b.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),

                    // Tags
                    if (b.tags.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: b.tags.map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 12)),
                          backgroundColor: AppConstants.accent.withOpacity(0.1),
                          side: BorderSide(color: AppConstants.accent.withOpacity(0.3)),
                          labelStyle: const TextStyle(color: AppConstants.accent),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        )).toList(),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Navigate button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Navigate on Map'),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.go('/map?building=${b.id}');
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey.shade800,
        child: const Center(child: Icon(Icons.business, color: Colors.grey, size: 64)),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppConstants.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
