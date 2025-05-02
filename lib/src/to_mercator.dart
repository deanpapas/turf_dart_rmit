import 'dart:math' as math;
import 'package:geotypes/geotypes.dart';
import 'package:turf/helpers.dart';

/// Converts WGS84 GeoJSON object to Web Mercator projection.
///
/// Accepts a [GeoJSONObject] or [Position] and returns a projected [GeoJSONObject] or [Position].
/// This function handles all GeoJSON types including Point, LineString, Polygon, 
/// MultiPoint, MultiLineString, MultiPolygon, Feature, and FeatureCollection.
///
/// If [mutate] is true, the input object is mutated for performance.
///
/// See: https://en.wikipedia.org/wiki/Web_Mercator_projection
dynamic geoToMercator(dynamic geojson, {bool mutate = false}) {
  // For simple Position objects, use the direct conversion
  if (geojson is Position) {
    return _toMercatorPosition(geojson);
  }
  
  // Check that input is a GeoJSONObject for all other cases
  if (geojson is! GeoJSONObject) {
    throw ArgumentError('Unsupported input type: ${geojson.runtimeType}');
  }
  
  // Clone geojson to avoid side effects if not mutating
  final workingObject = !mutate ? (geojson as GeoJSONObject).clone() : geojson;
  
  // Handle different GeoJSON types
  if (workingObject is Point) {
    workingObject.coordinates = _toMercatorPosition(workingObject.coordinates);
  } else if (workingObject is LineString) {
    for (var i = 0; i < workingObject.coordinates.length; i++) {
      workingObject.coordinates[i] = _toMercatorPosition(workingObject.coordinates[i]);
    }
  } else if (workingObject is Polygon) {
    for (var i = 0; i < workingObject.coordinates.length; i++) {
      for (var j = 0; j < workingObject.coordinates[i].length; j++) {
        workingObject.coordinates[i][j] = _toMercatorPosition(workingObject.coordinates[i][j]);
      }
    }
  } else if (workingObject is MultiPoint) {
    for (var i = 0; i < workingObject.coordinates.length; i++) {
      workingObject.coordinates[i] = _toMercatorPosition(workingObject.coordinates[i]);
    }
  } else if (workingObject is MultiLineString) {
    for (var i = 0; i < workingObject.coordinates.length; i++) {
      for (var j = 0; j < workingObject.coordinates[i].length; j++) {
        workingObject.coordinates[i][j] = _toMercatorPosition(workingObject.coordinates[i][j]);
      }
    }
  } else if (workingObject is MultiPolygon) {
    for (var i = 0; i < workingObject.coordinates.length; i++) {
      for (var j = 0; j < workingObject.coordinates[i].length; j++) {
        for (var k = 0; k < workingObject.coordinates[i][j].length; k++) {
          workingObject.coordinates[i][j][k] = _toMercatorPosition(workingObject.coordinates[i][j][k]);
        }
      }
    }
  } else if (workingObject is GeometryCollection) {
    for (var i = 0; i < workingObject.geometries.length; i++) {
      workingObject.geometries[i] = geoToMercator(workingObject.geometries[i], mutate: true);
    }
  } else if (workingObject is Feature) {
    if (workingObject.geometry != null) {
      workingObject.geometry = geoToMercator(workingObject.geometry!, mutate: true);
    }
  } else if (workingObject is FeatureCollection) {
    for (var i = 0; i < workingObject.features.length; i++) {
      workingObject.features[i] = geoToMercator(workingObject.features[i], mutate: true);
    }
  } else {
    throw ArgumentError('Unsupported input type: ${workingObject.runtimeType}');
  }
  
  return workingObject;
}

/// Converts a Position from WGS84 to Web Mercator.
///
/// Implements the spherical Mercator projection formulas.
/// Valid inputs: [Position] with [longitude, latitude]
/// Returns: [Position] with [x, y] coordinates in meters
Position _toMercatorPosition(Position wgs84) {
  // Constants for Web Mercator projection
  const double earthRadius = 6378137.0; // in meters
  const double originShift = 2.0 * math.pi * earthRadius / 2.0;
  
  // Extract coordinates
  final longitude = wgs84[0]?.toDouble() ?? 0.0;
  final latitude = wgs84[1]?.toDouble() ?? 0.0;
  
  // Clamp latitude to avoid infinity near poles
  final clampedLat = math.min(math.max(latitude, -89.9999), 89.9999);
  
  // Convert longitude to x coordinate
  final x = longitude * originShift / 180.0;
  
  // Convert latitude to y coordinate
  final rad = clampedLat * math.pi / 180.0;
  final y = earthRadius * math.log(math.tan(math.pi / 4.0 + rad / 2.0));
  
  // Clamp to valid Mercator bounds
  final mercatorLimit = 20037508.34; // Maximum extent of Web Mercator in meters
  final clampedX = math.max(math.min(x, mercatorLimit), -mercatorLimit);
  final clampedY = math.max(math.min(y, mercatorLimit), -mercatorLimit);
  
  // Preserve altitude if present
  final alt = wgs84.length > 2 ? wgs84[2] : null;
  
  return Position.of(alt != null 
      ? [
          clampedX, 
          clampedY, 
          alt,
        ] 
      : [
          clampedX, 
          clampedY,
        ]);
}
