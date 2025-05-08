import 'dart:math';

import 'package:turf/turf.dart';


// Returns a random Position within a Bbox
// Dart Random function module is obtained from dart:math

Position randomPosition(BBox? bbox) {
  checkBBox(bbox);
  return randomPositionUnchecked(bbox); 
}

// Returns a Random Position without checking if it is valid
Position randomPositionUnchecked(BBox? bbox) {
  if (bbox != null) {
    return coordInBBox(bbox);
  }
  return Position(Random().nextDouble() * 360 - 180, Random().nextDouble() * 180 - 90); // else return any random coordinate on the globe 
}

// 
void checkBBox(BBox? bbox) {
  if (bbox == null) {
    return; 
  }
}
// Returns a 
Position coordInBBox(BBox? bbox) {
  if (bbox == null) {
    throw ArgumentError("Bbox cannot be null.");
  }
  if (bbox.length != 4) {
    throw ArgumentError("Bbox must contain exactly 4 values.");
  }
  return Position(
    bbox[0]! + Random().nextDouble() * (bbox[2]! - bbox[0]!),
    bbox[1]! + Random().nextDouble() * (bbox[3]! - bbox[1]!)
  );
}