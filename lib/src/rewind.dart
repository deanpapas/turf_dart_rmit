import 'package:turf/turf.dart';
import 'package:turf/boolean.dart';

// Takes in a GeoJSON Object
// Returns a GeoJSON like Polygon

GeoJSONObject rewind(
  GeoJSONObject geojson, {
  bool reverse = false,
}) {
  // Feature or Geometry Collections
  if (geojson is GeometryCollection) {
    final newGeometries = geojson.geometries
        .map((geometry) {
          final rewinds = rewindFeature(geometry, reverse);
          return rewinds is GeometryType ? rewinds : null;
        })
        .whereType<GeometryType>()
        .toList();
    return GeometryCollection(
        geometries: newGeometries, bbox: geojson.bbox?.clone());
  }

  if (geojson is FeatureCollection) {
    final newFeatures = geojson.features.map((feature) {
      return rewindFeature(feature, reverse) as Feature;
    }).toList();
    return FeatureCollection(
        features: newFeatures, bbox: geojson.bbox?.clone());
  }

  // Else individual features/geometries
  return rewindFeature(geojson, reverse);
}

GeoJSONObject rewindFeature(GeoJSONObject geojson, bool reverse) {
  if (geojson is GeometryCollection) {
    final newGeometries = geojson.geometries
        .map((geometry) {
          final rewinds = rewindFeature(geometry, reverse);
          return rewinds is GeometryCollection ? rewinds : null;
        })
        .whereType<GeometryType>()
        .toList();
    return GeometryCollection(
        geometries: newGeometries, bbox: geojson.bbox?.clone());
  }

  // Converting to different GeoJSON objects and returning respective object
  if (geojson is LineString) {
    return LineString(
      coordinates: rewindLineString(geojson.coordinates, reverse),
      bbox: geojson.bbox?.clone(),
    );
  }

  if (geojson is Polygon) {
    return Polygon(
      coordinates: rewindPolygon(geojson.coordinates, reverse),
      bbox: geojson.bbox?.clone(),
    );
  }

  if (geojson is MultiLineString) {
    return MultiLineString(
      coordinates: geojson.coordinates.map((lineCoords) {
        return rewindLineString(lineCoords, reverse);
      }).toList(),
      bbox: geojson.bbox?.clone(),
    );
  }

  if (geojson is MultiPolygon) {
    return MultiPolygon(
      coordinates: geojson.coordinates.map((polygonCoords) {
        return rewindPolygon(polygonCoords, reverse);
      }).toList(),
      bbox: geojson.bbox?.clone(),
    );
  }
  return geojson;
}

List<Position> rewindLineString(List<Position> coords, bool reverse) {
  return reverse ? coords.reversed.toList() : coords.toList();
}

List<List<Position>> rewindPolygon(List<List<Position>> coords, bool reverse) {
  final newCoords = List<List<Position>>.from(coords);

  // Outer ring counterclockwise
  if (booleanClockwise(LineString(coordinates: coords[0])) != reverse) {
    newCoords[0] = newCoords[0].reversed.toList();
  }

  // Inner rings clockwise
  for (var i = 1; i < newCoords.length; i++) {
    if (booleanClockwise(LineString(coordinates: newCoords[i])) == reverse) {
      newCoords[i] = newCoords[i].reversed.toList();
    }
  }

  return newCoords;
}
