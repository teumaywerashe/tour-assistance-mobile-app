import 'package:latlong2/latlong.dart';

const Map<String, LatLng> campusNodes = {
  'N0':  LatLng(9.040958, 38.762185),
  'N1':  LatLng(9.041049, 38.762519),
  'N2':  LatLng(9.041107, 38.762786),
  'N33': LatLng(9.041210, 38.763010),
  'N34': LatLng(9.041159, 38.763022),
  'N3':  LatLng(9.041268, 38.763273),
  'N30': LatLng(9.041277, 38.763311),
  'N29': LatLng(9.040908, 38.763397),
  'N4':  LatLng(9.041377, 38.763759),
  'N5':  LatLng(9.041354, 38.763667),
  'N6':  LatLng(9.040986, 38.763740),
  'N7':  LatLng(9.040942, 38.763548),
  'N8':  LatLng(9.040869, 38.763250),
  'N9':  LatLng(9.040805, 38.762985),
  'N10': LatLng(9.040782, 38.762848),
  'N11': LatLng(9.040736, 38.762855),
  'N31': LatLng(9.040675, 38.762587),
  'N32': LatLng(9.040262, 38.762673),
  'N12': LatLng(9.040337, 38.762933),
  'N13': LatLng(9.040324, 38.762937),
  'N14': LatLng(9.040452, 38.763499),
  'N15': LatLng(9.040669, 38.763430),
  'N16': LatLng(9.040272, 38.763533),
  'N17': LatLng(9.040149, 38.763558),
  'N18': LatLng(9.040060, 38.763254),
  'N19': LatLng(9.039817, 38.763404),
  'N20': LatLng(9.039950, 38.762885),
  'N21': LatLng(9.039863, 38.762885),
  'N22': LatLng(9.039626, 38.763504),
  'N23': LatLng(9.039718, 38.763563),
  'N24': LatLng(9.039719, 38.764243),
  'N25': LatLng(9.040958, 38.763943),
  'N26': LatLng(9.040450, 38.763974),
  'N27': LatLng(9.040058, 38.764121),
  'N28': LatLng(9.039654, 38.762597),
};

const List<List<String>> campusEdges = [
  ['N0', 'N1'], ['N1', 'N2'], ['N2', 'N33'], ['N33', 'N34'],
  ['N34', 'N3'], ['N3', 'N30'], ['N30', 'N4'], ['N4', 'N5'],
  ['N5', 'N6'], ['N6', 'N7'], ['N7', 'N8'], ['N8', 'N9'],
  ['N9', 'N10'], ['N10', 'N11'], ['N11', 'N31'], ['N31', 'N32'],
  ['N32', 'N12'], ['N12', 'N13'], ['N13', 'N14'], ['N14', 'N15'],
  ['N15', 'N7'], ['N15', 'N29'], ['N29', 'N8'], ['N14', 'N16'],
  ['N16', 'N17'], ['N17', 'N18'], ['N18', 'N19'], ['N19', 'N20'],
  ['N20', 'N21'], ['N21', 'N28'], ['N22', 'N23'], ['N23', 'N19'],
  ['N22', 'N24'], ['N24', 'N27'], ['N27', 'N26'], ['N26', 'N25'],
  ['N25', 'N5'], ['N26', 'N14'], ['N9', 'N29'], ['N0', 'N31'],
  ['N28', 'N32'], ['N21', 'N22'],
];

/// Dijkstra's algorithm — returns ordered list of node IDs or empty if no path.
List<String> findShortestPath(String startNode, String endNode) {
  if (startNode == endNode) return [startNode];

  // Build adjacency map with distances
  final Map<String, Map<String, double>> graph = {};
  for (final edge in campusEdges) {
    final a = edge[0];
    final b = edge[1];
    final aPos = campusNodes[a]!;
    final bPos = campusNodes[b]!;
    final dist = const Distance().as(LengthUnit.Meter, aPos, bPos);
    graph.putIfAbsent(a, () => {})[b] = dist;
    graph.putIfAbsent(b, () => {})[a] = dist;
  }

  final distances = <String, double>{};
  final previous = <String, String?>{};
  final unvisited = <String>{};

  for (final node in campusNodes.keys) {
    distances[node] = double.infinity;
    previous[node] = null;
    unvisited.add(node);
  }
  distances[startNode] = 0;

  while (unvisited.isNotEmpty) {
    // Pick unvisited node with smallest distance
    String? current;
    double minDist = double.infinity;
    for (final node in unvisited) {
      if (distances[node]! < minDist) {
        minDist = distances[node]!;
        current = node;
      }
    }
    if (current == null || current == endNode) break;
    unvisited.remove(current);

    for (final neighbor in (graph[current] ?? {}).entries) {
      if (!unvisited.contains(neighbor.key)) continue;
      final alt = distances[current]! + neighbor.value;
      if (alt < distances[neighbor.key]!) {
        distances[neighbor.key] = alt;
        previous[neighbor.key] = current;
      }
    }
  }

  // Reconstruct path
  final path = <String>[];
  String? step = endNode;
  while (step != null) {
    path.insert(0, step);
    step = previous[step];
  }
  if (path.first != startNode) return [];
  return path;
}

/// Find the nearest campus node to a given lat/lng
String findNearestNode(double lat, double lng) {
  final pos = LatLng(lat, lng);
  String nearest = campusNodes.keys.first;
  double minDist = double.infinity;
  for (final entry in campusNodes.entries) {
    final d = const Distance().as(LengthUnit.Meter, pos, entry.value);
    if (d < minDist) {
      minDist = d;
      nearest = entry.key;
    }
  }
  return nearest;
}
