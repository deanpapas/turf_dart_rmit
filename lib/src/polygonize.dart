import 'package:turf/helpers.dart';
import 'package:turf/src/invariant.dart';
import 'package:turf/src/meta/flatten.dart';
import 'package:turf/src/booleans/boolean_clockwise.dart';

/// Edge representation for the graph
class Edge {
  final Position from;
  final Position to;
  bool visited = false;
  String? label;

  Edge(this.from, this.to);

  @override
  String toString() => '$from -> $to';

  /// Get canonical edge key (ordered by coordinates)
  String get key {
    final fromStr = '${from[0]},${from[1]}';
    final toStr = '${to[0]},${to[1]}';
    return fromStr.compareTo(toStr) <= 0 ? '$fromStr|$toStr' : '$toStr|$fromStr';
  }

  /// Get the key as directed edge
  String get directedKey => '${from[0]},${from[1]}|${to[0]},${to[1]}';

  /// Create a reversed edge
  Edge reversed() => Edge(to, from);
}

/// Node in the graph, representing a vertex with its edges
class Node {
  final Position position;
  final List<Edge> edges = [];

  Node(this.position);

  void addEdge(Edge edge) {
    edges.add(edge);
  }

  /// Get string representation for use as a map key
  String get key => '${position[0]},${position[1]}';
}

/// Graph representing a planar graph of edges and nodes
class Graph {
  final Map<String, Node> nodes = {};
  final Map<String, Edge> edges = {};

  /// Add an edge to the graph
  void addEdge(Position from, Position to) {
    // Skip edges with identical start and end points
    if (from[0] == to[0] && from[1] == to[1]) {
      return;
    }

    // Create a canonical edge key to avoid duplicates
    final fromKey = '${from[0]},${from[1]}';
    final toKey = '${to[0]},${to[1]}';
    final edgeKey = fromKey.compareTo(toKey) < 0 ? '$fromKey|$toKey' : '$toKey|$fromKey';

    // Skip duplicate edges
    if (edges.containsKey(edgeKey)) {
      return;
    }

    // Create and store the edge
    final edge = Edge(from, to);
    edges[edgeKey] = edge;

    // Add from node if it doesn't exist
    if (!nodes.containsKey(fromKey)) {
      nodes[fromKey] = Node(from);
    }
    nodes[fromKey]!.addEdge(edge);

    // Add to node if it doesn't exist
    if (!nodes.containsKey(toKey)) {
      nodes[toKey] = Node(to);
    }
    nodes[toKey]!.addEdge(Edge(to, from));
  }

  /// Find all rings in the graph
  List<List<Position>> findRings() {
    final allEdges = Map<String, Edge>.from(edges);
    final rings = <List<Position>>[];

    // Process edges until none are left
    while (allEdges.isNotEmpty) {
      // Take the first available edge
      final edgeKey = allEdges.keys.first;
      final edge = allEdges.remove(edgeKey)!;

      // Try to find a ring starting with this edge
      final ring = _findRing(edge, allEdges);
      if (ring != null && ring.length >= 3) {
        rings.add(ring);
      }
    }

    return rings;
  }

  /// Find a ring starting from the given edge, removing used edges from the availableEdges map
  List<Position>? _findRing(Edge startEdge, Map<String, Edge> availableEdges) {
    final ring = <Position>[];
    Position currentPos = startEdge.from;
    Position targetPos = startEdge.to;
    
    // Add the first point
    ring.add(currentPos);
    
    // Continue until we either complete the ring or determine it's not possible
    while (true) {
      // Move to the next position
      currentPos = targetPos;
      ring.add(currentPos);
      
      // If we've reached the starting point, we've found a ring
      if (currentPos[0] == ring[0][0] && currentPos[1] == ring[0][1]) {
        return ring;
      }
      
      // Find the next edge that continues the path
      Edge? nextEdge = _findNextEdge(currentPos, availableEdges);
      
      // If no more edges, this is not a ring
      if (nextEdge == null) {
        return null;
      }
      
      // Remove the edge from available edges
      final nextEdgeKey = _edgeKey(nextEdge.from, nextEdge.to);
      availableEdges.remove(nextEdgeKey);
      
      // Set the next target
      targetPos = nextEdge.to;
    }
  }
  
  /// Find the next edge to follow from the current position
  Edge? _findNextEdge(Position currentPos, Map<String, Edge> availableEdges) {
    final currentKey = '${currentPos[0]},${currentPos[1]}';
    
    // Check all available edges
    for (final edge in availableEdges.values) {
      final fromKey = '${edge.from[0]},${edge.from[1]}';
      final toKey = '${edge.to[0]},${edge.to[1]}';
      
      // If edge starts at current position, use it
      if (fromKey == currentKey) {
        return edge;
      }
      
      // If edge ends at current position, use it in reverse
      if (toKey == currentKey) {
        return Edge(edge.to, edge.from);
      }
    }
    
    return null;
  }
  
  /// Create a canonical edge key
  String _edgeKey(Position from, Position to) {
    final fromKey = '${from[0]},${from[1]}';
    final toKey = '${to[0]},${to[1]}';
    return fromKey.compareTo(toKey) < 0 ? '$fromKey|$toKey' : '$toKey|$fromKey';
  }
}

/// Converts a collection of LineString features to a collection of Polygon features.
///
/// Takes a [FeatureCollection<LineString>] and returns a [FeatureCollection<Polygon>].
/// The input features must be correctly noded, meaning they should only meet at their endpoints.
///
/// Example:
/// ```dart
/// var lines = FeatureCollection(features: [
///   Feature(geometry: LineString(coordinates: [
///     Position.of([0, 0]),
///     Position.of([10, 0])
///   ])),
///   Feature(geometry: LineString(coordinates: [
///     Position.of([10, 0]),
///     Position.of([10, 10])
///   ])),
///   Feature(geometry: LineString(coordinates: [
///     Position.of([10, 10]),
///     Position.of([0, 10])
///   ])),
///   Feature(geometry: LineString(coordinates: [
///     Position.of([0, 10]),
///     Position.of([0, 0])
///   ]))
/// ]);
///
/// var polygons = polygonize(lines);
/// ```
FeatureCollection<Polygon> polygonize(GeoJSONObject geoJSON) {
  // Create a planar graph from all segments
  final graph = Graph();
  
  // Function to add line segments to the graph
  void addLine(List<Position> coords) {
    if (coords.length < 2) return;
    
    for (var i = 0; i < coords.length - 1; i++) {
      graph.addEdge(coords[i], coords[i + 1]);
    }
  }
  
  // Process all LineString and MultiLineString features and add them to the graph
  flattenEach(geoJSON, (currentFeature, featureIndex, multiFeatureIndex) {
    final geometry = currentFeature.geometry!;
    
    if (geometry is LineString) {
      final coords = getCoords(geometry) as List<Position>;
      addLine(coords);
    } else if (geometry is MultiLineString) {
      final multiCoords = getCoords(geometry) as List<List<Position>>;
      for (final coords in multiCoords) {
        addLine(coords);
      }
    } else {
      throw ArgumentError('Input must be a LineString, MultiLineString, or a FeatureCollection of these types');
    }
  });
  
  // Find all rings in the graph
  final rings = graph.findRings();
  
  // Convert rings to polygons
  final features = <Feature<Polygon>>[];
  for (final ring in rings) {
    // Ensure the ring is closed (first and last points match)
    final closedRing = List<Position>.from(ring);
    if (closedRing.first[0] != closedRing.last[0] || closedRing.first[1] != closedRing.last[1]) {
      // Create a new position with the same coordinates as the first
      final firstPos = closedRing.first;
      final closePos = _createPosition(firstPos);
      closedRing.add(closePos);
    }
    
    // Ensure correct orientation (exterior rings should be clockwise)
    final lineString = LineString(coordinates: closedRing);
    if (!booleanClockwise(lineString)) {
      closedRing.removeAt(closedRing.length - 1);
      // Reverse the list correctly and preserve altitude if present
      final reversedRing = closedRing.reversed.toList();
      closedRing.clear();
      closedRing.addAll(reversedRing);
      
      // Add closing point
      final firstPos = closedRing.first;
      final closePos = _createPosition(firstPos);
      closedRing.add(closePos);
    }
    
    final polygon = Polygon(coordinates: [closedRing]);
    features.add(Feature<Polygon>(geometry: polygon));
  }
  
  return FeatureCollection<Polygon>(features: features);
}

/// Helper function to create a new Position from an existing one
/// Handles null safety for Position coordinates
Position _createPosition(Position source) {
  if (source.length > 2 && source[2] != null) {
    return Position.of([
      source[0]!,
      source[1]!,
      source[2]!,
    ]);
  } else {
    return Position.of([
      source[0]!,
      source[1]!,
    ]);
  }
}
