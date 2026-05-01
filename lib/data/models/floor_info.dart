class FloorInfo {
  final int floors;
  final int rooms;
  final List<String>? depts;

  const FloorInfo({
    required this.floors,
    required this.rooms,
    this.depts,
  });

  factory FloorInfo.fromJson(Map<String, dynamic> json) {
    return FloorInfo(
      floors: (json['floors'] as num?)?.toInt() ?? 1,
      rooms: (json['rooms'] as num?)?.toInt() ?? 0,
      depts: json['depts'] != null
          ? List<String>.from(json['depts'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'floors': floors,
        'rooms': rooms,
        if (depts != null) 'depts': depts,
      };
}
