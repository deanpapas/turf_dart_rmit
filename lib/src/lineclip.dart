import 'package:geotypes/geotypes.dart';
import 'package:turf/bbox.dart';

List<List<Point>> lineclip(List<Point> points, BBox bbox, [List<List<Point>>? result]) {
  int len = points.length;
  int codeA = bitCode(points[0], bbox);
  List<Point> part = [];
  result ??= [];

  for (int i = 1; i < len; i++) {
    Point a = points[i - 1];
    Point b = points[i];
    int codeB = bitCode(b, bbox);
    int lastCode = codeB;

    while (true) {
      if ((codeA | codeB) == 0) {
        part.add(a);

        if (codeB != lastCode) {
          part.add(b);
          if (i < len - 1) {
            result.add(part);
            part = [];
          }
        } else if (i == len - 1) {
          part.add(b);
        }
        break;
      } else if ((codeA & codeB) != 0) {
        break;
      } else if (codeA != 0) {
        a = intersect(a, b, codeA, bbox);
        codeA = bitCode(a, bbox);
      } else {
        b = intersect(a, b, codeB, bbox);
        codeB = bitCode(b, bbox);
      }
    }

    codeA = lastCode;
  }

  if (part.isNotEmpty) result.add(part);

  return result;
}

List<Point> polygonclip(List<Point> points, BBox bbox) {
  List<Point> result = [];

  for (int edge = 1; edge <= 8; edge *= 2) {
    result = [];
    Point prev = points.last;
    bool prevInside = (bitCode(prev, bbox) & edge) == 0;

    for (Point p in points) {
      bool inside = (bitCode(p, bbox) & edge) == 0;

      if (inside != prevInside) {
        result.add(intersect(prev, p, edge, bbox));
      }

      if (inside) {
        result.add(p);
      }

      prev = p;
      prevInside = inside;
    }

    points = result;

    if (points.isEmpty) break;
  }

  return result;
}

Point intersect(Point a, Point b, int edge, BBox bbox) {
  double ax = a.longitude;
  double ay = a.latitude;
  double bx = b.longitude;
  double by = b.latitude;
Point pt = Point(
    coordinates: Position(0, 0),
  );
  if ((edge & 8) != 0) {
    // top
    double x = ax + (bx - ax) * (bbox.lat2 - ay) / (by - ay);
    return Point(coordinates: Position(x, bbox.lat2));
  } else if ((edge & 4) != 0) {
    // bottom
    double x = ax + (bx - ax) * (bbox.lat1 - ay) / (by - ay);
    return Point(coordinates: Position(x, bbox.lat1));
  } else if ((edge & 2) != 0) {
    // right
    double y = ay + (by - ay) * (bbox.lng2 - ax) / (bx - ax);
    return Point(coordinates: Position(bbox.lng2, y));
  } else if ((edge & 1) != 0) {
    // left
    double y = ay + (by - ay) * (bbox.lng1 - ax) / (bx - ax);
    return Point(coordinates: Position(bbox.lng1, y));
  }

  throw ArgumentError('Invalid edge');
}

int bitCode(Point p, BBox bbox) {
  int code = 0;
  double x = p.longitude;
  double y = p.latitude;

  if (x < bbox.lng1) {
    code |= 1; // left
  } else if (x > bbox.lng2) {
    code |= 2; // right
  }

  if (y < bbox.lat1) {
    code |= 4; // bottom
  } else if (y > bbox.lat2) {
    code |= 8; // top
  }

  return code;
}
