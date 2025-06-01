import 'dart:math';
import 'package:turf/turf.dart';

// Returns a random Point
// Dart Random function module is obtained from dart:math

FeatureCollection<Point> randomPoint(int? count, {BBox? bbox}) {
  count = validateCount(count); // Ensure count is valid

  List<Feature<Point>> features = [];
  for (int i = 0; i < count; i++) {
    features.add(
        Feature(geometry: randomPointUnchecked(bbox))); // Wrap Point in Feature
  }

  return FeatureCollection<Point>(
      features: features); // Properly return a FeatureCollection
}

// Returns a count of 1 if null or negative integer
int validateCount(int? count) {
  return (count == null || count <= 0) ? 1 : count;
}

// Returns a random point from randomPositionUnchecked
Point randomPointUnchecked(BBox? bbox) {
  Position pos = randomPositionUnchecked(bbox);
  return Point(coordinates: pos);
}

// Returns a random position from bbox if provided, else a random position on globe.
Position randomPositionUnchecked(BBox? bbox) {
  if (bbox != null) {
    return coordInBBox(bbox);
  }
  return Position(
      Random().nextDouble() * 360 - 180, Random().nextDouble() * 180 - 90);
}

// Returns a random position from bbox
Position coordInBBox(BBox? bbox) {
  return Position(bbox![0]! + Random().nextDouble() * (bbox[2]! - bbox[0]!),
      bbox[1]! + Random().nextDouble() * (bbox[3]! - bbox[1]!));
}
