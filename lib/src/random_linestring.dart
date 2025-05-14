import 'dart:math';
import 'package:turf/src/random_position.dart';
import 'package:turf/turf.dart';

// Returns a random linestring

Feature<LineString> randomLineString(
  count, {
  BBox? bbox,
  numVertices, 
  maxLength, 
  maxRotation}) {

  void checkBBox(BBox? bbox) {
  if (bbox == null) {
    return; 
  }
  }

  checkBBox(bbox);

  numVertices = 10;
  maxLength = 0.0001;
  maxRotation = pi / 8;

  if (count <= 0) {
    throw ArgumentError('Count must be set to a positive integer to return a LineString.');
  }

  for (i= 0)
  

}