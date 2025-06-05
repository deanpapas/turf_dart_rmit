import 'dart:math' as math;
import 'package:turf/turf.dart';

/// Calculates the great circle route between two points on a sphere
///
/// Useful link: https://en.wikipedia.org/wiki/Great-circle_distance

Feature<GeometryType> greatCircle(Position start, Position end,
    {Map<String, dynamic> properties = const {},
    int npoints =
        100, // npoints = number of intermediate points less one (e.g if you want 5 intermediate points, set npoints = 6)
    int offset = 10}) {
  if (start.length != 2 || end.length != 2) {
    /// Coordinate checking
    throw ArgumentError(
        "Both start and end coordinates should have two values - a latitude and longitude");
  }

  // If start and end points are the same,
  if (start[0] == end[0] && start[1] == end[1]) {
    return Feature<LineString>(geometry: LineString(coordinates: []));
  }
  // Coordinate checking for valid values
  if (start[0]! < -90) {
    throw ArgumentError(
        "Starting latitude (vertical) coordinate is less than -90. This is not a valid coordinate.");
  }

  if (start[0]! > 90) {
    throw ArgumentError(
        "Starting latitude (vertical) coordinate is greater than 90. This is not a valid coordinate.");
  }

  if (start[1]! < -180) {
    throw ArgumentError(
        'Starting longitude (horizontal) coordinate is less than -180. This is not a valid coordinate.');
  }

  if (start[1]! > 180) {
    throw ArgumentError(
        'Starting longitude (horizontal) coordinate is greater than 180. This is not a valid coordinate.');
  }

  if (end[0]! < -90) {
    throw ArgumentError(
        "Ending latitude (vertical) coordinate is less than -90. This is not a valid coordinate.");
  }

  if (end[0]! > 90) {
    throw ArgumentError(
        "Ending latitude (vertical) coordinate is greater than 90. This is not a valid coordinate.");
  }

  if (end[1]! < -180) {
    throw ArgumentError(
        'Ending longitude (horizontal) coordinate is less than -180. This is not a valid coordinate.');
  }

  if (end[1]! > 180) {
    throw ArgumentError(
        'Ending longitude (horizontal) coordinate is greater than 180. This is not a valid coordinate.');
  }

  // Creates a list to store points for the great circle arc
  List<Position> line = [];

  num lat1 = degreesToRadians(start[0]!);
  num lng1 = degreesToRadians(start[1]!);
  num lat2 = degreesToRadians(end[0]!);
  num lng2 = degreesToRadians(end[1]!);

  // Harvesine formula
  for (int i = 0; i <= npoints; i++) {
    double f = i / npoints;
    double delta = 2 *
        math.asin(math.sqrt(math.pow(math.sin((lat2 - lat1) / 2), 2) +
            math.cos(lat1) *
                math.cos(lat2) *
                math.pow(math.sin((lng2 - lng1) / 2), 2)));
    double A = math.sin((1 - f) * delta) / math.sin(delta);
    double B = math.sin(f * delta) / math.sin(delta);
    double x = A * math.cos(lat1) * math.cos(lng1) +
        B * math.cos(lat2) * math.cos(lng2);
    double y = A * math.cos(lat1) * math.sin(lng1) +
        B * math.cos(lat2) * math.sin(lng2);
    double z = A * math.sin(lat1) + B * math.sin(lat2);

    double lat = math.atan2(z, math.sqrt(x * x + y * y));
    double lng = math.atan2(y, x);

    Position point = Position(lng, lat);
    line.add(point);
  }

  /// Check for multilinestring if path crosses anti-meridian
  bool crossAntiMeridian = (lng1 - lng2).abs() > 180;

  /// If it crossed antimeridian, we need to split our lines
  if (crossAntiMeridian) {
    List<List<Position>> multiLine = [];
    List<Position> currentLine = [];

    for (var point in line) {
      if ((point[0]! - line[0][0]!).abs() > 180) {
        multiLine.addAll([currentLine]);
        currentLine = [];
      }
      currentLine.add(point);
    }
    multiLine.addAll([currentLine]);
    return Feature<MultiLineString>(
        geometry: MultiLineString(coordinates: multiLine));
  }
  return Feature<LineString>(geometry: LineString(coordinates: line));
}

Feature<GeometryType> debugGreatCircle(Position start, Position end,
    {int npoints = 2}) {
  print("Input start: Position(${start[0]}, ${start[1]})");
  print("Input end: Position(${end[0]}, ${end[1]})");

  // Current assignment (what you have)
  num lng1 = degreesToRadians(start[0]!); // longitude
  num lat1 = degreesToRadians(start[1]!); // latitude
  num lng2 = degreesToRadians(end[0]!); // longitude
  num lat2 = degreesToRadians(end[1]!); // latitude

  print("After assignment:");
  print("lng1 (from start[0]): ${radiansToDegrees(lng1)}");
  print("lat1 (from start[1]): ${radiansToDegrees(lat1)}");
  print("lng2 (from end[0]): ${radiansToDegrees(lng2)}");
  print("lat2 (from end[1]): ${radiansToDegrees(lat2)}");

  List<Position> line = [];

  // Just add the start and end points to see what happens
  for (int i = 0; i <= npoints; i++) {
    double f = i / npoints;

    if (f == 0) {
      // Start point
      Position point = Position(lng1, lat1);
      line.add(point);
      print(
          "Start point created: Position(${lng1}, ${lat1}) = [${radiansToDegrees(lng1)}, ${radiansToDegrees(lat1)}]");
    } else if (f == 1) {
      // End point
      Position point = Position(lng2, lat2);
      line.add(point);
      print(
          "End point created: Position(${lng2}, ${lat2}) = [${radiansToDegrees(lng2)}, ${radiansToDegrees(lat2)}]");
    } else {
      // For simplicity, just add a midpoint
      double midLng = (lng1 + lng2) / 2;
      double midLat = (lat1 + lat2) / 2;
      Position point = Position(midLng, midLat);
      line.add(point);
      print(
          "Mid point created: Position(${midLng}, ${midLat}) = [${radiansToDegrees(midLng)}, ${radiansToDegrees(midLat)}]");
    }
  }

  return Feature<LineString>(geometry: LineString(coordinates: line));
}
