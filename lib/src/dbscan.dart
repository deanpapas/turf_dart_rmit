import 'package:geotypes/geotypes.dart';
import 'package:turf/clone.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';
import 'package:rbush/rbush.dart';
import 'dart:math' as math;

// DBSCAN (Density-Based Spatial Clustering of Applications with Noise) is a data clustering algorithm.
// Given a set of points in some space, it groups together points that are closely packed together
// (points with many nearby neighbors), marking as outliers points that lie alone in low-density regions.

FeatureCollection<Point> dbscan(
  FeatureCollection<Point> points,
  int maxClusterLength,
  int minPoints,
  double maxRadius, {
  bool mutableInput = true,
}) {
  if (minPoints <= 0) {
    throw ArgumentError('minPoints must be greater than 0');
  }
  if (maxRadius < 0) {
    throw ArgumentError('maxRadius must be greater than or equal to 0');
  }

  final numberOfPoints = points.features.length;
  final clustered = mutableInput ? points : clone(points);
  final visited = List<bool>.filled(numberOfPoints, false);
  final noise = List<bool>.filled(numberOfPoints, false);
  int clusterId = 0;

  // Build an R-tree index for efficient neighbor searching
  final tree = RBush<Feature<Point>>(maxEntries: 9);
  for (int i = 0; i < numberOfPoints; i++) {
    final feature = clustered.features[i];
    if (feature.geometry != null) {
      tree.insert(feature.bbox!, feature);
    }
  }

  // Function to find neighbors within a given radius
  List<int> getNeighbors(int pointIndex) {
    final neighbors = <int>[];
    final targetPoint = clustered.features[pointIndex];
    if (targetPoint.geometry == null) {
      return neighbors;
    }
    final envelope = [
      targetPoint.bbox![0] - maxRadius,
      targetPoint.bbox![1] - maxRadius,
      targetPoint.bbox![2] + maxRadius,
      targetPoint.bbox![3] + maxRadius,
    ];

    final potentialNeighbors = tree.search(envelope);
    for (final neighborFeature in potentialNeighbors) {
      final neighborIndex = clustered.features.indexOf(neighborFeature);
      if (pointIndex != neighborIndex) {
        final distanceInMeters = distance(targetPoint, neighborFeature);
        if (distanceInMeters <= maxRadius) {
          neighbors.add(neighborIndex);
        }
      }
    }
    return neighbors;
  }

  // Expand the cluster recursively
  void expandCluster(int pointIndex, List<int> neighbors) {
    visited[pointIndex] = true;
    clustered.features[pointIndex].properties['cluster'] = clusterId;

    int i = 0;
    while (i < neighbors.length) {
      final neighborIndex = neighbors[i];
      if (!visited[neighborIndex]) {
        visited[neighborIndex] = true;
        clustered.features[neighborIndex].properties['cluster'] = clusterId;
        final newNeighbors = getNeighbors(neighborIndex);
        if (newNeighbors.length >= minPoints) {
          neighbors.addAll(newNeighbors.where((n) => !neighbors.contains(n)));
        }
      }
      i++;
    }
  }

  // Iterate through each point
  for (int i = 0; i < numberOfPoints; i++) {
    if (!visited[i]) {
      final neighbors = getNeighbors(i);
      if (neighbors.length < minPoints) {
        noise[i] = true;
      } else {
        expandCluster(i, neighbors);
        clusterId++;
        if (clusterId > maxClusterLength) {
          throw ArgumentError(
              'Cluster exceeded maxClusterLength ($maxClusterLength)');
        }
      }
    }
  }

  // Add the 'cluster' property to noise points (set to null or -1)
  for (int i = 0; i < numberOfPoints; i++) {
    if (noise[i]) {
      clustered.features[i].properties['cluster'] = null; // Or -1
    }
  }

  return clustered;
}