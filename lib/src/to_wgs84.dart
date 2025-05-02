import 'dart:math' as math;
import 'package:geotypes/geotypes.dart';
import 'package:turf/helpers.dart';

/// Converts a [GeoJSONObject] or [Position] from Web Mercator to WGS84 coordinates.
///
/// Accepts Mercator projection coordinates and returns WGS84 coordinates.
///
/// If [mutate] is true, the input object is mutated for performance.
///
/// See: https://epsg.io/4326
dynamic geoToWgs84(dynamic mercator, {bool mutate = false}) {
  // For simple Position objects, use the direct conversion
  if (mercator is Position) {
    return _toWgs84Position(mercator);
  }
  
  // Check that input is a GeoJSONObject for all other cases
  if (mercator is! GeoJSONObject) {
    throw ArgumentError('Unsupported input type: ${mercator.runtimeType}');
  }
  
  // Clone mercator to avoid side effects if not mutating
  final workingObject = !mutate ? (mercator as GeoJSONObject).clone() : mercator;
  
  // Handle different GeoJSON types
  if (workingObject is Point) {
    workingObject.coordinates = _toWgs84Position(workingObject.coordinates);
  } else if (workingObject is LineString) {
    for (var i = 0; i < workingObject.coordinates.length; i++) {
      workingObject.coordinates[i] = _toWgs84Position(workingObject.coordinates[i]);
    }
  } else if (workingObject is Polygon) {
    for (var i = 0; i < workingObject.coordinates.length; i++) {
      for (var j = 0; j < workingObject.coordinates[i].length; j++) {
        workingObject.coordinates[i][j] = _toWgs84Position(workingObject.coordinates[i][j]);
      }
    }
  } else if (workingObject is MultiPoint) {
    for (var i = 0; i < workingObject.coordinates.length; i++) {
      workingObject.coordinates[i] = _toWgs84Position(workingObject.coordinates[i]);
    }
  } else if (workingObject is MultiLineString) {
    for (var i = 0; i < workingObject.coordinates.length; i++) {
      for (var j = 0; j < workingObject.coordinates[i].length; j++) {
        workingObject.coordinates[i][j] = _toWgs84Position(workingObject.coordinates[i][j]);
      }
    }
  } else if (workingObject is MultiPolygon) {
    for (var i = 0; i < workingObject.coordinates.length; i++) {
      for (var j = 0; j < workingObject.coordinates[i].length; j++) {
        for (var k = 0; k < workingObject.coordinates[i][j].length; k++) {
          workingObject.coordinates[i][j][k] = _toWgs84Position(workingObject.coordinates[i][j][k]);
        }
      }
    }
  } else if (workingObject is GeometryCollection) {
    for (var i = 0; i < workingObject.geometries.length; i++) {
      workingObject.geometries[i] = geoToWgs84(workingObject.geometries[i], mutate: true);
    }
  } else if (workingObject is Feature) {
    if (workingObject.geometry != null) {
      workingObject.geometry = geoToWgs84(workingObject.geometry!, mutate: true);
    }
  } else if (workingObject is FeatureCollection) {
    for (var i = 0; i < workingObject.features.length; i++) {
      workingObject.features[i] = geoToWgs84(workingObject.features[i], mutate: true);
    }
  } else {
    throw ArgumentError('Unsupported input type: ${workingObject.runtimeType}');
  }
  
  return workingObject;
}

/// Converts a Position from Web Mercator to WGS84.
///
/// Valid inputs: [Position] with [x, y] in meters
/// Returns: [Position] with [longitude, latitude] coordinates
Position _toWgs84Position(Position mercator) {
  // Constants for Web Mercator projection
  const double earthRadius = 6378137.0; // in meters
  const double mercatorLimit = 20037508.34; // Maximum extent in meters
  const double originShift = 2.0 * math.pi * earthRadius / 2.0;
  
  // Extract coordinates
  final x = math.max(math.min(mercator[0]?.toDouble() ?? 0.0, mercatorLimit), -mercatorLimit);
  final y = math.max(math.min(mercator[1]?.toDouble() ?? 0.0, mercatorLimit), -mercatorLimit);
  
  // Convert x to longitude
  final longitude = x / (earthRadius * math.pi / 180.0);
  
  // Convert y to latitude
  final latRad = 2 * math.atan(math.exp(y / earthRadius)) - (math.pi / 2);
  final latitude = latRad * (180.0 / math.pi);
  
  // Clamp latitude to valid range
  final clampedLatitude = math.max(math.min(latitude, 90.0), -90.0);
  
  // Preserve altitude if present
  final alt = mercator.length > 2 ? mercator[2] : null;
  
  return Position.of(alt != null 
      ? [
          longitude, 
          clampedLatitude, 
          alt,
        ] 
      : [
          longitude, 
          clampedLatitude,
        ]);
}
