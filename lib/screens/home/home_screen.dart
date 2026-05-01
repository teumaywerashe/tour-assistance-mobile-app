import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../providers/buildings_provider.dart';
import '../../widgets/theme_toggle_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = ref.watch(buildingsProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            // Hero section
            SliverToBoxAdapter(
              child: SizedBox(
                height: size.height * 0.55,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image
                    Image.asset(
                      'assets/images/gate.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
                          ),
                        ),
                      ),
                    ),
                    // Dark gradient overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                          stops: [0.3, 1.0],
                        ),
                      ),
                    ),
                    // Top bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 32,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.school,
                                  color: AppConstants.accent,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'AAU Campus Tour',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              const ThemeToggleButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Hero text
                    Positioned(
                      bottom: 80,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore Your Campus',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          )
                              .animate()
                              .slideY(begin: 0.3, duration: 600.ms)
                              .fadeIn(duration: 600.ms),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Find ',
                                style: TextStyle(color: Colors.white70, fontSize: 18),
                              ),
                              AnimatedTextKit(
                                repeatForever: true,
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    'Buildings',
                                    textStyle: const TextStyle(
                                      color: AppConstants.accent,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    speed: const Duration(milliseconds: 80),
                                  ),
                                  TypewriterAnimatedText(
                                    'Libraries',
                                    textStyle: const TextStyle(
                                      color: AppConstants.accent,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    speed: const Duration(milliseconds: 80),
                                  ),
                                  TypewriterAnimatedText(
                                    'Labs',
                                    textStyle: const TextStyle(
                                      color: AppConstants.accent,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    speed: const Duration(milliseconds: 80),
                                  ),
                                  TypewriterAnimatedText(
                                    'Sports Halls',
                                    textStyle: const TextStyle(
                                      color: AppConstants.accent,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    speed: const Duration(milliseconds: 80),
                                  ),
                                  TypewriterAnimatedText(
                                    'Offices',
                                    textStyle: const TextStyle(
                                      color: AppConstants.accent,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    speed: const Duration(milliseconds: 80),
                                  ),
                                ],
                              ),
                            ],
                          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                        ],
                      ),
                    ),
                    // Search bar
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => context.go('/map'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: AppConstants.accent),
                              const SizedBox(width: 12),
                              Text(
                                'Search buildings, labs, offices...',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ).animate().slideY(begin: 0.2, delay: 400.ms, duration: 500.ms).fadeIn(delay: 400.ms),
                    ),
                  ],
                ),
              ),
            ),

            // Quick access cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Access',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _QuickCard(
                          icon: Icons.business,
                          label: 'Find Buildings',
                          color: const Color(0xFF3b82f6),
                          onTap: () => context.go('/categories'),
                        ),
                        const SizedBox(width: 12),
                        _QuickCard(
                          icon: Icons.map,
                          label: 'Interactive Map',
                          color: const Color(0xFF22c55e),
                          onTap: () => context.go('/map'),
                        ),
                        const SizedBox(width: 12),
                        _QuickCard(
                          icon: Icons.info_outline,
                          label: 'About',
                          color: AppConstants.accent,
                          onTap: () => context.go('/about'),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
            ),

            // Stats row
            SliverToBoxAdapter(
              child: buildingsAsync.when(
                data: (buildings) => _StatsRow(buildingCount: buildings.length),
                loading: () => const _StatsRow(buildingCount: 0),
                error: (_, __) => const _StatsRow(buildingCount: 0),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            ),

            // Featured locations
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  'Featured Locations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: buildingsAsync.when(
                data: (buildings) => _FeaturedList(buildings: buildings.take(5).toList()),
                loading: () => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int buildingCount;
  const _StatsRow({required this.buildingCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(value: buildingCount > 0 ? '$buildingCount+' : '30+', label: 'Buildings'),
            _Divider(),
            const _StatItem(value: '5+', label: 'Categories'),
            _Divider(),
            const _StatItem(value: '360°', label: 'Map'),
            _Divider(),
            const _StatItem(value: '5K+', label: 'Students'),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.3));
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppConstants.accent)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}

class _FeaturedList extends StatelessWidget {
  final List buildings;
  const _FeaturedList({required this.buildings});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: buildings.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final b = buildings[i];
          final imageUrl = AppConstants.imageUrl(b.images);
          return GestureDetector(
            onTap: () => context.push('/building/${b.id}'),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).cardColor,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(color: Colors.grey.shade800),
                        )
                      : Container(color: Colors.grey.shade800, child: const Icon(Icons.business, color: Colors.grey)),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      b.name,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
