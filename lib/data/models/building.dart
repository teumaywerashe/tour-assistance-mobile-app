import 'dart:convert';
import 'floor_info.dart';

class Building {
  final dynamic id;
  final String name;
  final String category;
  final String description;
  final String? images;
  final double lat;
  final double lng;
  final dynamic nearestNode;
  final String hours;
  final String location;
  final List<String> tags;
  final FloorInfo floorinfo;

  const Building({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.images,
    required this.lat,
    required this.lng,
    this.nearestNode,
    required this.hours,
    required this.location,
    required this.tags,
    required this.floorinfo,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      images: json['images'],
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      nearestNode: json['nearestNode'],
      hours: json['hours'] ?? '',
      location: json['location'] ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      floorinfo: _parseFloorInfo(json['floorinfo']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
        'images': images,
        'lat': lat,
        'lng': lng,
        'nearestNode': nearestNode,
        'hours': hours,
        'location': location,
        'tags': tags,
        'floorinfo': floorinfo.toJson(),
      };

  List<String> get nearestNodes {
    if (nearestNode == null) return [];
    if (nearestNode is List) return List<String>.from(nearestNode);
    return [nearestNode.toString()];
  }

  static FloorInfo _parseFloorInfo(dynamic value) {
    if (value == null) return const FloorInfo(floors: 1, rooms: 0);
    if (value is Map<String, dynamic>) return FloorInfo.fromJson(value);
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return FloorInfo.fromJson(decoded);
      } catch (_) {}
    }
    return const FloorInfo(floors: 1, rooms: 0);
  }
}
