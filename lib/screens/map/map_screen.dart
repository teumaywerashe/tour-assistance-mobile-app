import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../data/models/building.dart';
import '../../data/navigation_data.dart';
import '../../providers/buildings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/route_info_card.dart';
import '../../widgets/category_chip_bar.dart';

class MapScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  final String? initialBuildingId;

  const MapScreen({super.key, this.initialQuery, this.initialBuildingId});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  Building? _selectedBuilding; // tracks tapped marker for sheet state
  LatLng? _userLocation;
  List<LatLng> _routePoints = [];
  double _routeDistance = 0;
  bool _locating = false;
  bool _pulseVisible = true;
  Timer? _pulseTimer;

  static const _campusCenter = LatLng(9.0409, 38.7621);
  static final _campusBounds = LatLngBounds(
    LatLng(9.038, 38.760),
    LatLng(9.043, 38.766),
  );

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (mounted) setState(() => _pulseVisible = !_pulseVisible);
    });
    if (widget.initialBuildingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _selectBuildingById(widget.initialBuildingId!));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pulseTimer?.cancel();
    super.dispose();
  }

  void _selectBuildingById(String id) {
    final buildings = ref.read(buildingsProvider).valueOrNull ?? [];
    final b = buildings.firstWhere((b) => b.id.toString() == id, orElse: () => buildings.first);
    _onMarkerTap(b);
  }

  Future<void> _locateUser() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied. Enable in settings.')),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _userLocation = LatLng(pos.latitude, pos.longitude));
      _mapController.move(_userLocation!, 17);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _onMarkerTap(Building building) {
    setState(() => _selectedBuilding = building);
    _mapController.move(LatLng(building.lat, building.lng), 17.5);
    _showBuildingSheet(building);
  }

  void _navigateTo(Building building) {
    if (_userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enable location first to navigate')),
      );
      return;
    }
    final startNode = findNearestNode(_userLocation!.latitude, _userLocation!.longitude);
    final endNodes = building.nearestNodes;
    if (endNodes.isEmpty) return;

    List<String> bestPath = [];
    for (final endNode in endNodes) {
      final path = findShortestPath(startNode, endNode);
      if (bestPath.isEmpty || path.length < bestPath.length) bestPath = path;
    }

    if (bestPath.isEmpty) return;

    final routePoints = [
      _userLocation!,
      ...bestPath.map((n) => campusNodes[n]!),
      LatLng(building.lat, building.lng),
    ];

    double dist = 0;
    for (int i = 0; i < routePoints.length - 1; i++) {
      dist += const Distance().as(LengthUnit.Meter, routePoints[i], routePoints[i + 1]);
    }

    setState(() {
      _routePoints = routePoints;
      _routeDistance = dist;
    });
    Navigator.of(context).pop(); // close sheet
  }

  void _showBuildingSheet(Building building) {
    final imageUrl = AppConstants.imageUrl(building.images);
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 72, height: 72,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _imgPlaceholder(),
                        )
                      : _imgPlaceholder(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(building.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppConstants.categoryColor(building.category).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          building.category,
                          style: TextStyle(
                            color: AppConstants.categoryColor(building.category),
                            fontSize: 11, fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(building.hours, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('View Details'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/building/${building.id}');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text('Navigate'),
                    onPressed: () => _navigateTo(building),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        width: 72, height: 72,
        color: Colors.grey.shade800,
        child: const Icon(Icons.business, color: Colors.grey),
      );

  List<Building> _filteredBuildings(List<Building> all) {
    final query = _searchController.text.toLowerCase();
    return all.where((b) {
      final matchCat = _selectedCategory == 'All' || b.category == _selectedCategory;
      final matchQuery = query.isEmpty ||
          b.name.toLowerCase().contains(query) ||
          b.location.toLowerCase().contains(query);
      return matchCat && matchQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = ref.watch(buildingsProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final tileUrl = isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Map
            buildingsAsync.when(
              data: (buildings) {
                final filtered = _filteredBuildings(buildings);
                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _campusCenter,
                    initialZoom: 17,
                    minZoom: 15,
                    maxZoom: 19,
                    cameraConstraint: CameraConstraint.containCenter(bounds: _campusBounds),
                    onTap: (_, __) => setState(() => _selectedBuilding = null),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: tileUrl,
                      subdomains: isDark ? ['a', 'b', 'c'] : [],
                      userAgentPackageName: 'com.example.tour_assistance',
                    ),
                    // Route polyline
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: AppConstants.accent,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    // Building markers
                    MarkerLayer(
                      markers: filtered.map((b) {
                        final color = AppConstants.categoryColor(b.category);
                        return Marker(
                          point: LatLng(b.lat, b.lng),
                          width: 36,
                          height: 36,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _onMarkerTap(b);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)],
                              ),
                              child: const Icon(Icons.business, color: Colors.white, size: 18),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    // User location
                    if (_userLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _userLocation!,
                            width: 24,
                            height: 24,
                            child: AnimatedOpacity(
                              opacity: _pulseVisible ? 1.0 : 0.4,
                              duration: const Duration(milliseconds: 400),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppConstants.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [BoxShadow(color: AppConstants.accent.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),

            // Search + filter overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search buildings...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    CategoryChipBar(
                      selected: _selectedCategory,
                      onSelected: (cat) => setState(() => _selectedCategory = cat),
                    ),
                  ],
                ),
              ),
            ),

            // Route info card
            if (_routePoints.isNotEmpty)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: RouteInfoCard(
                  distanceMeters: _routeDistance,
                  onClear: () => setState(() {
                    _routePoints = [];
                    _routeDistance = 0;
                  }),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _locateUser();
        },
        backgroundColor: AppConstants.accent,
        child: _locating
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
