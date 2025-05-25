import 'package:geotypes/geotypes.dart';
import 'package:turf/clone.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';
import 'package:rbush/rbush.dart';
import 'dart:math' as math;

enum Dbscan {
  core,
  edge,
  noise,
}

class DbscanProps extends Properties {
  Dbscan? dbscan;
  int? cluster;

  DbscanProps({this.dbscan, this.cluster, super.properties});

  factory DbscanProps.fromJson(Map<String, dynamic> json) {
    return DbscanProps(
      dbscan: Dbscan.values.byName(json['dbscan']),
      cluster: json['cluster'] as int?,
      properties: json,
    );
  }

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('dbscan', dbscan?.name);
    writeNotNull('cluster', cluster);
    if (properties != null) {
      val.addAll(properties!);
    }
    return val;
  }
}

class IndexedPoint implements HasExtent {
  double minX;
  double minY;
  double maxX;
  double maxY;
  int index;

  IndexedPoint({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.index,
  });

  @override
  Extent get extent => Extent(minX, minY, maxX, maxY);
}

FeatureCollection clustersDbscan(
  FeatureCollection<Point> points,
  double maxDistance, {
  Units units = Units.kilometers,
  bool mutate = false,
  int minPoints = 3,
}) {
  // Input validation (Dart's type system helps here, but we can add more runtime checks if needed)
  if (maxDistance <= 0) {
    throw ArgumentError('maxDistance must be greater than 0');
  }
  if (minPoints <= 0) {
    throw ArgumentError('minPoints must be greater than 0');
  }

  // Clone points to prevent mutations
  FeatureCollection<Point> processedPoints =
      mutate ? points : clone(points) as FeatureCollection<Point>;

  // Calculate the distance in degrees for region queries
  final double latDistanceInDegrees = lengthToDegrees(maxDistance, unit: units);

  // Create a spatial index
  final RBush<IndexedPoint> tree = RBush<IndexedPoint>(maxEntries: points.features.length);

  // Keeps track of whether a point has been visited or not.
  final List<bool> visited = List<bool>.filled(processedPoints.features.length, false);

  // Keeps track of whether a point is assigned to a cluster or not.
  final List<bool> assigned = List<bool>.filled(processedPoints.features.length, false);

  // Keeps track of whether a point is noise|edge or not.
  final List<bool> isnoise = List<bool>.filled(processedPoints.features.length, false);

  // Keeps track of the clusterId for each point
  final List<int> clusterIds = List<int>.filled(processedPoints.features.length, -1);

  // Index each point for spatial queries
  tree.load(
    processedPoints.features.asMap().entries.map((entry) {
      final int index = entry.key;
      final Point point = entry.value;
      final List<double> coordinates = point.coordinates as List<double>;
      final double x = coordinates[0];
      final double y = coordinates[1];
      return IndexedPoint(
        minX: x,
        minY: y,
        maxX: x,
        maxY: y,
        index: index,
      );
    }).toList(),
  );

  // Function to find neighbors of a point within a given distance
  List<IndexedPoint> regionQuery(int index) {
    final Point point = processedPoints.features[index];
    final List<double> coordinates = point.coordinates as List<double>;
    final double x = coordinates[0];
    final double y = coordinates[1];

    final double minY = math.max(y - latDistanceInDegrees, -90.0);
    final double maxY = math.min(y + latDistanceInDegrees, 90.0);

    double lonDistanceInDegrees = () {
      // Handle the case where the bounding box crosses the poles
      if (minY < 0 && maxY > 0) {
        return latDistanceInDegrees;
      }
      if (minY.abs() < maxY.abs()) {
        return latDistanceInDegrees / math.cos(degreesToRadians(maxY));
      } else {
        return latDistanceInDegrees / math.cos(degreesToRadians(minY));
      }
    }();

    final double minX = math.max(x - lonDistanceInDegrees, -360.0);
    final double maxX = math.min(x + lonDistanceInDegrees, 360.0);

    // Calculate the bounding box for the region query
    final Extent bbox = Extent(minX, minY, maxX, maxY);
    return tree.search(bbox).where((neighbor) {
      final int neighborIndex = neighbor.index;
      final Point neighborPoint = processedPoints.features[neighborIndex];
      final double distanceInKm = distance(point, neighborPoint, units: Units.kilometers);
      return distanceInKm <= maxDistance;
    }).toList();
  }

  // Function to expand a cluster
  void expandCluster(int clusteredId, List<IndexedPoint> neighbors) {
    for (int i = 0; i < neighbors.length; i++) {
      final IndexedPoint neighbor = neighbors[i];
      final int neighborIndex = neighbor.index;
      if (!visited[neighborIndex]) {
        visited[neighborIndex] = true;
        final List<IndexedPoint> nextNeighbors = regionQuery(neighborIndex);
        if (nextNeighbors.length >= minPoints) {
          neighbors.addAll(nextNeighbors);
        }
      }
      if (!assigned[neighborIndex]) {
        assigned[neighborIndex] = true;
        clusterIds[neighborIndex] = clusteredId;
      }
    }
  }

  // Main DBSCAN clustering algorithm
  int nextClusteredId = 0;
  processedPoints.features.asMap().forEach((index, _) {
    if (visited[index]) return;
    final List<IndexedPoint> neighbors = regionQuery(index);
    if (neighbors.length >= minPoints) {
      final int clusteredId = nextClusteredId++;
      visited[index] = true;
      expandCluster(clusteredId, neighbors);
    } else {
      isnoise[index] = true;
    }
  });

  // Assign DBSCAN properties to each point
  final List<Feature<Point, DbscanProps>> clusteredFeatures =
      processedPoints.features.asMap().entries.map((entry) {
    final int index = entry.key;
    final Point clusterPoint = entry.value;
    final DbscanProps properties = DbscanProps();

    if (clusterIds[index] >= 0) {
      properties.dbscan = isnoise[index] ? Dbscan.edge : Dbscan.core;
      properties.cluster = clusterIds[index];
    } else {
      properties.dbscan = Dbscan.noise;
    }
    return Feature<Point, DbscanProps>(geometry: clusterPoint, properties: properties);
  }).toList();

  return FeatureCollection<Point, DbscanProps>(features: clusteredFeatures);
}
